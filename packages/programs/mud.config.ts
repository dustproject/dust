import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "default-1",
  userTypes: {
    EntityId: { filePath: "@dust/world/src/EntityId.sol", type: "bytes32" },
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
