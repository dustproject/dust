import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "dfprograms_1",
  codegen: {
    generateSystemLibraries: true,
  },
  userTypes: {
    EntityId: { filePath: "@dust/world/src/EntityId.sol", type: "bytes32" },
  },
  tables: {
    AccessGroupCount: {
      schema: {
        count: "uint256",
      },
      key: [],
    },
    AccessGroupOwner: {
      schema: {
        groupId: "uint256",
        owner: "EntityId",
      },
      key: ["groupId"],
    },
    AccessGroupMember: {
      schema: {
        groupId: "uint256",
        member: "EntityId",
        hasAccess: "bool",
      },
      key: ["groupId", "member"],
    },
    EntityAccessGroup: {
      schema: {
        entityId: "EntityId",
        groupId: "uint256",
      },
      key: ["entityId"],
    },
  },
  systems: {
    DefaultProgramSystem: {
      deploy: {
        registerWorldFunctions: false,
      },
    },
  },
});
