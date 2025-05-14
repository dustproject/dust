import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { Game } from "./Game";
import { Providers } from "./Providers";

const root = ReactDOM.createRoot(document.querySelector("#react-root")!);
root.render(
  <StrictMode>
    <Providers>
      <Game />
    </Providers>
  </StrictMode>,
);
