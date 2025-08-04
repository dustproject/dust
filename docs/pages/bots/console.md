# Browser Console

The DUST client exposes a bunch of utils under the `world` variable name. Transactions can be called using the `world.write` util.

## Example: Filling a bucket

1. Figure out the input parameters for the tx.

- DUST is built on [MUD](https://mud.dev/) and so each function has its own system contract. You can see all the system interfaces [here](https://github.com/dustproject/dust/tree/main/packages/world/src/codegen/world). We can see the [BucketSystem interface](https://github.com/dustproject/dust/blob/main/packages/world/src/codegen/world/IBucketSystem.sol#L15), shows the parameters for filling a bucket are:

```solidity
function fillBucket(EntityId caller, Vec3 waterCoord, uint16 bucketSlot) external;
```

2. Call the tx

:::tip
Almost all TXs will require the caller entity as the first argument. This is derived from the player's address. You can get this using `world.utils.encodePlayer(world.sessionClient.userAddress)`.
:::

```typescript
await world.write(
  "fillBucket",
  world.utils.encodePlayer(world.sessionClient.userAddress),
  world.utils.packVec3([597, 143, -1623]),
  1
);
```

Right after this is called, the transaction details will be printed in the console.

![TX from console](/tx-from-console.png)

You can expand on the object in the log to see more details, such as the transaction hash. eg fillBucket tx hash: [0xc3fe7fc926229b756afb2fd1cc7570c7babb4c37c28ddcc8617abed23bacc26e](https://explorer.redstone.xyz/tx/0xc3fe7fc926229b756afb2fd1cc7570c7babb4c37c28ddcc8617abed23bacc26e)

![TX from console](/tx-from-console-expanded.png)
