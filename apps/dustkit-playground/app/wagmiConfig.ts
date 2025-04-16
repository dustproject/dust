import { http, type Chain } from "viem";
import { anvil } from "viem/chains";
import { createConfig } from "wagmi";

const chains = [anvil] as const satisfies Chain[];

const transports = {
  [anvil.id]: http(),
} as const;

export const wagmiConfig = createConfig({
  chains,
  transports,
  pollingInterval: {
    [anvil.id]: 500,
  },
});
