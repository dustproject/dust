# Reference

## Force field

### `onValidateProgram`

Called before attaching a program to an entity in the force field.
Can revert to prevent attaching the program.

```solidity
struct ValidateProgramContext {
  EntityId caller;
  EntityId target;
  EntityId programmed;
  ProgramId program;
  bytes extraData;
}

interface IProgramValidator {
  function validateProgram(ValidateProgramContext calldata ctx) external view;
}
```

### `onAttachProgram`

```solidity
struct AttachProgramContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

interface IAttachProgram {
  function onAttachProgram(AttachProgramContext calldata ctx) external;
}
```

### `onDetachProgram`

```solidity
struct DetachProgramContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

interface IDetachProgram {
  function onDetachProgram(DetachProgramContext calldata ctx) external;
}
```

### `onHit`

```solidity
struct HitContext {
  EntityId caller;
  EntityId target;
  uint128 damage;
  bytes extraData;
}

interface IHit {
  function onHit(HitContext calldata ctx) external;
}
```

### `onFuel`

```solidity
struct FuelContext {
  EntityId caller;
  EntityId target;
  uint16 fuelAmount;
  bytes extraData;
}

interface IFuel {
  function onFuel(FuelContext calldata ctx) external;
}
```

### `onAddFragment`

```solidity
struct AddFragmentContext {
EntityId caller;
EntityId target;
EntityId added;
bytes extraData;
}

interface IAddFragment {
function onAddFragment(AddFragmentContext calldata ctx) external;
}
```

### `onRemoveFragment`

```solidity
struct RemoveFragmentContext {
EntityId caller;
EntityId target;
EntityId removed;
bytes extraData;
}

interface IRemoveFragment {
function onRemoveFragment(RemoveFragmentContext calldata ctx) external;
}
```

### `onBuild`

```solidity
struct BuildContext {
EntityId caller;
EntityId target;
ObjectType objectType;
Vec3 coord;
bytes extraData;
}

interface IBuild {
function onBuild(BuildContext calldata ctx) external;
}
```

### `onMine`

```solidity
struct MineContext {
EntityId caller;
EntityId target;
ObjectType objectType;
Vec3 coord;
bytes extraData;
}

interface IMine {
function onMine(MineContext calldata ctx) external;
}
```

## Chest

### `onTransfer`

```solidity
struct TransferContext {
  EntityId caller;
  EntityId target;
  SlotData[] deposits;
  SlotData[] withdrawals;
  bytes extraData;
}

interface ITransfer {
  function onTransfer(TransferContext calldata ctx) external;
}
```

## Spawn tile

### `onSpawn`

```solidity
struct SpawnContext {
  EntityId caller;
  EntityId target;
  uint128 spawnEnergy;
  bytes extraData;
}

interface ISpawn {
  function onSpawn(SpawnContext calldata ctx) external;
}
```

## Bed

### `onSleep`

```solidity
struct SleepContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

interface ISleep {
  function onSleep(SleepContext calldata ctx) external;
}
```

### `onWakeup`

```solidity
struct WakeupContext {
  EntityId caller;
  EntityId target;
  bytes extraData;
}

interface IWakeup {
  function onWakeup(WakeupContext calldata ctx) external;
}
```
