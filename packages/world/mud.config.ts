import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  deploy: {
    upgradeableWorldImplementation: true,
  },
  codegen: {
    generateSystemLibraries: true,
  },
  enums: {
    Action: [
      "None",
      "Build",
      "Mine",
      "Move",
      "Craft",
      "CraftFuel",
      "Drop",
      "Pickup",
      "Transfer",
      "Spawn",
      "Sleep",
      "Wakeup",
      "FuelMachine",
      "HitMachine",
      "AttachProgram",
      "DetachProgram",
      "AddFragment",
      "RemoveFragment",
      "Death",
    ],
    Direction: [
      // Cardinal directions (6)
      "PositiveX",
      "NegativeX",
      "PositiveY",
      "NegativeY",
      "PositiveZ",
      "NegativeZ",
      // Edge directions (12)
      "PositiveXPositiveY",
      "PositiveXNegativeY",
      "NegativeXPositiveY",
      "NegativeXNegativeY",
      "PositiveXPositiveZ",
      "PositiveXNegativeZ",
      "NegativeXPositiveZ",
      "NegativeXNegativeZ",
      "PositiveYPositiveZ",
      "PositiveYNegativeZ",
      "NegativeYPositiveZ",
      "NegativeYNegativeZ",
      // Corner directions (8)
      "PositiveXPositiveYPositiveZ",
      "PositiveXPositiveYNegativeZ",
      "PositiveXNegativeYPositiveZ",
      "PositiveXNegativeYNegativeZ",
      "NegativeXPositiveYPositiveZ",
      "NegativeXPositiveYNegativeZ",
      "NegativeXNegativeYPositiveZ",
      "NegativeXNegativeYNegativeZ",
    ],
  },
  userTypes: {
    ObjectType: { filePath: "./src/ObjectType.sol", type: "uint16" },
    EntityId: { filePath: "./src/EntityId.sol", type: "bytes32" },
    ProgramId: { filePath: "./src/ProgramId.sol", type: "bytes32" },
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      type: "bytes32",
    },
    Vec3: { filePath: "./src/Vec3.sol", type: "uint96" },
  },
  tables: {
    // ------------------------------------------------------------
    // Static Data
    // ------------------------------------------------------------
    ObjectPhysics: {
      schema: {
        objectType: "ObjectType",
        mass: "uint128",
        energy: "uint128",
      },
      key: ["objectType"],
    },
    Recipes: {
      schema: {
        recipeId: "bytes32",
        stationTypeId: "ObjectType",
        craftingTime: "uint128",
        inputTypes: "uint16[]",
        inputAmounts: "uint16[]",
        outputTypes: "uint16[]",
        outputAmounts: "uint16[]",
      },
      key: ["recipeId"],
    },
    InitialEnergyPool: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        energy: "uint128",
      },
      key: ["x", "y", "z"],
    },
    // ------------------------------------------------------------
    // Grid
    // ------------------------------------------------------------
    EntityObjectType: {
      schema: {
        entityId: "EntityId",
        objectType: "ObjectType",
      },
      key: ["entityId"],
    },
    Position: {
      schema: {
        entityId: "EntityId",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      key: ["entityId"],
    },
    ReversePosition: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        entityId: "EntityId",
      },
      key: ["x", "y", "z"],
    },
    Orientation: {
      schema: {
        entityId: "EntityId",
        direction: "Direction",
      },
      key: ["entityId"],
    },
    Mass: {
      schema: {
        entityId: "EntityId",
        mass: "uint128",
      },
      key: ["entityId"],
    },
    Energy: {
      schema: {
        entityId: "EntityId",
        lastUpdatedTime: "uint128",
        energy: "uint128",
        drainRate: "uint128",
      },
      key: ["entityId"],
    },
    LocalEnergyPool: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        energy: "uint128",
      },
      key: ["x", "y", "z"],
    },
    ExploredChunk: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        explorer: "address",
      },
      key: ["x", "y", "z"],
    },
    SurfaceChunkByIndex: {
      schema: {
        index: "uint256",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      key: ["index"],
    },
    SurfaceChunkCount: {
      schema: {
        count: "uint256",
      },
      key: [],
    },
    RegionMerkleRoot: {
      schema: {
        x: "int32",
        z: "int32",
        root: "bytes32",
      },
      key: ["x", "z"],
    },
    // ------------------------------------------------------------
    // Inventory
    // ------------------------------------------------------------
    Inventory: {
      schema: {
        owner: "EntityId",
        occupiedSlots: "uint16[]", // Slots with at least 1 item
      },
      key: ["owner"],
    },
    InventorySlot: {
      schema: {
        owner: "EntityId",
        slot: "uint16",
        entityId: "EntityId",
        objectType: "ObjectType",
        amount: "uint16",
        // TODO: we could make them bigger but not sure if neeed
        occupiedIndex: "uint16",
        typeIndex: "uint16", // Index in InventoryTypeSlots
      },
      key: ["owner", "slot"],
    },
    InventoryTypeSlots: {
      schema: {
        owner: "EntityId",
        objectType: "ObjectType",
        slots: "uint16[]", // All slots containing this object type
      },
      key: ["owner", "objectType"],
    },
    // ------------------------------------------------------------
    // Movable positions
    // ------------------------------------------------------------
    MovablePosition: {
      schema: {
        entityId: "EntityId",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      key: ["entityId"],
    },
    ReverseMovablePosition: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        entityId: "EntityId",
      },
      key: ["x", "y", "z"],
    },
    // ------------------------------------------------------------
    // Player
    // ------------------------------------------------------------
    Player: {
      schema: {
        player: "address",
        entityId: "EntityId",
      },
      key: ["player"],
    },
    ReversePlayer: {
      schema: {
        entityId: "EntityId",
        player: "address",
      },
      key: ["entityId"],
    },
    BedPlayer: {
      schema: {
        bedEntityId: "EntityId",
        playerEntityId: "EntityId",
        lastDepletedTime: "uint128",
      },
      key: ["bedEntityId"],
    },
    PlayerBed: {
      schema: {
        entityId: "EntityId",
        bedEntityId: "EntityId",
      },
      key: ["entityId"],
    },
    // ------------------------------------------------------------
    // Smart Entities
    // ------------------------------------------------------------
    EntityProgram: {
      schema: {
        entityId: "EntityId",
        program: "ProgramId",
      },
      key: ["entityId"],
    },
    Fragment: {
      schema: {
        entityId: "EntityId",
        forceField: "EntityId",
        forceFieldCreatedAt: "uint128",
        // Comes from beds with sleeping players or
        // other entities that might continuously drain energy
        extraDrainRate: "uint128",
      },
      key: ["entityId"],
    },
    FragmentPosition: {
      schema: {
        entityId: "EntityId",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      key: ["entityId"],
    },
    ReverseFragmentPosition: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        entityId: "EntityId",
      },
      key: ["x", "y", "z"],
    },
    Machine: {
      schema: {
        entityId: "EntityId",
        createdAt: "uint128",
        depletedTime: "uint128",
      },
      key: ["entityId"],
    },
    Station: {
      schema: {
        entityId: "EntityId",
        recipeId: "bytes32",
        beganCraftingAt: "uint128",
        maxOutputAmount: "uint16",
      },
      key: ["entityId"],
    },
    // ------------------------------------------------------------
    // Resources
    // ------------------------------------------------------------
    ChunkCommitment: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        blockNumber: "uint256",
      },
      key: ["x", "y", "z"],
    },
    ResourcePosition: {
      schema: {
        objectType: "ObjectType",
        index: "uint256",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      key: ["objectType", "index"],
    },
    ResourceCount: {
      schema: {
        objectType: "ObjectType",
        count: "uint256",
      },
      key: ["objectType"],
    },
    BurnedResourceCount: {
      schema: {
        objectType: "ObjectType",
        count: "uint256",
      },
      key: ["objectType"],
    },
    DisabledExtraDrops: {
      schema: {
        entityId: "EntityId",
        disabled: "bool",
      },
      key: ["entityId"],
    },
    // ------------------------------------------------------------
    // Farming
    // ------------------------------------------------------------
    SeedGrowth: {
      schema: {
        entityId: "EntityId",
        fullyGrownAt: "uint128",
      },
      key: ["entityId"],
    },
    // ------------------------------------------------------------
    // Offchain
    // ------------------------------------------------------------
    Notification: {
      schema: {
        playerEntityId: "EntityId",
        timestamp: "uint128",
        action: "Action",
        data: "bytes",
      },
      key: ["playerEntityId"],
      type: "offchainTable",
    },
    // ------------------------------------------------------------
    // Internal
    // ------------------------------------------------------------
    WorldStatus: {
      schema: {
        inMaintenance: "bool",
      },
      key: [],
    },
    UniqueEntity: {
      schema: {
        value: "uint256",
      },
      key: [],
    },
    BaseEntity: {
      schema: {
        entityId: "EntityId",
        baseEntityId: "EntityId",
      },
      key: ["entityId"],
    },
  },
  systems: {
    AdminSystem: {
      deploy: {
        disabled: true,
      },
    },
  },
});
