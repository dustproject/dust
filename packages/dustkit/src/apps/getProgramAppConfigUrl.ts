import { encodeSystemCall } from "@latticexyz/world/internal";
import type { Address, Client } from "viem";
import { readContract } from "viem/actions";
import appAbi from "../../out/IAppConfigURI.sol/IAppConfigURI.abi";
import worldCallAbi from "../../out/IWorldKernel.sol/IWorldCall.abi";
import type { EntityId, ProgramId } from "../common";

export async function getProgramAppConfigUrl({
  client,
  worldAddress,
  program,
  entity,
}: {
  client: Client;
  worldAddress: Address;
  program: ProgramId;
  entity?: EntityId;
}): Promise<string | undefined> {
  // currently assumes a URL is returned from `appConfigURI`
  // TODO: add data URI support
  const url = await readContract(client, {
    address: worldAddress,
    abi: worldCallAbi,
    functionName: "call",
    args: encodeSystemCall({
      systemId: program,
      abi: appAbi,
      functionName: "appConfigURI",
      args: [entity ?? "0x"],
    }),
  });

  // TODO: if no url or if revert (not implemented), fallback to program default URL

  if (url === "") return;
  return url;
}
