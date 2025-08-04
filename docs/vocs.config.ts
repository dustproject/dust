import { defineConfig } from "vocs";

export default defineConfig({
  title: "DUST",
  rootDir: "./",
  iconUrl: "/dust.png",
  logoUrl: "/dust.png",
  ogImageUrl: "/dust.png",
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
