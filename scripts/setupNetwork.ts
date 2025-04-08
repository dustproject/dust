import { transportObserver } from "@latticexyz/common";
import dotenv from "dotenv";
import {
  type WriteContractParameters,
  createPublicClient,
  createWalletClient,
  custom,
  parseGwei,
  size,
} from "viem";
import type { Hex } from "viem";
import { fallback } from "viem";
import { webSocket } from "viem";
import { http } from "viem";
import type {
  Abi,
  Account,
  Chain,
  ContractFunctionArgs,
  ContractFunctionName,
} from "viem";

import { privateKeyToAccount } from "viem/accounts";

import IWorldAbi from "@dust/world/IWorld.abi.json";
import worldsJson from "@dust/world/worlds.json";
import ERC20SystemAbi from "@latticexyz/world-modules/out/ERC20System.sol/ERC20System.abi.json";
import ERC721SystemAbi from "@latticexyz/world-modules/out/ERC721System.sol/ERC721System.abi.json";

import { mudFoundry } from "@latticexyz/common/chains";
import { supportedChains } from "./supportedChains";

dotenv.config();

const DEV_CHAIN_ID =
  supportedChains.find((chain) => chain.name === "Foundry")?.id ?? 31337;

const chainId = process.env.CHAIN_ID
  ? Number.parseInt(process.env.CHAIN_ID)
  : DEV_CHAIN_ID;

export type SetupNetwork = Awaited<ReturnType<typeof setupNetwork>>;

export async function setupNetwork() {
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("Missing PRIVATE_KEY in .env file");
  }
  const chainIndex = supportedChains.findIndex((c) => c.id === chainId);
  const chain = supportedChains[chainIndex];
  if (!chain) {
    throw new Error(`Chain ${chainId} not found`);
  }

  const worldAddress = worldsJson[chain.id]?.address;
  if (!worldAddress) {
    throw new Error("Missing worldAddress in worlds.json file");
  }
  const fromBlock = worldsJson[chain.id]?.blockNumber ?? 0;

  const account = privateKeyToAccount(privateKey as Hex);

  const publicClient = createPublicClient({
    chain: chain,
    transport: http(undefined, {
      batch: {
        batchSize: 100,
        wait: 1000,
      },
    }),
  });

  const walletClient = createWalletClient({
    chain: chain,
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

  const [publicKey] = await walletClient.getAddresses();

  const txOptions = {
    address: worldAddress as Hex,
    abi: IWorldAbi,
    account,
    chain,
    maxPriorityFeePerGas: 1n,
    // gas: 50_000_000n,
  };

  async function callTx<
    chain extends Chain | undefined,
    account extends Account | undefined,
    abi extends Abi | readonly unknown[],
    functionName extends ContractFunctionName<abi, "nonpayable" | "payable">,
    args extends ContractFunctionArgs<
      abi,
      "nonpayable" | "payable",
      functionName
    >,
    chainOverride extends Chain | undefined,
  >(
    txData: WriteContractParameters<
      abi,
      functionName,
      args,
      chain,
      account,
      chainOverride
    >,
    label: string | undefined = undefined,
  ) {
    let txHash: Hex;
    try {
      txHash = await walletClient.writeContract(txData);
    } catch (e) {
      console.error(e);
      return [false, e];
    }
    const receipt = await publicClient.waitForTransactionReceipt({
      hash: txHash,
      pollingInterval: 1_000,
      retryDelay: 2_000,
      timeout: 60_000,
      confirmations: 0,
    });
    if (receipt.status !== "success") {
      try {
        await publicClient.simulateContract(txData);
      } catch (e) {
        console.error(e);
        return [false, e];
      }
    }
    return [true, receipt];
  }

  const allAbis = [IWorldAbi, ERC20SystemAbi, ERC721SystemAbi];

  let indexerUrl = chain.indexerUrl;
  let indexer = undefined;
  if (chainId === mudFoundry.id) {
    indexerUrl = "http://localhost:13690";
    indexer = {
      type: "sqlite",
      url: new URL("/api/sqlite-indexer", indexerUrl).toString(),
    };
  } else {
    if (indexerUrl) {
      indexer = { type: "hosted", url: new URL("/q", indexerUrl).toString() };
    }
  }

  return {
    IWorldAbi,
    allAbis,
    worldAddress,
    walletClient,
    publicClient,
    txOptions,
    indexer,
    callTx,
    account,
    fromBlock,
  };
}
