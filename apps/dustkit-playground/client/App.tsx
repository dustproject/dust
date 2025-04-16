import { Messenger } from "dustkit";
import { useEffect, useState } from "react";

export function App() {
  const [iframe, setIframe] = useState<HTMLIFrameElement>();

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

    return () => {
      bridge.destroy();
    };
  }, [iframe]);

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
