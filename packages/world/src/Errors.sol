// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EntityId } from "./types/EntityId.sol";
import { ObjectType } from "./types/ObjectType.sol";
import { Vec3 } from "./types/Vec3.sol";

// General errors
error InvalidWorldAddress(address provided);
error AmountMustBePositive(uint256 amount);
error InvalidSlot(uint16 slot);
error EmptySlot(EntityId owner, uint16 slot);
error NotEnoughEnergy(uint32 required, uint32 available);
error DivisionByZero();

// Entity errors
error EntityDoesNotExist(EntityId entityId);
error EntityHasNoObjectType(EntityId entityId);
error EntityIsNotPlayer(EntityId entityId);
error EntityMustExist(EntityId entityId);
error EntityHasNoEnergy(EntityId entityId);
error EntityIsNotBlock(EntityId entityId);
error EntityIsNotFragment(EntityId entityId);
error PlayerAlreadySpawned(EntityId player);
error PlayerIsSleeping(EntityId player);
error PlayerIsNotDead(EntityId player);
error PlayerNotInBed(EntityId player);

// Transfer and inventory errors
error CallerNotInvolvedInTransfer(EntityId caller, EntityId from, EntityId to);
error CannotAccessAnotherPlayerInventory(ObjectType targetType);
error CannotTransferToPassThrough(ObjectType targetType);
error CannotTransferAllToSelf(EntityId entity);
error CannotTransferAmountsToSelf(EntityId entity);
error CannotStoreDifferentObjectTypes(ObjectType existing, ObjectType newType);
error CannotAdd0ObjectsToSlot();
error EntityTransferAmountMustBe1(uint16 amount);
error NotAnEntity(EntityId entityId);
error NotEnoughObjects(ObjectType objectType, uint16 required, uint16 available);
error NotEnoughObjectsInSlot(uint16 slot, uint16 required, uint16 available);
error ObjectDoesNotFitInSlot(uint16 amount, uint16 stackable);
error ObjectTypeCannotBeAddedToInventory(ObjectType objectType);
error SlotExceedsMaxInventory(uint16 slot, uint16 max);
error SlotMustBeEmpty(uint16 slot);
error InventoryIsFull(EntityId owner);

// Build errors
error CanOnlyBuildOnAirOrWater(ObjectType currentType);
error CannotBuildNonBlock(ObjectType objectType);
error CannotBuildOnMovableEntity(EntityId entity);
error CannotBuildOnWaterWithNonWaterloggable(ObjectType objectType);
error CannotBuildWhereDroppedObjects(Vec3 coord);
error CannotJumpBuildOnPassThrough(ObjectType objectType);
error CannotPlantOnThisBlock(ObjectType baseBlock);
error ForceFieldOverlapsWithAnother(EntityId existingForceField);

// Drop and pickup errors
error MustDropAtLeastOneObject();
error CannotDropOnNonPassableBlock(ObjectType objectType);
error CannotPickupFromNonPassableBlock(ObjectType objectType);

// Spawn and bed errors
error NotABed(ObjectType objectType);
error BedFull(EntityId bed);
error BedNotInsideForceField(EntityId bed);
error NotASpawnTile(ObjectType objectType);
error CannotSpawnInForceField(EntityId forceField);
error CannotSpawnHereGravityApplies(Vec3 coord);
error CannotSpawnOnNonPassableBlock(ObjectType objectType);
error CannotSpawnWithMoreThan30PercentEnergy(uint32 energy);
error SpawnTileNotInsideForceField(EntityId spawnTile);
error NotEnoughEnergyInSpawnTile(uint32 required, uint32 available);
error SpawnTileTooFarAway(Vec3 spawnTileCoord, Vec3 spawnCoord);
error BedTooFarAway(Vec3 bedCoord, Vec3 spawnCoord);
error DropLocationTooFarFromBed(Vec3 dropCoord, Vec3 bedCoord);
error NoSurfaceChunksAvailable();

// Movement errors
error NewCoordTooFarFromOld(Vec3 oldCoord, Vec3 newCoord);
error CannotMoveThroughPlayer(EntityId player);
error CannotJumpMoreThan3Blocks(uint256 jumps);
error CannotGlideMoreThan10Blocks(uint256 glides);
error MoveLimitExceeded(uint256 moveUnits);
error EntityIsTooFar(Vec3 entityCoord, Vec3 targetCoord);
error FragmentIsTooFar(Vec3 fragmentCoord, Vec3 targetCoord);

// Tool and craft errors
error MustEquipHoe(ObjectType equippedType);
error NotTillable(ObjectType objectType);
error NotWater(ObjectType objectType);
error NotFarmland(ObjectType objectType);
error MustUseBucket(ObjectType objectType);
error MustUseWaterBucket(ObjectType objectType);
error ObjectIsNotFood(ObjectType objectType);
error RecipeNotFound(ObjectType outputType);
error InvalidStation(ObjectType requiredStation, ObjectType providedStation);
error InputAmountExceedsRemaining(uint16 amount, uint16 remaining);
error InputAmountMustBePositive();
error InputTypeDoesNotMatchRecipe(ObjectType required, ObjectType provided);
error NotEnoughInputsForRecipe(uint256 required, uint256 provided);
error InventoryItemIsNotTool(ObjectType objectType);
error ToolIsBroken(uint16 toolState);

// Machine and force field errors
error CanOnlyFuelMachines(ObjectType objectType);
error MustProvideAtLeastOneSlot();
error SlotIsNotFuel(ObjectType slotType);
error NoForceFieldAtLocation(Vec3 coord);
error CannotHitDepletedForceField(uint32 energyLeft);
error InvalidObjectType(ObjectType expected, ObjectType actual);
error ReferenceFragmentNotPartOfForceField(EntityId forceField, Vec3 fragmentCoord);
error CannotRemoveForceFieldFragment(Vec3 forceFieldFragment, Vec3 fragment);
error FragmentNotPartOfForceField(EntityId forceField, EntityId fragment);
error NoBoundaryFragmentsFound();
error InvalidSpanningTree();
error CannotExpandIntoFragmentWithProgram(EntityId fragment);
error CannotRemoveFragmentWithProgram(EntityId fragment);
error FragmentMustNotHaveExtraDrainRate(uint32 drainRate);
error FragmentAlreadyBelongsToForceField(EntityId fragment, EntityId forceField);

// Program errors
error ExistingProgramMustBeDetached(EntityId target);
error NoProgramAttached(EntityId target);
error TargetIsNotSmartEntity(ObjectType targetType);
error ProgramDoesNotExist(address programAddress);
error ProgramSystemMustBePrivate(bool publicAccess);

// Guardian errors
error AddressAlreadyGuardian(address guardian);
error AddressNotGuardian(address guardian);

// Mining errors
error ObjectIsNotMineable(ObjectType objectType);
error CannotMineWithEnergyRemaining(uint32 energy);
error CannotMineForceFieldWithSleepingPlayers(uint32 drainRate);

// Nature and chunk errors
error NotGrowable(ObjectType objectType);
error SeedCannotBeGrownYet(uint256 fullyGrownAt, uint256 currentTime);
error EntityTooFarToCommit(Vec3 callerChunkCoord, Vec3 chunkCoord);
error ExistingChunkCommitment(uint256 existingCommitment);
error NoResourcesAvailableForRespawn(uint32 burnedCount);
error ResourceCoordinateIsNotAir(ObjectType objectType);
error CannotRespawnWhereDroppedObjects(EntityId entityId);
error ChunkAlreadyExplored(Vec3 chunkCoord);
error EnergyPoolChunksAre2DOnly(int16 yCoord);
error RegionEnergyAlreadyExplored(Vec3 regionCoord);
error RegionNotSeeded(Vec3 regionCoord);
error InvalidMerkleProof();
error ChunkNotExploredYet(Vec3 chunkCoord);
error ChunkCommitmentExpired();
error NotEnoughSeedsInCirculation(uint32 required, uint32 available);
error NotWithinCommitmentBlocks(uint256 blockNumber, uint256 commitmentBlock);
error UnsupportedChunkEncodingVersion(uint16 version, uint16 expected);

// Access control errors
error CallerNotAllowed(EntityId caller);
error ActionNotAllowed(EntityId entity);

// Energy errors
error CannotDecrease0Energy();
error NotEnoughEnergyInLocalPool(uint32 required, uint32 available);
error InvalidLastDepletedTime(uint256 lastDepletedTime);

// Other errors
error NoOptionsAvailable();
error DustIsPaused();
error OrientationNotSupported(uint8 orientationVal);

// Debug errors (only for debug system)
error DebugSystemOnlyInDevEnv(uint256 chainId);
error ToAddToolUseDebugAddToolToInventory(ObjectType objectType);
error CannotTeleportHereGravityApplies(Vec3 coord);
error CannotTeleportToNonPassableBlock(ObjectType objectType);
error CannotTeleportWherePlayerExists(EntityId existingPlayer);

// Test-specific errors
error NotAllowedByProgram();
error NotAllowedByForceField();
error NotAllowedByForceFieldFragment();
error TransferNotAllowedByChest();

// Revert helpers
error EntityNotFound(EntityId entityId);
error ObjectTypeNotFound(EntityId entityId, ObjectType objectType);
