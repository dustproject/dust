# Client

The DUST client exposes a bunch of utils under the `world` variable name. Transasctions can be called usnig the `world.write` util.

## Example: Filling a bucket

1. Figure out the input parameters for the tx.

- DUST is built on [MUD](https://mud.dev/) and so each function has its own system contract. You can see all the system interfaces [here](https://github.com/dustproject/dust/tree/main/packages/world/src/codegen/world). We can see the [BucketSystem interface](https://github.com/dustproject/dust/blob/main/packages/world/src/codegen/world/IBucketSystem.sol#L15), shows the interface for filling a bucket is:

```solidity
function fillBucket(EntityId caller, Vec3 waterCoord, uint16 bucketSlot) external;
```

2. Call the tx

- Many TXs will require the caller entity as the first argument. This is derived from the player's address. You can get this using `world.utils.encodePlayer(world.sessionClient.userAddress)`, in the browser console.

```typescript
await world.write(
  "fillBucket",
  world.utils.encodePlayer(world.sessionClient.userAddress),
  packVec3([597, 143, -1623]),
  1
);
```

Right after this is called, the transaction details will be printed in the console along with if it was a success or not.
