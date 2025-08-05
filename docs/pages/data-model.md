# Data Model

DUST is built using [MUD](https://mud.dev/), and so the [mud.config.ts](https://github.com/dustproject/dust/blob/main/packages/world/mud.config.ts) defines all the different entities and components. Here we look at 2 specific kinds of data and how to read them.

## Object at Position

The entire world is a 3D grid where each `[x, y, z]` coordinate has a certain object (ie player, block, or air). This is what you see in the client as you look around.

:::tip
y is the height
:::

For example, we can see the player is standing at `[1380, 79, -2434]`, and there is a grass block below at `[1380, 78, -2434]`.

![dust terrian third person](/dust-terrain-third-person.png)

![dust terrian first person](/dust-terrain-first-person.png)

### Tables

The latest object type at a coordinate can be read from the `EntityObjectType` table.

```typescript
EntityObjectType: {
  schema: {
    entityId: "EntityId",
    objectType: "ObjectType",
  },
  key: ["entityId"],
},
EntityPosition: {
  schema: {
    entityId: "EntityId",
    x: "int32",
    y: "int32",
    z: "int32",
  },
  key: ["entityId"],
}
```

To save on gas, this table is not prefilled with the entire map. Instead the intitial terrain is defined in the bytecode of a smart contract.

### Reading Via Explorer

#### Which object is at this position?

1. Get the entity id corresponding to the coordinate using the `encodeBlock` util:

```typescript
world.utils.encodeBlock([1380, 78, -2434]);
```

This returns `0x03000005640000004efffff67e00000000000000000000000000000000000000`

2. Filter the `EntityObjectType` table using this entity id:

```sql
SELECT "entityId", "objectType" FROM "EntityObjectType" WHERE "entityId" = '0x03000005640000004efffff67e00000000000000000000000000000000000000';
```

![explorer entity object type](explorer-entity-object-type.png)

This shows the object type is 21.

3. Check which object this id is from [ObjectType.sol](https://github.com/dustproject/dust/blob/main/packages/world/src/types/ObjectType.sol)

We can see this coordinate has grass!

```solidity
ObjectType constant Grass = ObjectType.wrap(21);
```

:::warning
Via the explorer, you can only see blocks modified, not the initial terrain data.
:::

#### Which coordinate is this player at?

1. Get the player entity id using the `encodePlayer` util:

```typescript
world.utils.encodePlayer("0xcD0DD7a799b8281dddA11c5AA54FE8A2D05aAcF4");
```

This returns `0x01cd0dd7a799b8281ddda11c5aa54fe8a2d05aacf40000000000000000000000`

2. Filter the `EntityPosition` table using this entity id:

```sql
SELECT "entityId", "x", "y", "z" FROM "EntityPosition" WHERE "entityId" = '0x01cd0dd7a799b8281ddda11c5aa54fe8a2d05aacf40000000000000000000000';
```

![explorer entity position](explorer-entity-position.png)

This shows the player is at `[1380, 79, -2434]`.

### Reading In A Program

```solidity
import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { ObjectType } from "@dust/world/src/types/ObjectType.sol";
import { Vec3 } from "@dust/world/src/types/Vec3.sol";
import { EntityObjectType } from "@dust/world/src/codegen/tables/EntityObjectType.sol";

function getObjectTypeAt(Vec3 coord) internal view returns (ObjectType) {
  EntityId entityId = EntityTypeLib.encodeBlock(coord);
  ObjectType objectType = EntityObjectType.get(entityId);

  return objectType.isNull() ? TerrainLib.getBlockType(coord) : objectType;
}
```

### Reading In An App

```typescript
import { encodeBlock, getTerrainBlockType, Vec3 } from "@dust/world/internal";

function getObjectTypeAt(
  publicClient: PublicClient,
  pos: Vec3
): Promise<number> {
  const objectTypeRecord = stash.getRecord({
    table: tables.EntityObjectType,
    key: { entityId: encodeBlock(pos) },
  });
  let objectTypeId = objectTypeRecord?.objectType;
  if (!objectTypeId) {
    objectTypeId = await getTerrainBlockType(publicClient, worldAddress, pos);
  }
  return objectTypeId;
}
```

## Inventory

Players, chests, and all [pass through blocks](https://github.com/dustproject/dust/blob/main/packages/world/ts/objects.ts#L2033) (ie, air, water, flower, etc) can have an inventory.

Players have 36 slots

![player inventory labelled](player-inventory-labelled.png)

Chests have 27 slots

![chest inventory labelled](chest-inventory-labelled.png)

### Tables

```typescript
InventorySlot: {
  schema: {
    owner: "EntityId",
    slot: "uint16",
    entityId: "EntityId",
    objectType: "ObjectType",
    amount: "uint16",
  },
  key: ["owner", "slot"],
},
InventoryBitmap: {
  schema: {
    owner: "EntityId",
    bitmap: "uint256[]", // Each uint256 holds 256 slots
  },
  key: ["owner"],
},
```

### Reading Via Explorer

![player inventory](player-inventory.png)

1. Get the player entity id using the `encodePlayer` util:

```typescript
world.utils.encodePlayer("0xcD0DD7a799b8281dddA11c5AA54FE8A2D05aAcF4");
```

This returns `0x01cd0dd7a799b8281ddda11c5aa54fe8a2d05aacf40000000000000000000000`

2. Filter the `InventorySlot` table using this entity id and slot:

```sql
SELECT "owner", "slot", "entityId", "objectType", "amount" FROM "InventorySlot" WHERE "owner" = '0x01cd0dd7a799b8281ddda11c5aa54fe8a2d05aacf40000000000000000000000';
```

![explorer entity inventory slot](explorer-entity-inventory-slot.png)

This shows all the items the player has. eg, the player has 4 WheatSeeds (id 134) in slot 2.

### Reading In A Program

```solidity
import { InventorySlot, InventorySlotData } from "@dust/world/src/codegen/tables/InventorySlot.sol";

InventorySlotData slotData = InventorySlot.get(EntityId.encodePlayer(0xcD0DD7a799b8281dddA11c5AA54FE8A2D05aAcF4), 1);

```

### Reading In An App

```typescript
import { getRecord } from "@latticexyz/store/internal";
import { encodePlayer } from "@dust/world/internal";
import mudConfig from "@dust/world/mud.config";

const slotData = await getRecord(publicClient, {
  address: worldAddress,
  table: mudConfig.tables.InventorySlot,
  key: {
    owner: encodePlayer("0xcD0DD7a799b8281dddA11c5AA54FE8A2D05aAcF4"),
    slot: 1,
  },
});
```
