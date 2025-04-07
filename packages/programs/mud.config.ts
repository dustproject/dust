import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  // Note: this is required as the world is deployed with this
  deploy: {
    upgradeableWorldImplementation: true,
  },
  namespace: "default-1",
  userTypes: {
    ObjectTypeId: {
      filePath: "@dust/world/src/ObjectTypeId.sol",
      type: "uint16",
    },
    EntityId: { filePath: "@dust/world/src/EntityId.sol", type: "bytes32" },
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      type: "bytes32",
    },
    ProgramId: {
      filePath: "@dust/world/src/ProgramId.sol",
      type: "bytes32",
    },
  },
  tables: {
    Owner: {
      schema: {
        entityId: "EntityId",
        owner: "EntityId",
      },
      key: ["entityId"],
    },
    AllowedCallers: {
      schema: {
        target: "EntityId",
        callers: "bytes32[]", // EntityId[]
      },
      key: ["target"],
    },
  },
});
