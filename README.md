# DUST

Dust is our serious attempt at seeding an autonomous world.

## DUST is live on Redstone mainnet, but still in alpha.

What you create in Dust is real and permanent. The map and your progress won’t be reset.

However, Dust is still in alpha and focused on balancing and stability. Some parts of the system may evolve, but always with full transparency and a clear path toward decentralization.

🔒 **Things that will not change anymore:**

- The current map, both natural terrain and structures created by players.
- The number of items in your inventory and chests.
- The world contract address. If systems within the world are updated, their interfaces will be backwards compatible, so your programs don’t break.

🚧 **Things that may change during alpha:**

- Balancing changes, i.e. cost or requirements of actions, block mass, drop probabilities.
- Introduction of new game systems or items.
- Bug fixes and stability improvements.
- Map extensions beyond the current borders.

The goal of all changes is to put Dust on the path of autonomy. Changes will be communicated in advance and can be followed in this repository. The changelog includes a historical log of changes since the mainnet deployment.

Once the world is sufficiently stable, we will decentralize governance and let Dust stand on its own.

## Repository structure

This repository includes the core physics contracts of the Dust protocol, a client SDK to extend the functionality of the default Dust browser client, as well as examples for programs (onchain) and apps (browser).

```
.
├── packages
│   ├── world              // the core physics contracts
│   ├── programs           // default programs installed on entities
│   └── dustkit            // client SDK to built apps in Dust
└── apps
    ├── dustkit-playground // a playground to iterate on apps with dustkit
    └── player-position    // an example app
```

To understand the relationship between programs and apps, have a look at [PROGRAMS.md](./PROGRAMS.md).

## Relevant links

- [Dust discord](https://dustproject.org/discord)
- [Dust landing page](https://dustproject.org)
- [Dust learning resources](https://dustproject.org/learn)
- [Dust browser client](https://alpha.dustproject.org) ([join discord to get access](https://dustproject.org/access))
- [Dust explorer](https://dustproject.org/explorer)
