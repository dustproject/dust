import type { AppConfig } from "dustkit";
import { type AppRpcSchema, getMessagePortProvider } from "dustkit/internal";
import type { Address, Hex } from "viem";
import { useAccount } from "wagmi";

let nextAppId = 0;

export function AppPane() {
  const { address: userAddress } = useAccount();

  const url = new URL(
    import.meta.env.VITE_DUSTKIT_APP_URL,
    window.location.href,
  );

  return (
    <iframe
      title="DustKit app"
      src={url.toString()}
      onLoad={async (event) => {
        const appId = `app:${++nextAppId}`;

        if (!userAddress) {
          console.info("no user address, skipping app init");
          return;
        }

        console.info("setting up app provider");
        const target = event.currentTarget.contentWindow!;
        const appProvider = getMessagePortProvider<
          AppRpcSchema,
          {
            appId: string;
            appConfig: AppConfig;
            userAddress: Address;
            via?: {
              entity: Hex;
              program: Hex;
            };
          }
        >({
          target,
          targetOrigin: url.origin,
          context: {
            appId,
            appConfig: {
              name: "Playground",
              startUrl: "/",
            },
            userAddress,
          },
        });

        console.info("sending init");
        try {
          const res = await appProvider.request({
            method: "dustApp_init",
            params: {
              appConfig: {
                name: "Playground",
                startUrl: "/",
              },
              userAddress,
            },
          });
          if (target.closed) {
            console.info("ignoring reply after unmount", res);
            return;
          }
          console.info("got init reply", res);
        } catch (error) {
          if (target.closed) {
            console.info("ignoring error after unmount", error);
            return;
          }
          throw error;
        }
      }}
    />
  );
}
