import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  sourceDirectory: "contracts",
  namespace: "dustkit",
  userTypes: {
    ResourceId: {
      type: "bytes32",
      filePath: "@latticexyz/store/src/ResourceId.sol",
    },
    EntityId: {
      type: "bytes32",
      filePath: "@dust/world/src/types/EntityId.sol",
    },
    ProgramId: {
      type: "bytes32",
      filePath: "@dust/world/src/types/ProgramId.sol",
    },
  },
  tables: {
    // TODO
  },
});
