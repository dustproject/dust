# DUST

DUST is our serious attempt at seeding an [autonomous world](https://0xparc.org/blog/autonomous-worlds).

## DUST is live on DUST mainnet, but still in alpha.

What you create in DUST is real and permanent. The map and your progress won’t be reset.

However, DUST is still in alpha and focused on balancing and stability. Some parts of the system may evolve, but always with full transparency and a clear path toward decentralization.

🔒 **Things that will not change anymore:**

- The current map, both natural terrain and structures created by players.
- The number of items in your inventory and chests.
- The world contract address. If systems within the world are updated, their interfaces will be backwards compatible, so your programs don’t break.

🚧 **Things that may change during alpha:**

- Balancing changes, i.e. cost or requirements of actions, block mass, drop probabilities.
- Introduction of new game systems or items.
- Bug fixes and stability improvements.
- Map extensions beyond the current borders.

The goal of all changes is to put DUST on the path of autonomy. Changes will be communicated in advance and can be followed in this repository. The [changelog](https://github.com/dustproject/dust/blob/main/CHANGELOG.md) includes a historical log of changes since the mainnet deployment.

Once the world is sufficiently stable, we will decentralize governance and let DUST stand on its own.

## Repository structure

This repository includes the core physics contracts of the DUST protocol, a client SDK to extend the functionality of the default DUST browser client, as well as examples for programs (onchain) and apps (browser).

```
.
├── packages
│   ├── world              // the core physics contracts
│   ├── programs           // default programs installed on entities
│   └── dustkit            // client SDK to build apps in DUST
└── apps
    └── dustkit-playground // a playground to iterate on apps with dustkit
```

To understand the relationship between programs and apps, have a look at [PROGRAMS.md](./PROGRAMS.md).

## Relevant links

- [Discord](https://dustproject.org/discord)
- [Landing page](https://dustproject.org)
- [Learning resources](https://dustproject.org/what)
- [Browser client](https://alpha.dustproject.org)
- [Explorer](https://dustproject.org/explorer)
