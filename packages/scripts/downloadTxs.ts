import { Hex } from "viem";
import { setupNetwork } from "./setupNetwork";

import fs from "fs";
import path from "path";
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

async function saveDetailedTransactions(
  transactions: any[],
  contractAddress: Hex,
  fromBlock: string,
  toBlock: string,
  suffix = "detailed",
) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const fileName = `detailed_txs_${contractAddress}_from${fromBlock}_to${toBlock}_${suffix}_${timestamp}.json`;

  const data = {
    contractAddress,
    fromBlock,
    toBlock,
    totalTransactions: transactions.length,
    scanCompletedAt: new Date().toISOString(),
    transactions,
  };

  try {
    const outputDir = path.join(process.cwd(), "gen");
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }

    const filePath = path.join(outputDir, fileName);
    await fs.promises.writeFile(filePath, JSON.stringify(data, replacer, 2));
    console.log(`Saved detailed transactions to ${filePath}`);
  } catch (error) {
    console.error("Error saving to JSON:", error);
  }
}

async function main() {
  const { publicClient, fromBlock, worldAddress, IWorldAbi, account, txOptions, callTx } = await setupNetwork();

  try {
    // Get the input file path from command line arguments or use a default
    const inputFile = process.argv[2] || path.join(process.cwd(), "gen", "latest_transactions.json");
    console.log(`Reading from: ${inputFile}`);

    const { transactions: txHashes, contractAddress, fromBlock, toBlock } = await loadTransactionHashes(inputFile);
    console.log(`Processing ${txHashes.length} transactions...`);

    const detailedTransactions = [];
    const batchSize = 100; // Adjust based on RPC rate limits

    // Process transactions in batches
    for (let i = 0; i < txHashes.length; i += batchSize) {
      const batch = txHashes.slice(i, i + batchSize);

      console.log(`Processing batch ${i / batchSize + 1} of ${Math.ceil(txHashes.length / batchSize)}`);

      const batchPromises = batch.map(async (hash) => {
        try {
          const [transaction, transactionReceipt] = await Promise.all([
            publicClient.getTransaction({ hash }),
            publicClient.getTransactionReceipt({ hash }),
          ]);

          return {
            hash,
            transaction,
            receipt: transactionReceipt,
          };
        } catch (error) {
          console.error(`Error processing transaction ${hash}:`, error);
          return {
            hash,
            error: error.message,
          };
        }
      });

      const batchResults = await Promise.all(batchPromises);
      detailedTransactions.push(...batchResults);

      // Save progress periodically
      if ((i + batchSize) % 100 === 0 || i + batchSize >= txHashes.length) {
        await saveDetailedTransactions(
          detailedTransactions,
          contractAddress,
          fromBlock,
          toBlock,
          `progress_${i + batchSize}`,
        );
      }

      // Add a small delay between batches to avoid rate limiting
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    // Save final results
    await saveDetailedTransactions(detailedTransactions, contractAddress, fromBlock, toBlock);

    console.log("Processing completed!");
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
