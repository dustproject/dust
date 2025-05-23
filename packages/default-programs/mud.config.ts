import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "dfprograms_1",
  userTypes: {
    EntityId: { filePath: "@dust/world/src/EntityId.sol", type: "bytes32" },
  },
  tables: {
    SmartItem: {
      schema: {
        entityId: "EntityId",
        itemId: "bytes32",
      },
      key: ["entityId"],
    },
    Owner: {
      schema: {
        itemId: "bytes32",
        owner: "EntityId",
      },
      key: ["itemId"],
    },
    AllowedCaller: {
      schema: {
        itemId: "bytes32",
        caller: "EntityId",
        allowed: "bool",
      },
      key: ["itemId", "caller"],
    },
    UniqueEntity: {
      schema: {
        value: "uint256",
      },
      key: [],
    },
  },
});
