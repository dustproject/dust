import { Messenger } from "dustkit";
import { useEffect, useState } from "react";
import { useConfig } from "wagmi";
import { getConnectorClient } from "wagmi/actions";

export function App() {
  const [iframe, setIframe] = useState<HTMLIFrameElement>();
  const wagmiConfig = useConfig();

  useEffect(() => {
    if (!iframe) return;
    if (!iframe.contentWindow) {
      console.warn("no content window for iframe, skipping bridge", iframe);
      return;
    }

    const bridge = Messenger.bridge({
      from: Messenger.fromWindow(window),
      to: Messenger.fromWindow(iframe.contentWindow),
      waitForReady: true,
    });

    bridge.send("app:open", {
      appConfig: {
        name: "DustKit app",
        startUrl: "/",
      },
    });

    bridge.on("client:rpcRequests", async (requests, reply) => {
      console.info("got requests", requests);
      const connectorClient = await getConnectorClient(wagmiConfig);
      const responses = await Promise.all(
        requests.map(async (request) =>
          connectorClient.transport.request(request),
        ),
      );
      console.info("replying with", responses);
      reply(responses);
    });

    return () => {
      bridge.destroy();
    };
  }, [iframe, wagmiConfig]);

  return (
    <div>
      <h1>Client</h1>
      <iframe
        title="DustKit app"
        src={import.meta.env.VITE_DUSTKIT_APP_URL}
        onLoad={(event) => setIframe(event.currentTarget)}
      />
    </div>
  );
}
