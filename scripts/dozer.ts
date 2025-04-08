import type { Hex } from "viem";
import { setupNetwork } from "./setupNetwork";

import fs from "node:fs";
import path from "node:path";
import { constructTableNameForQuery, replacer } from "./utils";

async function main() {
  const {
    publicClient,
    fromBlock,
    worldAddress,
    IWorldAbi,
    account,
    txOptions,
    callTx,
    indexer,
  } = await setupNetwork();

  const query = [
    {
      address: worldAddress,
      query: `SELECT ${indexer?.type === "sqlite" ? "*" : '"entityId", "programAddress"'} FROM "${constructTableNameForQuery(
        "",
        "Program",
        worldAddress as Hex,
        indexer,
      )}";`,
    },
  ];

  const entityIds = new Set();

  // fetch post request
  const response = await fetch(indexer?.url, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(query),
  });
  const content = await response.json();
  for (const row of content.result[0]) {
    // don't include the first row cuz its the header
    if (row[0].toLowerCase() === "entityid") continue;
    if (
      row[1].toLowerCase() ===
      "0x602e17290e184Cafab0f8AB242f49DF690f0ab45".toLowerCase()
    ) {
      entityIds.add(row[0]);
    }
    // entityIds.add(row[0]);
  }
  let i = 0;
  for (const entityId of entityIds) {
    i++;
  }
}

main();
