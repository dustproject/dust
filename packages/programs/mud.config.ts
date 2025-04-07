import { defineWorld } from "@latticexyz/world";

export default defineWorld({
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
    Admin: {
      schema: {
        entityId: "EntityId",
        admin: "address",
      },
      key: ["entityId"],
    },
    AllowedPlayers: {
      schema: {
        entityId: "EntityId",
        players: "address[]",
      },
      key: ["entityId"],
    },
    AllowedPrograms: {
      schema: {
        entityId: "EntityId",
        program: "ProgramId",
        allowed: "bool",
      },
      key: ["entityId", "program"],
    },
  },
});
