## Attaching Programs to Entities

To attach a program to an entity:

1. **Find Program ID**: Get the resource ID of the registered system. The easiest way to find it is to look in the MUD codegenerated system library. For example, [this is where you would find the resource ID of the default program](https://github.com/dustproject/dust/blob/6ad697a45c99ee3418196968b01cc38c73626aec/packages/programs/src/codegen/systems/DefaultProgramSystemLib.sol#L21).
2. **Be in proximity**: Move close to the smart entity with a player that has access to upgrade the smart entity's program. By default the player who placed the smart entity has access to update its program.
3. **Find the smart entity's ID**: The easiest way to find it is to right click the smart entity in the client to open its UI, then click on the small square next to the window title. From there you can select the truncated hex after "Entity" (i.e. `Entity: 0x0300...0000`) and press CTRL+C to copy it. Despite the truncation, it will copy the entire ID.
   ![EntityId](/smart-entity-id.png)
4. **Call the `world.updateProgram` function**: You need to call it from the account of the player standing close to the smart entity. The easiest way to do this is to connect the player's account to the [MUD World Explorer and call the function from there](https://explorer.mud.dev/redstone/worlds/0x253eb85B3C953bFE3827CC14a151262482E7189C/interact?expanded=root%2C0x7379000000000000000000000000000050726f6772616d53797374656d000000&filter=updatePro#0x7379000000000000000000000000000050726f6772616d53797374656d000000-0x843bb3c7cebac75f0b0ba241960c28d7148f695cb075442ee297284be1b22360).

```solidity
world.updateProgram(
  entityId,    // ID of the smart entity, i.e. chest
  programId,   // MUD system ID of the program
  ""           // optional extra data
);
```
