## Programs

```
insert diagram
```

Programs can read from the world and influence it via smart objects.

The state of the world is stored in MUD tables. You can see the full list of tables on the mud.config.

To read the tables in a smart contract, you import the table library and then pass in the keys. To read the tables in an app/script, you can call a getter or use an indexer (eg. MUD stash).

Programs can be attached to smart objects in the world (eg chests, force fields), and the world will call your program for certain interactions.

Smart contract programs deployed to the DUST world will automatically show up in the explorer. You can also register a custom UI for your program in 3 different places:

- sidebar: a list of global apps
- spawn screen: a list of apps shown on the spawn screen
- when interacting with smart items: shown when a user interacts with a smart object with your program attached
