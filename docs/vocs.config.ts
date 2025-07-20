import { defineConfig } from "vocs";

export default defineConfig({
  title: "DUST",
  rootDir: "./",
  sidebar: [
    {
      text: "Programs (contracts)",
      items: [
        { text: "Introduction", link: "/programs" },
        { text: "Registration", link: "/programs/registration" },
        { text: "Reference", link: "/programs/reference" },
      ],
    },
    {
      text: "Apps (client)",
      items: [
        { text: "Introduction", link: "/apps" },
        { text: "Registration", link: "/apps/registration" },
        { text: "Dustkit", link: "/apps/dustkit" },
      ],
    },
    {
      text: "Examples",
      items: [
        { text: "Swap chest", link: "/examples/swap-chest" },
        { text: "Blueprint", link: "/examples/blueprint" },
        { text: "Spawn tile", link: "/examples/spawn-tile" },
      ],
    },
  ],
});
