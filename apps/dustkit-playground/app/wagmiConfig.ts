import { connector } from "dustkit/internal";
import { http, type Chain } from "viem";
import { anvil } from "viem/chains";
import { createConfig } from "wagmi";
import { dustBridge } from "./dust";

const chains = [anvil] as const satisfies Chain[];

const transports = {
  [anvil.id]: http(),
} as const;

export const wagmiConfig = createConfig({
  chains,
  transports,
  connectors: [connector({ bridge: dustBridge })],
  pollingInterval: {
    [anvil.id]: 500,
  },
});
