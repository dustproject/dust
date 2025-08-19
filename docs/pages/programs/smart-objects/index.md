# Smart Objects

Programs can be attached to smart objects in the world (eg chests, force fields), and the world will call your program for certain interactions.

## Core Concepts

Programs in this architecture are defined by several key abstractions:

- **ProgramId**: A unique identifier that references a specific program implementation (the underlying value is a MUD `ResourceId`)
- **EntityId**: A unique identifier for entities within the world (ForceFields, Chests, etc)
- **Program**: Smart contracts (MUD systems) which can be attached to specific entities to define their behavior

### ProgramId and Resource Management

The `ProgramId` type serves as the fundamental reference to program implementations. It is defined as:

```solidity
type ProgramId is bytes32;
```

Programs are registered as systems within the MUD framework, and `ProgramId`s encode the corresponding `ResourceId` of the system.

### Program Attachment and Validation

The `ProgramSystem` contract manages the attachment and detachment of programs to entities:

```solidity
function attachProgram(EntityId caller, EntityId target, ProgramId program, bytes calldata extraData) public {
  // Validation logic
  // ...

  EntityProgram._set(target, program);

  program.callOrRevert(abi.encodeCall(IAttachHook.onAttachProgram, (caller, target, extraData)));

  // Notification logic
  // ...
}

function detachProgram(EntityId caller, EntityId target, bytes calldata extraData) public {
  // Validation logic
  // ...

  ProgramId program = target.getProgram();

  bytes memory onDetachProgram = abi.encodeCall(IDetachProgramHook.onDetachProgram, (caller, target, extraData));

  (EnergyData memory machineData, ) = updateMachineEnergy(forceField);
  if (machineData.energy > 0) {
    program.callOrRevert(onDetachProgram);
  } else {
    program.call({ gas: SAFE_PROGRAM_GAS, hook: onDetachProgram });
  }

  EntityProgram._deleteRecord(target);

  // Notification logic
  // ...
}
```

A key aspect of program attachment is the validation process. Before a program can be attached to an entity, it must pass validation checks:

1. The program must be registered as a private system
2. If the entity being programmed is within an active ForceField, the forcefield's program `validateProgram` hook must accept the attachment
3. The program itself must accept the attachment through the `onAttachProgram` hook

This multi-layered validation ensures that only appropriate programs can be attached to entities, maintaining the integrity of the world.

### Gas Safety Mechanisms

To prevent malicious or poorly implemented programs from consuming excessive gas, calls with a fixed amount of gas are used. Safe calls are only used for hooks that correspond to actions that the entity might be incentivized to prevent (e.g. `onHit`).

The `SAFE_PROGRAM_GAS` constant (set to 1,000,000 gas units) limits the gas available to safe program calls, preventing the program from consuming all the gas available in the transaction.

## Program Execution in Context

### Machine Interactions

Programs can respond to interactions with machines, such as when a player fuels a machine:

```solidity
function fuelMachine(EntityId callerEntityId, EntityId machineEntityId, uint16 fuelAmount) public {
  // Validation and fuel logic
  // ...

  // Call program hook
  ProgramId program = baseEntityId.getProgram();
  program.callOrRevert(abi.encodeCall(IFuelHook.onFuel, (callerEntityId, baseEntityId, fuelAmount, "")));

  // Notification logic
  // ...
}
```

This allows machines to execute custom logic when they receive fuel, potentially triggering complex behaviors or state changes.
