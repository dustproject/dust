import fs from "node:fs";
import { resourceToHex } from "@latticexyz/common";
import { storeEventsAbi } from "@latticexyz/store";
import csv from "csv-parser";
import prompts from "prompts";
import { Hex, decodeFunctionData, formatEther } from "viem";
import { setupNetwork } from "./setupNetwork";

function calculateCalldataGasCost(calldataHex: string): {
  gasCost: number;
  nonZeroBytes: number;
  zeroBytes: number;
} {
  // Remove '0x' prefix and convert to bytes
  const calldata = Buffer.from(calldataHex.slice(2), "hex");

  // Count non-zero and zero bytes
  let nonZeroBytes = 0;
  let zeroBytes = 0;

  for (const byte of calldata) {
    if (byte !== 0) {
      nonZeroBytes++;
    } else {
      zeroBytes++;
    }
  }

  // Calculate gas cost using the provided formula
  const gasCost = nonZeroBytes * 16 + zeroBytes * 4;

  return {
    gasCost,
    nonZeroBytes,
    zeroBytes,
  };
}

async function main() {
  const { publicClient, worldAddress, IWorldAbi, account, txOptions, callTx } =
    await setupNetwork();

  // Path to the CSV file
  const csvFilePath = "gen/transactions.csv";

  // Read and parse the CSV file
  const txHashes = [];

  // This will store all the rows to be processed serially
  const rows: any[] = [
    {
      TxHash:
        "0x3cbc1dab0b2e4bad13add1eac9ac49a1cd614e9729177c894ce82bc9fc81d55d",
    },
  ];

  let totalL2Fee = 0n;
  let totalL1Fee = 0n;

  // Read the CSV file and push all rows to the array
  fs.createReadStream(csvFilePath)
    .pipe(csv())
    .on("data", (row) => {
      // rows.push(row);
    })
    .on("end", async () => {
      // Now process each row serially using a for loop
      let numProcessed = 0;
      for (const row of rows) {
        const { TxHash } = row;

        if (TxHash) {
          // Await each transaction processing sequentially
          try {
            const transaction = await publicClient.getTransaction({
              hash: TxHash,
            });
            const transactionReceipt = await publicClient.getTransactionReceipt(
              {
                hash: TxHash,
              },
            );
            // console.log("Transaction:", transaction);
            // console.log("Transaction Receipt:", transactionReceipt);

            const { functionName, args } = decodeFunctionData({
              abi: IWorldAbi,
              data: transaction.input,
            });

            const baseFee =
              transactionReceipt.effectiveGasPrice -
              transaction.maxPriorityFeePerGas;
            const l2Fee = transactionReceipt.gasUsed * baseFee;
            const l1Fee = transactionReceipt.l1Fee;
            const totalFee = l2Fee + transactionReceipt.l1Fee;
            totalL2Fee += l2Fee;
            totalL1Fee += l1Fee;
            // console.log("Arguments:", args);
            // console.log("Gas Used:", calculateCalldataGasCost(transaction.input));
            if (functionName === "batchCallFrom") {
              for (const batchCallArgs of args[0]) {
                const callFromCallData = decodeFunctionData({
                  abi: IWorldAbi,
                  data: batchCallArgs.callData,
                });
              }
            }
          } catch (error) {}
        }
        numProcessed++;
        if (numProcessed % 100 === 0) {
        }
      }

      const totalFee = totalL2Fee + totalL1Fee;
      process.exit(0); // Exit after processing all rows
    })
    .on("error", (error) => {
      console.error("Error reading CSV file:", error);
      process.exit(1); // Exit with error
    });
}

main();
