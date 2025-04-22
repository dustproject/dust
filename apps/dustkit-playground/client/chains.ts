import { garnet, pyrope, redstone, rhodolite } from "@latticexyz/common/chains";
import type { Chain } from "viem";
import { anvil } from "viem/chains";

export const chains = [
  redstone,
  garnet,
  pyrope,
  rhodolite,
  {
    ...anvil,
    contracts: {
      ...anvil.contracts,
      paymaster: {
        address: "0xf03E61E7421c43D9068Ca562882E98d1be0a6b6e",
      },
    },
    blockExplorers: {
      default: {} as never,
      worldsExplorer: {
        name: "MUD Worlds Explorer",
        url: "http://localhost:13690/anvil/worlds",
      },
    },
  },
] as const satisfies readonly [Chain, ...Chain[]];

export type chains = typeof chains;
