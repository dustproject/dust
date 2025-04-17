import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createMessagePortRpcServer } from "dustkit/internal";
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

createMessagePortRpcServer({
  async onRequest(req) {
    console.info("got rpc request", req);
    return {
      jsonrpc: req.jsonrpc,
      id: req.id,
      result: "hello",
    };
  },
});
