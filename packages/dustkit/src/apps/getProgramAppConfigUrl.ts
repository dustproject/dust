import { getRecord } from "@latticexyz/store/internal";
import baseWorldConfig from "@latticexyz/world/mud.config";
import { type Address, type Client, zeroHash } from "viem";
import { readContract } from "viem/actions";
import appAbi from "../../out/IAppConfigURI.sol/IAppConfigURI.abi";
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
  const { system } = await getRecord(client, {
    address: worldAddress,
    table: baseWorldConfig.tables.world__Systems,
    key: {
      systemId: program,
    },
  });

  try {
    // We are calling the program system directly here, as programs are required to be private
    // systems so that their hook functions can only be called by the world
    url = await readContract(client, {
      address: system,
      abi: appAbi,
      functionName: "appConfigURI",
      args: [entity ?? zeroHash],
    });
  } catch (error: any) {
    if (error?.name === "ContractFunctionExecutionError") {
      return undefined;
    }
    throw error;
  }
  if (url !== "") {
    return url;
  }
}
