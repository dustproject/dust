import { garnet, pyrope, redstone, rhodolite } from "@latticexyz/common/chains";
import { createWagmiConfig } from "@latticexyz/entrykit/internal";
import { http, type Transport, webSocket } from "viem";
import { anvil } from "viem/chains";
import { chains } from "./chains";
import { chainId } from "./common";

export const transports = {
  [anvil.id]: webSocket(),
  [garnet.id]: http(),
  [pyrope.id]: http(),
  [rhodolite.id]: http(),
  [redstone.id]: http(),
} as const satisfies {
  readonly [k in keyof chains & number as chains[k]["id"]]: Transport;
};

export const wagmiConfig = createWagmiConfig({
  chainId,
  walletConnectProjectId: "7ad4437df68026a6f50453161f29b8c6",
  appName: document.title,
  chains,
  transports,
  pollingInterval: {
    [anvil.id]: 2000,
    [garnet.id]: 2000,
    [pyrope.id]: 2000,
    [rhodolite.id]: 2000,
    [redstone.id]: 2000,
  },
});
