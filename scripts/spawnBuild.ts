import fs from "node:fs";
import prompts from "prompts";
import type { Hex } from "viem";
import { setupNetwork } from "./setupNetwork";

async function main() {
  const { publicClient, worldAddress, IWorldAbi, account, txOptions, callTx } =
    await setupNetwork();

  const build = JSON.parse(fs.readFileSync("gen/build.json", "utf8"));

  const baseWorldCoord = build.baseWorldCoord;
  if (baseWorldCoord === undefined) {
    throw new Error("baseWorldCoord is not defined in build");
  }

  const response = await prompts({
    type: "confirm",
    name: "continue",
    message: "Are you sure you want to continue?",
  });
  if (!response.continue) {
    process.exit(0);
  }

  let numTx = 0;
  const batchSize = 50;
  let batchPositions: Array<{ x: number; y: number; z: number }> = [];
  let batchObjectIds: number[] = [];

  for (let i = 0; i < build.relativePositions.length; i++) {
    if (i % 1000 === 0) {
    }

    const relativePos = build.relativePositions[i];
    const objectTypeId = build.objectTypeIds[i];

    const worldPos = {
      x: baseWorldCoord.x + relativePos.x,
      y: baseWorldCoord.y + relativePos.y,
      z: baseWorldCoord.z + relativePos.z,
    };

    const objectTypeIdAtCoord = await publicClient.readContract({
      address: worldAddress as Hex,
      abi: IWorldAbi,
      functionName: "getObjectTypeIdAtCoordOrTerrain",
      args: [worldPos],
      account,
    });

    if (objectTypeIdAtCoord === objectTypeId) {
      continue;
    }

    // Add the world position and object type to the batch
    batchPositions.push(worldPos);
    batchObjectIds.push(objectTypeId);

    // Once we have a full batch, send a transaction
    if (batchPositions.length === batchSize) {
      numTx++;
      await callTx(
        {
          ...txOptions,
          functionName: "setObjectAtCoord", // Assuming this is your batch function
          args: [batchObjectIds, batchPositions],
        },
        `Building batch of ${batchSize} objects`,
      );

      // Clear the batch arrays
      batchPositions = [];
      batchObjectIds = [];
    }
  }

  // Send any remaining objects that didn't complete a full batch
  if (batchPositions.length > 0) {
    numTx++;
    await callTx(
      {
        ...txOptions,
        functionName: "setObjectAtCoord",
        args: [batchObjectIds, batchPositions],
      },
      `Building final batch of ${batchPositions.length} objects`,
    );
  }

  process.exit(0);
}

main();
