import IWorldAbi from "@dust/world/out/IWorld.sol/IWorld.abi";
import worldsJson from "@dust/world/worlds.json";
import { resourceToHex, transportObserver } from "@latticexyz/common";
import { mudFoundry } from "@latticexyz/common/chains";
import MetadataSystemAbi from "@latticexyz/world-module-metadata/out/MetadataSystem.sol/MetadataSystem.abi.json";
import { encodeSystemCall } from "@latticexyz/world/internal";
import dotenv from "dotenv";
import {
  http,
  createPublicClient,
  fallback,
  getContract,
  toBytes,
  toHex,
  webSocket,
} from "viem";
import { createWalletClient } from "viem";
import type { Abi, Hex } from "viem";
import { privateKeyToAccount } from "viem/accounts";

dotenv.config();

// TODO: generalize to work with any chain
export function getWorldAddress() {
  const worldAddress = worldsJson[mudFoundry.id]?.address;
  if (!worldAddress) {
    throw new Error(
      "No world address configured. Is the world still deploying?",
    );
  }
  return worldAddress;
}

const appNamespace = "pos-hud";

async function registerApp() {
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("Missing PRIVATE_KEY in .env file");
  }

  const account = privateKeyToAccount(privateKey as Hex);

  const publicClient = createPublicClient({
    chain: mudFoundry,
    transport: http(undefined, {
      batch: {
        batchSize: 100,
        wait: 1000,
      },
    }),
  });

  const walletClient = createWalletClient({
    chain: mudFoundry,
    transport: transportObserver(
      fallback([
        webSocket(),
        http(undefined, {
          batch: {
            batchSize: 100,
            wait: 1000,
          },
        }),
      ]),
    ),
    pollingInterval: 1000, // e.g. when waiting for transactions, we poll every 1000ms
    account: account,
  });

  const worldAddress = getWorldAddress();

  const appNamespaceId = resourceToHex({
    type: "namespace",
    namespace: appNamespace,
    name: "",
  });

  console.info("registering app namespace", appNamespaceId);
  // TODO: consolidate common code
  let txHash: Hex;
  try {
    txHash = await walletClient.writeContract({
      address: worldAddress as Hex,
      abi: IWorldAbi,
      account,
      functionName: "registerNamespace",
      args: [appNamespaceId],
    });
  } catch (error) {
    console.error(error);
    throw error;
  }
  let receipt = await publicClient.waitForTransactionReceipt({
    hash: txHash,
    pollingInterval: 1_000,
    retryDelay: 2_000,
    timeout: 60_000,
    confirmations: 0,
  });
  if (receipt.status === "success") {
    console.info("App registered successfully");
  } else {
    throw new Error("App registration failed");
  }

  console.info("setting app config url");
  txHash = await walletClient.writeContract({
    address: worldAddress as Hex,
    abi: IWorldAbi,
    account,
    functionName: "call",
    args: encodeSystemCall({
      abi: MetadataSystemAbi as Abi,
      systemId: resourceToHex({
        type: "system",
        namespace: "metadata",
        name: "MetadataSystem",
      }),
      functionName: "setResourceTag",
      args: [
        appNamespaceId,
        toHex("dust.appConfigUrl", { size: 32 }),
        toHex("http://localhost:5501/dust-app.json"),
      ],
    }),
  });
  receipt = await publicClient.waitForTransactionReceipt({
    hash: txHash,
    pollingInterval: 1_000,
    retryDelay: 2_000,
    timeout: 60_000,
    confirmations: 0,
  });
  if (receipt.status === "success") {
    console.info("App config url set successfully");
  } else {
    throw new Error("App config url set failed");
  }
}

registerApp();
