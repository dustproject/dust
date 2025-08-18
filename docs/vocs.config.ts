import { defineConfig } from "vocs";

export default defineConfig({
  title: "DUST",
  rootDir: "./",
  iconUrl: "/dust.png",
  logoUrl: "/dust.png",
  ogImageUrl: "/dust.png",
  sidebar: [
    {
      text: "Overview",
      items: [{ text: "Introduction", link: "/" }],
    },
    {
      text: "Programs",
      items: [
        { text: "Introduction", link: "/programs" },
        { text: "Reading The World", link: "/programs/reading-the-world" },
        { text: "Smart Objects", link: "/programs/smart-objects" },
        { text: "Custom UIs", link: "/programs/custom-uis" },
      ],
    },
    {
      text: "Bots",
      items: [
        { text: "Introduction", link: "/bots" },
        { text: "Browser Console", link: "/bots/console" },
        { text: "Scripts", link: "/bots/scripts" },
        { text: "FAQ", link: "/bots/faq" },
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
  socials: [
    {
      icon: "github",
      link: "https://github.com/dustproject/dust",
    },
    {
      icon: "discord",
      link: "https://discord.gg/QFsFhehfhS",
    },
    {
      icon: "x",
      link: "https://x.com/Dust_Org",
    },
  ],
});
