import dustConfig from "@dust/world/mud.config";
import { getRecord } from "@latticexyz/store/internal";
import type { Address, Client } from "viem";
import type { EntityId, ProgramId } from "../common";

export async function getEntityProgram({
  client,
  worldAddress,
  entity,
}: {
  client: Client;
  worldAddress: Address;
  entity: EntityId;
}): Promise<ProgramId | undefined> {
  const { program } = await getRecord(client, {
    address: worldAddress,
    table: dustConfig.tables.EntityProgram,
    key: { entityId: entity },
  });
  if (/^0x0*$/.test(program)) return;
  return program;
}
