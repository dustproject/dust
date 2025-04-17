import { encodeSystemCall } from "@latticexyz/world/internal";
import { type Address, type Client, zeroHash } from "viem";
import { readContract } from "viem/actions";
import appAbi from "../../out/IAppConfigURI.sol/IAppConfigURI.abi";
import worldCallAbi from "../../out/IWorldKernel.sol/IWorldCall.abi";
import type { EntityId, ProgramId } from "../common";

// TODO: add data URI support (currently assumes URL)

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
  let url: string | undefined;
  try {
    url = await readContract(client, {
      address: worldAddress,
      abi: worldCallAbi,
      functionName: "call",
      args: encodeSystemCall({
        systemId: program,
        abi: appAbi,
        functionName: "appConfigURI",
        args: [entity ?? zeroHash],
      }),
    });
  } catch (error: any) {
    if (error?.name === "ContractFunctionRevertedError") {
      return undefined;
    }
    throw error;
  }
  if (url !== "") {
    return url;
  }
}
