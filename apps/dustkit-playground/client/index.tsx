import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { App } from "./App";
import { Providers } from "./Providers";

const root = ReactDOM.createRoot(document.querySelector("#react-root")!);
root.render(
  <StrictMode>
    <Providers>
      <App />
    </Providers>
  </StrictMode>,
);
