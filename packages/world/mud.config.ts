import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  deploy: {
    upgradeableWorldImplementation: true,
  },
  codegen: {
    generateSystemLibraries: true,
  },
  enums: {
    NotificationType: [
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
      "HitPlayer",
      "AttachProgram",
      "DetachProgram",
      "AddFragment",
      "RemoveFragment",
      "Death",
    ],
    RateLimitType: ["Movement", "Combat", "Work"],
    ActivityType: [
      "MinePickMass",
      "MineAxeMass",
      "MineCropMass",
      "HitPlayerDamage",
      "HitMachineDamage",
      "MoveWalkSteps",
      "MoveSwimSteps",
      "MoveFallEnergy",
      "BuildEnergy",
      "BuildMass",
      "CraftHandMass",
      "CraftWorkbenchMass",
      "CraftPowerstoneMass",
      "CraftFurnaceMass",
      "CraftStonecutterMass",
      "CraftAnvilMass",
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
    ObjectType: { filePath: "./src/types/ObjectType.sol", type: "uint16" },
    Orientation: { filePath: "./src/types/Orientation.sol", type: "uint8" },
    EntityId: { filePath: "./src/types/EntityId.sol", type: "bytes32" },
    ProgramId: { filePath: "./src/types/ProgramId.sol", type: "bytes32" },
    Vec3: { filePath: "./src/types/Vec3.sol", type: "uint96" },
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      type: "bytes32",
    },
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
    EntityFluidLevel: {
      schema: {
        entityId: "EntityId",
        level: "uint8",
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
    },
    EntityOrientation: {
      schema: {
        entityId: "EntityId",
        orientation: "Orientation",
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
    // ------------------------------------------------------------
    // Movable entities
    // ------------------------------------------------------------
    ReverseMovablePosition: {
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
        entityId: "EntityId",
      },
      key: ["x", "y", "z"],
    },
    RateLimitUnits: {
      schema: {
        entityId: "EntityId",
        blockNumber: "uint256",
        rateLimitType: "RateLimitType",
        units: "uint128",
      },
      key: ["entityId", "blockNumber", "rateLimitType"],
    },
    // ------------------------------------------------------------
    // Player
    // ------------------------------------------------------------
    PlayerActivity: {
      schema: {
        player: "EntityId",
        deathCount: "uint256",
        activityType: "ActivityType",
        value: "uint256",
      },
      key: ["player", "deathCount", "activityType"],
    },
    Death: {
      schema: {
        player: "EntityId",
        deaths: "uint256",
        lastDiedAt: "uint128",
      },
      key: ["player"],
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
    Machine: {
      schema: {
        entityId: "EntityId",
        createdAt: "uint128",
        depletedTime: "uint128",
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
        notificationType: "NotificationType",
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
        isPaused: "bool",
      },
      key: [],
    },
    Guardians: {
      schema: {
        guardian: "address",
        isGuardian: "bool",
      },
      key: ["guardian"],
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

    // DEPRECATED: replaced by RateLimitUnits
    MoveUnits: {
      schema: {
        entityId: "EntityId",
        blockNumber: "uint256",
        units: "uint128",
      },
      key: ["entityId", "blockNumber"],
    },
  },
  systems: {
    // This system is only used during development and is not deployed on mainnet
    DebugSystem: {
      deploy: {
        disabled: true,
      },
    },
  },
});
