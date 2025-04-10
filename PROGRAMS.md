# WIP Programs: A Comprehensive Analysis

## Abstract

This document provides an overview of the Programs architecture within the DUST smart contract ecosystem. Programs represent a powerful abstraction layer that enables dynamic behavior and programmable logic for entities within the virtual world. By leveraging the MUD framework's capabilities, Programs offer a flexible mechanism for extending entity functionality through custom logic that can respond to various in-world events. This document explains the concepts, implementation details and practical applications of Programs, serving as a practical guide for developers.

## 1. Introduction

In decentralized virtual worlds built on blockchain technology, the ability to create programmable objects with custom behaviors is essential for creating rich, interactive experiences. The Programs architecture in this project provides a framework for attaching custom logic to in-world entities, allowing them to respond to events, validate actions, and execute complex behaviors.

Programs function as an extension mechanism that separates an entity's data from its behavior, following principles similar to the Entity Component System (ECS) pattern. This separation enables dynamic composition of functionality and promotes code reuse across different entity types.

## 2. Framework

### 2.1 Core Concepts

Programs in this architecture are defined by several key abstractions:

- **ProgramId**: A unique identifier that references a specific program implementation (the underlying value is a MUD `ResourceId`)
- **EntityId**: A unique identifier for entities within the world (ForceFields, Chests, etc)
- **Program**: Smart contracts (MUD systems) which can be attached to specific entities to define their behavior

The relationship between these components creates a flexible framework where entities can have programmable behaviors that are triggered by in-world events.

### 2.2 Event-Driven Architecture

Programs follow an event-driven architecture where system contracts invoke program hooks in response to specific actions. This pattern allows for:

1. **Decoupling**: World systems and programs are loosely coupled, communicating through well-defined interfaces
2. **Extensibility**: New hooks can be added without modifying core systems
3. **Composability**: A program can be attached to different types of entities, and optionally implement the hooks related to those entity types

## 3. Implementation Details

### 3.1 ProgramId and Resource Management

The `ProgramId` type serves as the fundamental reference to program implementations. It is defined as:

```solidity
type ProgramId is bytes32;
```

Programs are registered as systems within the MUD framework, and `ProgramId`s encode the corresponding `ResourceId` of the system.

### 3.2 Program Hooks Interfaces

The `ProgramInterfaces.sol` file includes interfaces for all hooks and functions that a program can implement:

Each hook corresponds to a specific action or event within the world, allowing programs to respond accordingly. The hooks receive contextual information about the action, including the caller, target entity, and any additional data relevant to the event.

### 3.3 Program Attachment and Validation

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

### 3.4 Gas Safety Mechanisms

To prevent malicious or poorly implemented programs from consuming excessive gas, calls with a fixed amount of gas are used. Safe calls are only used for hooks that correspond to actions that the entity might be incentivized to prevent (e.g. `onHit`).

The `SAFE_PROGRAM_GAS` constant (set to 1,000,000 gas units) limits the gas available to safe program calls, preventing the program from consuming all the gas available in the transaction.


## 4. Program Execution in Context

### 4.1 Machine Interactions

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

## 5. Practical Applications

### 5.1 Smart Entities

Programs enable the creation of smart entities with custom behaviors:

- **Smart Doors**: Doors that only open for specific entities or under certain conditions
- **Resource Generators**: Machines that produce resources at regular intervals
- **Security Systems**: Force fields that restrict actions based on complex rules
- **Interactive NPCs**: Non-player characters with programmable behavior

### 5.2 Gameplay Mechanics

Programs can implement complex gameplay mechanics:

- **Quest Systems**: Programs that track player progress and reward completion
- **Economic Systems**: Trading posts with dynamic pricing algorithms
- **Combat Systems**: Custom combat mechanics for specific areas or entities
- **Crafting Systems**: Advanced crafting pipelines that reward resource providers and periodically craft specific items

### 5.3 World Governance

Programs can facilitate governance mechanisms:

- **Access Control**: Programs that manage permissions for different areas
- **Resource Management**: Systems that regulate resource distribution
- **Voting Systems**: Mechanisms for collective decision-making
- **Taxation Systems**: Automated collection and distribution of resources

## 6. Implementation Guide

### 6.1 Creating a Program (WIP)

Example of a simple door program:

```solidity
contract SimpleDoorProgram is Program {
  constructor(IWorld world) Program(world) {}

  function onAttach(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    address[] memory allowedPlayers = abi.decode(extraData, (address[]));

    // Logic to set the owner and the allowed players for the door
  }


  // Only implement the hooks you need
  function onOpen(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    // Check if caller is allowed to open the door
    // If not, revert the transaction
    if (!isAllowedToOpen(caller, target)) {
      revert("Access denied");
    }

    // Additional logic for successful opening
  }

  function onClose(EntityId caller, EntityId target, bytes memory extraData) external onlyWorld {
    // Logic for closing the door
  }

  // Helper function to check permissions
  function _isAllowedToOpen(EntityId caller, EntityId target) internal view returns (bool) {
    // Custom permission logic
  }
}
```

### 6.2 Attaching Programs to Entities

To attach a program to an entity:

1. **Obtain Program ID**: Get the resource ID of the registered system
2. **Call Attach Function**: Use the `ProgramSystem.attachProgram` function
3. **Provide Extra Data**: Include any initialization data needed by the program

Example:

```solidity
world.attachProgram(
  playerEntityId,  // caller
  doorEntityId,    // target
  doorProgramId,   // program
  abi.encode(allowedPlayers)  // extra data
);
```

## 7. Conclusion

The Programs architecture provides a powerful framework for creating dynamic, programmable entities within the virtual world. By separating entity data from behavior and leveraging an event-driven design, Programs enable complex interactions and emergent gameplay without requiring modifications to core systems.

This architecture opens up possibilities for user-generated content, complex gameplay mechanics, and evolving world dynamics. As the ecosystem grows, the Programs framework will enable increasingly sophisticated virtual experiences that blur the line between traditional games and open digital worlds.

## References

1. MUD Framework Documentation: [https://mud.dev/](https://mud.dev/)

