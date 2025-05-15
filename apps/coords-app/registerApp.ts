import IWorldAbi from "@dust/world/out/IWorld.sol/IWorld.abi";
import worldsJson from "@dust/world/worlds.json";
import { resourceToHex, transportObserver } from "@latticexyz/common";
import { mudFoundry } from "@latticexyz/common/chains";
import dotenv from "dotenv";
import {
  http,
  createPublicClient,
  fallback,
  getContract,
  webSocket,
} from "viem";
import { createWalletClient } from "viem";
import type { Hex } from "viem";
import { privateKeyToAccount } from "viem/accounts";

dotenv.config();

export function getWorldAddress() {
  const worldAddress = worldsJson[mudFoundry.id]?.address;
  if (!worldAddress) {
    throw new Error(
      "No world address configured. Is the world still deploying?",
    );
  }
  return worldAddress;
}

const appNamespace = "coords-app";

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

  const worldContract = getContract({
    abi: IWorldAbi,
    address: getWorldAddress(),
    client: {
      public: publicClient,
      wallet: walletClient,
    },
  });

  await worldContract.write.registerNamespace([
    resourceToHex({ type: "namespace", namespace: appNamespace, name: "" }),
  ]);

  await worldContract.write.metadata_setResourceTag(
    resourceToHex({ type: "namespace", namespace: appNamespace, name: "" }),
    "dust.appConfigUrl",
    "https://trading-app-client-psi.vercel.app/dust-app.json",
  );
}

registerApp();
