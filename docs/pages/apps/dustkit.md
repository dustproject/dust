# Dustkit

Dustkit is the bridge between apps and the native Dust browser client.

## Getting started

### Setup

1. Add `dustkit` as a dependency to `package.json`. The tag at the end corresponds to the github commit on main

```
"dustkit": "https://pkg.pr.new/dustproject/dust/dustkit@27f724c"
```

2. Connect the dustkit client:

```
import { connectDustClient } from "dustkit/internal";
const { appContext, provider } = await connectDustClient();
```

3. You can now access the methods on the `provider` object

## Reference

### `setWaypoint`

Sets a waypoint for a specific entity with a label.

**Parameters:**

- `entity` (EntityId): The entity to set the waypoint for
- `label` (string): The label for the waypoint

**Returns:** `void`

### `getSlots`

Retrieves slot information for inventory operations.

**Parameters:**

- `entity` (EntityId): The entity to get slots for
- `objectType` (number): The type of object
- `amount` (number): The amount of objects
- `operationType` ("withdraw" | "deposit"): "withdraw" means you want the slots where this object & amount exists and "deposit" means you want the slots where this object & amount will fit

**Returns:**

```typescript
{
  slots: {
    slot: number;
    amount: number;
  }
  [];
}
```

### `systemCall`

Executes a system call in the world

**Parameters:**

- `params` (SystemCalls): The system call parameters

**Returns:** Either a user operation receipt or transaction receipt:

```typescript
{
  userOperationHash: Hex;
  receipt: UserOperationReceipt;
} | {
  transactionHash: Hex;
  receipt: TransactionReceipt;
}
```

### `getPlayerPosition`

Gets the 3D position of a player entity.

**Parameters:**

- `entity` (EntityId): The player entity

**Returns:**

```typescript
{
  x: number;
  y: number;
  z: number;
}
```

### `setBlueprint`

Sets a blueprint with block positions and options.

**Parameters:**

- `blocks`: Array of block definitions:
  ```typescript
  {
    objectTypeId: number;
    x: number;
    y: number;
    z: number;
    orientation: number;
  }
  [];
  ```
- `options` (optional): Blueprint display options:
  ```typescript
  {
    showBlocksToMine: boolean;
    showBlocksToBuild: boolean;
  }
  ```

**Returns:** `void`

### `getSelectedObjectType`

Gets the currently selected object type in the players hotbar.

**Parameters:** None

**Returns:** `number` - The selected object type ID

### `getForceFieldAt`

Gets force field information at a specific coordinate.

**Parameters:**

- `x` (number): X coordinate
- `y` (number): Y coordinate
- `z` (number): Z coordinate

**Returns:** Force field data or undefined:

```typescript
{
  forceFieldId: Hex;
  fragmentId: Hex;
  fragmentPos: {
    x: number;
    y: number;
    z: number;
  };
  forceFieldCreatedAt: bigint;
  extraDrainRate: bigint;
} | undefined
```
