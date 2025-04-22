import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import { mud } from "vite-plugin-mud";

export default defineConfig({
  plugins: [react(), mud({ worldsFile: "../../packages/world/worlds.json" })],
});
