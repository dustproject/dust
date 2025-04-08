import { getTableName } from "@latticexyz/store-sync/sqlite";
import type { Hex } from "viem";

export function replacer(key, value) {
  if (value === undefined) {
    return "undefined";
  }
  if (typeof value === "bigint") {
    return `BigInt:${value.toString()}`;
  }
  if (value instanceof Map) {
    return { dataType: "Map", value: Array.from(value.entries()) };
  }
  if (value instanceof Set) {
    return { dataType: "Set", value: Array.from(value) };
  }
  if (value === Number.POSITIVE_INFINITY) {
    return "Infinity";
  }
  if (value === Number.NEGATIVE_INFINITY) {
    return "-Infinity";
  }
  return value;
}

export function reviver(key, value) {
  if (typeof value === "string") {
    if (value.startsWith("BigInt:")) {
      return BigInt(value.substring("BigInt:".length));
    }
    if (value === "Infinity") {
      return Number.POSITIVE_INFINITY;
    }
    if (value === "-Infinity") {
      return Number.NEGATIVE_INFINITY;
    }
    if (value === "undefined") {
      return undefined;
    }
    return value;
  }
  if (value && typeof value === "object") {
    if (value.dataType === "Map") {
      return new Map(
        value.value.map(([k, v]) => [
          k,
          JSON.parse(JSON.stringify(v, replacer), reviver),
        ]),
      );
    }
    if (value.dataType === "Set") {
      return new Set(
        Array.from(value.value, (v) =>
          JSON.parse(JSON.stringify(v, replacer), reviver),
        ),
      );
    }
    // For regular objects, recursively revive any nested structures
    for (const prop in value) {
      value[prop] = JSON.parse(JSON.stringify(value[prop], replacer), reviver);
    }
    return value;
  }
  return value;
}

export function constructTableNameForQuery(
  tableNamespace: string,
  tableName: string,
  worldAddress: Hex,
  indexer: { type: string; url: string },
) {
  if (indexer.type === "sqlite") {
    return getTableName(worldAddress, tableNamespace, tableName);
  }
  return constructDozerTableName(tableNamespace, tableName);
}

function constructDozerTableName(tableNamespace: string, tableName: string) {
  return tableNamespace ? `${tableNamespace}__${tableName}` : tableName;
}
