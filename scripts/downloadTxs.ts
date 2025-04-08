import type { Hex } from "viem";
import { setupNetwork } from "./setupNetwork";

import fs from "node:fs";
import path from "node:path";
import { replacer } from "./utils";

async function loadTransactionHashes(inputFilePath: string): Promise<{
  transactions: Hex[];
  contractAddress: Hex;
  fromBlock: string;
  toBlock: string;
}> {
  const fileContent = await fs.promises.readFile(inputFilePath, "utf-8");
  return JSON.parse(fileContent);
}

async function saveDetailedTransactionsBatch(
  transactions: any[],
  contractAddress: Hex,
  fromBlock: string,
  toBlock: string,
  batchNumber: number,
): boolean {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const fileName = `detailed_txs_${contractAddress}_from${fromBlock}_to${toBlock}_batch${batchNumber}_${timestamp}.json`;

  // const data = {
  //   contractAddress,
  //   fromBlock,
  //   toBlock,
  //   totalTransactions: transactions.length,
  //   scanCompletedAt: new Date().toISOString(),
  //   transactions,
  // };

  // filter out nulls
  const filteredTransactions = transactions.filter((el) => el !== null);
  if (filteredTransactions.length === 0) {
    return false;
  }

  try {
    const outputDir = path.join(process.cwd(), "gen");
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }

    const filePath = path.join(outputDir, fileName);

    const finalData = `{"contractAddress": "${contractAddress}", "fromBlock": "${fromBlock}", "toBlock": "${toBlock}", "totalTransactions": ${filteredTransactions.length}, "scanCompletedAt": "${new Date().toISOString()}", "transactions": [${filteredTransactions
      .map((el) => JSON.stringify(el, replacer, 2))
      .join(",")}]}`;
    await fs.promises.writeFile(filePath, finalData);
  } catch (error) {
    console.error("Error saving to JSON:", error);
  }

  return true;
}

async function main() {
  const {
    publicClient,
    fromBlock,
    worldAddress,
    IWorldAbi,
    account,
    txOptions,
    callTx,
  } = await setupNetwork();

  try {
    // Get the input file path from command line arguments or use a default
    const inputFile =
      process.argv[2] ||
      path.join(process.cwd(), "gen", "latest_transactions.json");

    const {
      transactions: txHashes,
      contractAddress,
      fromBlock,
      toBlock,
    } = await loadTransactionHashes(inputFile);

    const batchSize = 50; // Adjust based on RPC rate limits

    const proccessedHashes = new Set();

    // Get list of files to process
    const dirPath = path.join(process.cwd(), "gen/");
    const files = fs
      .readdirSync(dirPath)
      .filter((file) =>
        file.startsWith(
          `detailed_txs_${contractAddress}_from${fromBlock}_to${toBlock}_batch`,
        ),
      )
      .map((file) => path.join(dirPath, file));

    for (const file of files) {
      const { transactions } = JSON.parse(fs.readFileSync(file, "utf-8"));
      for (const transaction of transactions) {
        proccessedHashes.add(transaction.hash.toLowerCase());
      }
    }

    // Process transactions in batches
    for (let i = 0; i < txHashes.length; i += batchSize) {
      const batch = txHashes.slice(i, i + batchSize);
      const batchNumber = Math.floor(i / batchSize) + 1;

      const batchPromises = batch.map(async (hash) => {
        if (proccessedHashes.has(hash.toLowerCase())) {
          return null;
        }

        try {
          const [transaction, transactionReceipt] = await Promise.all([
            publicClient.getTransaction({ hash }),
            publicClient.getTransactionReceipt({ hash }),
          ]);

          // delete logs and logsBloom from transactionReceipt
          transactionReceipt.logs = undefined;
          transactionReceipt.logsBloom = undefined;

          return {
            hash,
            transaction,
            receipt: transactionReceipt,
          };
        } catch (error) {
          console.error(`Error processing transaction ${hash}:`, error);
          throw Error("Error processing blocks");
        }
      });

      const batchResults = await Promise.all(batchPromises);

      // Save progress periodically
      const saved = await saveDetailedTransactionsBatch(
        batchResults,
        contractAddress,
        fromBlock,
        toBlock,
        batchNumber,
      );
      if (!saved) {
        continue;
      }

      // Add a small delay between batches to avoid rate limiting
      await new Promise((resolve) => setTimeout(resolve, 3000));
    }
  } catch (error) {
    console.error("Error:", error);
    throw Error("Error processing blocks");
  }
}

main();
