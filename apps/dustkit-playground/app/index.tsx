import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { type AppSchema, createMessagePortRpcServer } from "dustkit/internal";
import { MethodNotSupportedError } from "ox/RpcResponse";
import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { WagmiProvider } from "wagmi";
import { App } from "./App";
import { wagmiConfig } from "./wagmiConfig";

const queryClient = new QueryClient();

const root = ReactDOM.createRoot(document.querySelector("#react-root")!);
root.render(
  <StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    </WagmiProvider>
  </StrictMode>,
);

createMessagePortRpcServer<AppSchema>({
  async onRequest({ method, params }) {
    if (method === "dustApp_init") {
      console.info("client asked this app to initialize with", params);
      return;
    }

    throw new MethodNotSupportedError({
      message: `"${method}" not supported.`,
    });
  },
});
