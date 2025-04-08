import { getRecord } from "@latticexyz/store/internal";
import metadataConfig from "@latticexyz/world-module-metadata/mud.config";
import { type Address, type Client, hexToString, stringToHex } from "viem";
import type { ProgramId } from "../common";

// TODO: add data URI support (currently assumes URL)

export async function getProgramDefaultAppConfigUrl({
  client,
  worldAddress,
  program,
}: {
  client: Client;
  worldAddress: Address;
  program: ProgramId;
}): Promise<string | undefined> {
  const { value } = await getRecord(client, {
    address: worldAddress,
    table: metadataConfig.tables.metadata__ResourceTag,
    key: {
      resource: program,
      tag: stringToHex("dust.defaultAppConfigURI", { size: 32 }),
    },
  });
  if (/^0x0*$/.test(value)) return;
  return hexToString(value);
}
