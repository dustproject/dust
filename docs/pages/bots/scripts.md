# Scripts

Custom bot scripts can be written in various different ways.

## Example: Filling a bucket

0. Install pre-reqs

```
pnpm install viem @latticexyz/common
```

The DUST world package is not available via NPM, and needs to be installed by adding the published github release to your `package.json`.

`"@dust/world": "https://pkg.pr.new/dustproject/dust/@dust/world@3374e63"`

1. Setup the wallet clients.

```typescript
import {
  createPublicClient,
  createWalletClient,
  fallback,
  http,
  webSocket,
} from "viem";
import { createBurnerAccount } from "@latticexyz/common";
import { transactionQueue } from "@latticexyz/common/actions";
import { redstone } from "@latticexyz/common/chains";

const clientOptions = {
  chain: redstone,
  transport: fallback([webSocket(), http()]),
  pollingInterval: 2_000,
};

const publicClient = createPublicClient(clientOptions);

const walletClient = createWalletClient({
  ...clientOptions,
  account: createBurnerAccount(process.env.PRIVATE_KEY),
}).extend(transactionQueue());
```

2. Call the tx

```typescript
import IWorldAbi from "@dust/world/out/IWorld.sol/IWorld.abi";
import worldsJson from "@dust/world/worlds.json";

const worldAddress = worldsJson[redstone.id]?.address as Hex;

const worldContract = getContract({
  address: worldAddress as Hex,
  abi: IWorldAbi,
  client: { public: publicClient, wallet: walletClient },
});

const txHash = await worldContract.write.fillBucket(
  encodePlayer(walletClient.account.address),
  packVec3([597, 143, -1623]),
  1
);
const txReceipt = await publicClient.waitForTransactionReceipt({
  hash: txHash,
});
if (txReceipt.status !== "success") {
  console.error(`Tx (${txHash}) failed`);
} else {
  console.log(`Tx (${txHash}) succeeded`);
}
```
