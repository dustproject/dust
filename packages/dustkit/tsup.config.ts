import { defineConfig } from "tsup";
import { baseConfig } from "../../tsup.config.base";

export default defineConfig((opts) => ({
  ...baseConfig(opts),
  entry: [
    "mud.config.ts",
    "src/exports/index.ts",
    "src/exports/internal.ts",
    "out/IAppConfigURI.sol/IAppConfigURI.abi.ts",
  ],
}));
