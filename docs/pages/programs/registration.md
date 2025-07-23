## Attaching Programs to Entities

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
