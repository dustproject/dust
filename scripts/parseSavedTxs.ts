import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { Worker } from "node:worker_threads";
import { formatEther } from "viem";
import { setupNetwork } from "./setupNetwork";
import { replacer } from "./utils";

// Number of CPU cores to use (leave one core free for system processes)
const NUM_WORKERS = Math.max(1, os.cpus().length - 1);
const BATCH_SIZE = 1000; // Number of files to process in each batch

async function createWorker(allWork) {
  return new Promise((resolve, reject) => {
    const worker = new Worker("./workerCode.cjs");
    worker.on("message", resolve);
    worker.on("error", reject);
    worker.on("exit", (code) => {
      if (code !== 0)
        reject(new Error(`Worker stopped with exit code ${code}`));
    });

    worker.postMessage(allWork);
  });
}

async function main() {
  const startTime = Date.now();

  // Setup initial configuration
  const {
    publicClient,
    worldAddress,
    allAbis,
    account,
    txOptions,
    callTx,
    fromBlock,
  } = await setupNetwork();

  const referenceStartBlock = BigInt(fromBlock);
  const block = await publicClient.getBlock({
    blockNumber: referenceStartBlock,
  });
  const referenceStartTimestamp = block.timestamp;

  // Get list of files to process
  const dirPath = path.join(process.cwd(), "gen/server_gen");
  const files = fs
    .readdirSync(dirPath)
    .filter((file) => file.startsWith("detailed_txs_"))
    .map((file) => path.join(dirPath, file));

  const totalFiles = files.length;

  // Split files into batches for each worker
  const batchedFiles = [];
  for (let i = 0; i < files.length; i += BATCH_SIZE) {
    batchedFiles.push(files.slice(i, i + BATCH_SIZE));
  }

  // Create worker pool and process batches
  const workers = new Array(NUM_WORKERS).fill(null).map(() => []);
  let currentWorker = 0;

  // Distribute batches across workers
  for (const batch of batchedFiles) {
    workers[currentWorker].push(batch);
    currentWorker = (currentWorker + 1) % NUM_WORKERS;
  }

  let processedBatches = 0;

  // Process all batches in parallel
  const workerPromises = workers.map(async (workerBatches, index) => {
    if (workerBatches.length === 0) return null;

    const results = [];
    for (const batch of workerBatches) {
      const result = await createWorker({
        filesToProcess: batch,
        abis: allAbis,
        worldAddress,
        referenceStartBlock: referenceStartBlock,
        referenceStartTimestamp: referenceStartTimestamp,
      });
      if (result.error) {
        throw new Error(`Worker ${index} error: ${result.error}`);
      }
      results.push(result);

      // Increment processed batch counter
      processedBatches++;

      // Log progress
      const completedFiles = processedBatches * BATCH_SIZE;
      const progress = Math.min(
        (completedFiles / totalFiles) * 100,
        100,
      ).toFixed(2);
    }
    return results;
  });

  // Wait for all workers to complete and aggregate results
  const workerResults = (await Promise.all(workerPromises)).filter(Boolean);

  // Combine results from all workers
  const finalResults = {
    baseFeeTotal: BigInt(0),
    l2FeeTotal: BigInt(0),
    l1FeeTotal: BigInt(0),
    totalFeeSum: BigInt(0),
    priorityFeeTotal: BigInt(0),
  };
  const finalTxCounts = new Map();
  const finalDailyStats = new Map();

  let totalTransactions = 0;
  let totalContractCreations = 0;
  let totalNonWorldTxs = 0;
  let totalUnknownTxs = 0;
  let finalEarliestFromBlock = Number.POSITIVE_INFINITY;
  let finalLatestToBlock = 0;

  const allUserStats = new Map();

  for (const result of workerResults.flat()) {
    finalResults.baseFeeTotal += result.aggregatedFees.baseFeeTotal;
    finalResults.l2FeeTotal += result.aggregatedFees.l2FeeTotal;
    finalResults.l1FeeTotal += result.aggregatedFees.l1FeeTotal;
    finalResults.totalFeeSum += result.aggregatedFees.totalFeeSum;
    finalResults.priorityFeeTotal += result.aggregatedFees.priorityFeeTotal;
    totalTransactions += result.numTransactions;
    totalContractCreations += result.contractCreationCount;
    totalNonWorldTxs += result.nonWorldTxCount;
    totalUnknownTxs += result.unknownTxCount;
    // iterate oer result.txCounts map
    for (const [txType, count] of result.txCounts.entries()) {
      if (!finalTxCounts.has(txType)) {
        finalTxCounts.set(txType, 0);
      }
      finalTxCounts.set(txType, finalTxCounts.get(txType) + count);
    }

    for (const [user, stat] of result.perUserStats.entries()) {
      let userStat = allUserStats.get(user);
      if (userStat === undefined) {
        userStat = {
          txCounts: new Map(),
          numActions: 0,
          numTxs: 0,
          numContractCreations: 0,
          numNonWorldTxs: 0,
          numUnknownTxs: 0,
          totalL2Fees: BigInt(0),
          totalL1Fees: BigInt(0),
          totalBaseFees: BigInt(0),
          totalPriorityFees: BigInt(0),
          totalFees: BigInt(0),
          firstTxDate: null,
          lastTxDate: null,
        };
      }
      for (const [txType, count] of stat.txCounts.entries()) {
        const currentCount = userStat.txCounts.get(txType) || 0;
        userStat.txCounts.set(txType, currentCount + count);
      }
      userStat.totalL2Fees += stat.totalL2Fees;
      userStat.totalL1Fees += stat.totalL1Fees;
      userStat.totalBaseFees += stat.totalBaseFees;
      userStat.totalPriorityFees += stat.totalPriorityFees;
      userStat.totalFees += stat.totalFees;
      userStat.numTxs += stat.numTxs;
      userStat.numActions += stat.numActions;
      if (
        userStat.firstTxDate === null ||
        stat.firstTxDate < userStat.firstTxDate
      ) {
        userStat.firstTxDate = stat.firstTxDate;
      }
      if (
        userStat.lastTxDate === null ||
        stat.lastTxDate > userStat.lastTxDate
      ) {
        userStat.lastTxDate = stat.lastTxDate;
      }
      userStat.numContractCreations += stat.numContractCreations;
      userStat.numNonWorldTxs += stat.numNonWorldTxs;
      userStat.numUnknownTxs += stat.numUnknownTxs;
      allUserStats.set(user, userStat);
    }

    finalEarliestFromBlock = Math.min(finalEarliestFromBlock, result.fromBlock);
    finalLatestToBlock = Math.max(finalLatestToBlock, result.toBlock);

    // dailyStat = { txCount: 0, fees: BigInt(0), users: new Set() };

    for (const [date, resultDailyStat] of result.dailyStats.entries()) {
      let dailyStat = finalDailyStats.get(date);
      if (dailyStat === undefined) {
        dailyStat = { txCount: 0, fees: BigInt(0), users: new Set() };
      }
      dailyStat.txCount += resultDailyStat.txCount;
      dailyStat.fees += resultDailyStat.fees;
      for (const user of resultDailyStat.users) {
        dailyStat.users.add(user);
      }
      finalDailyStats.set(date, dailyStat);
    }
  }

  for (const [txType, count] of finalTxCounts.entries()) {
  }

  // console.log("\nDaily Statistics:");
  // for (const [date, dailyStat] of finalDailyStats.entries()) {
  //   console.log(`${date}:`);
  //   console.log(`  Transactions: ${dailyStat.txCount}`);
  //   console.log(`  Fees: ${formatEther(dailyStat.fees)}`);
  //   console.log(`  Unique users: ${dailyStat.users.size}`);
  // }

  // Write these stats to a file
  const stats = {
    fromBlock: finalEarliestFromBlock,
    toBlock: finalLatestToBlock,
    totalTransactions,
    totalContractCreations,
    totalNonWorldTxs,
    totalUnknownTxs,

    aggregatedFees: finalResults,
    txCounts: Object.fromEntries(finalTxCounts),
    allUserStats: Object.fromEntries(allUserStats.entries()),
    dailyStats: Object.fromEntries(
      Array.from(finalDailyStats.entries()).map(([date, dailyStat]) => {
        return [date, { ...dailyStat, users: Array.from(dailyStat.users) }];
      }),
    ),
  };
  fs.writeFileSync("gen/stats.json", JSON.stringify(stats, replacer, 2));

  const endTime = Date.now();
}

main().catch(console.error);
