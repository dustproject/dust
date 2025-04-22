import { EntryKitProvider, defineConfig } from "@latticexyz/entrykit/internal";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { WagmiProvider } from "wagmi";
import { chainId, getWorldAddress } from "./common";
import { wagmiConfig } from "./wagmiConfig";

const queryClient = new QueryClient();

export type Props = {
  children: ReactNode;
};

export function Providers({ children }: Props) {
  const worldAddress = getWorldAddress();
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <EntryKitProvider
          config={defineConfig({ chainId, worldAddress, theme: "dark" })}
        >
          {children}
        </EntryKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
