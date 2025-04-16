import { useEffect } from "react";
import { dustBridge } from "./dust";

export function App() {
  useEffect(() => {
    dustBridge.ready();
    dustBridge.on("app:open", ({ appConfig, via }) => {
      console.info("client opened app", appConfig, "via", via);
    });
  }, []);

  return (
    <div>
      <h1>App</h1>
    </div>
  );
}
