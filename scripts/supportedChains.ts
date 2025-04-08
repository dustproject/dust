import {
  garnet,
  mudFoundry,
  pyrope,
  redstone,
} from "@latticexyz/common/chains";

import type { Chain } from "viem";

/*
 * See https://mud.dev/tutorials/minimal/deploy#run-the-user-interface
 * for instructions on how to add networks.
 */
export const supportedChains: Chain[] = [mudFoundry, garnet, pyrope, redstone];
