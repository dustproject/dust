import {
  ChainNotConfiguredError,
  type Connector,
  createConnector,
} from "@wagmi/core";
import type { Provider } from "ox/Provider";
import { SwitchChainError, getAddress, hexToNumber, numberToHex } from "viem";
import type { Bridge } from "../apps/Messenger";
import { createProvider } from "./provider";

export type ConnectorConfig = {
  bridge: Bridge;
};

export function connector(config: ConnectorConfig) {
  return createConnector<Provider>((wagmiConfig) => {
    const provider = createProvider(config);

    let accountsChanged: Connector["onAccountsChanged"] | undefined;
    let chainChanged: Connector["onChainChanged"] | undefined;
    let disconnect: Connector["onDisconnect"] | undefined;

    return {
      id: "dustkit",
      name: "DustKit",
      // TODO: rdns
      // TODO: icon
      type: "injected",

      async connect({ chainId } = {}) {
        const provider = await this.getProvider();
        const accounts = await provider.request({
          method: "eth_requestAccounts",
        });

        if (!accountsChanged) {
          accountsChanged = this.onAccountsChanged.bind(this);
          // @ts-expect-error provider event arg is stricter
          provider.on("accountsChanged", accountsChanged);
        }
        if (!chainChanged) {
          chainChanged = this.onChainChanged.bind(this);
          provider.on("chainChanged", chainChanged);
        }
        if (!disconnect) {
          disconnect = this.onDisconnect.bind(this);
          provider.on("disconnect", disconnect);
        }

        let currentChainId = await this.getChainId();
        if (chainId && currentChainId !== chainId) {
          const chain = await this.switchChain!({ chainId });
          currentChainId = chain.id;
        }

        return {
          accounts: accounts.map((x) => getAddress(x)),
          chainId: currentChainId,
        };
      },
      async disconnect() {
        const provider = await this.getProvider();

        if (accountsChanged) {
          // @ts-expect-error provider event arg is stricter
          provider.removeListener("accountsChanged", accountsChanged);
          accountsChanged = undefined;
        }

        if (chainChanged) {
          provider.removeListener("chainChanged", chainChanged);
          chainChanged = undefined;
        }

        if (disconnect) {
          provider.removeListener("disconnect", disconnect);
          disconnect = undefined;
        }
      },
      async getAccounts() {
        const provider = await this.getProvider();
        const accounts = await provider.request({
          method: "eth_accounts",
        });
        return accounts.map((x) => getAddress(x));
      },
      async getChainId() {
        const provider = await this.getProvider();
        const hexChainId = await provider.request({ method: "eth_chainId" });
        return hexToNumber(hexChainId);
      },
      async isAuthorized() {
        try {
          const accounts = await this.getAccounts();
          return !!accounts.length;
        } catch {
          return false;
        }
      },
      async switchChain({ chainId }) {
        const chain = wagmiConfig.chains.find((x) => x.id === chainId);
        if (!chain) {
          throw new SwitchChainError(new ChainNotConfiguredError());
        }

        const provider = await this.getProvider();
        await provider.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: numberToHex(chainId) }],
        });

        return chain;
      },
      onAccountsChanged(accounts) {
        if (accounts.length === 0) {
          this.onDisconnect();
        } else {
          wagmiConfig.emitter.emit("change", {
            accounts: accounts.map((x) => getAddress(x)),
          });
        }
      },
      onChainChanged(chain) {
        const chainId = Number(chain);
        wagmiConfig.emitter.emit("change", { chainId });
      },
      async onDisconnect() {
        wagmiConfig.emitter.emit("disconnect");
      },
      async getProvider() {
        return provider;
      },
    };
  });
}
