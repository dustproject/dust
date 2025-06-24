import type { Hex } from "viem";
import { setupNetwork } from "./setupNetwork";

import { EntityTypes, decodeEntityType } from "@dust/world/internal";
import { constructTableNameForQuery } from "./utils";

async function main() {
  const { worldAddress, indexer } = await setupNetwork();

  const query = [
    {
      address: worldAddress,
      query: `SELECT ${indexer?.type === "sqlite" ? "*" : '"entityId", "energy"'} FROM "${constructTableNameForQuery(
        "",
        "Energy",
        worldAddress as Hex,
        indexer,
      )}";`,
    },
  ];

  // fetch post request
  const response = await fetch(indexer?.url, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(query),
  });
  // console.log(response);
  const content = await response.json();

  let numPlayers = 0;
  for (const row of content.result[0]) {
    // don't include the first row cuz its the header
    if (row[0].toLowerCase() === "entityid") continue;
    console.log(row);
    const entityType = decodeEntityType(row[0]);
    if (entityType === EntityTypes.Player) {
      numPlayers++;
    }
  }
  console.log("numPlayers", numPlayers);
}

main();
