import { resourceToHex } from "@latticexyz/common";
// Copied over from MDU because the exported bundle includes browser code that Cloudflare Workers have a hard time with
// https://github.com/latticexyz/mud/blob/1f509ee224cadd4254e7bbb7a268b519f65e4495/packages/entrykit/src/validateSigner.ts
//
// TODO: remove this once MUD has a tree-shakable build
import { getRecord } from "@latticexyz/store/internal";
import worldConfig from "@latticexyz/world/mud.config";
import type { Address, Client } from "viem";
import { readContract } from "viem/actions";

export async function validateSigner({
  client,
  worldAddress,
  userAddress,
  sessionAddress,
  signerAddress,
}: {
  client: Client;
  worldAddress: Address;
  userAddress: Address;
  sessionAddress: Address;
  signerAddress: Address;
}) {
  const ownerAddress = await readContract(client, {
    address: sessionAddress,
    abi: simpleAccountAbi,
    functionName: "owner",
  });

  if (ownerAddress.toLowerCase() !== signerAddress.toLowerCase()) {
    throw new Error(
      `Session account owner (${ownerAddress}) does not match message signer (${signerAddress}).`,
    );
  }

  const hasDelegation = await getDelegation({
    client,
    worldAddress,
    sessionAddress,
    userAddress,
    blockTag: "latest",
  });

  if (!hasDelegation) {
    throw new Error(
      `Session account (${sessionAddress}) does not have delegation for user account (${userAddress}).`,
    );
  }
}

// TODO: import ABI once we can get strongly typed JSON or expose `getOwner` or similar method on smart account
const simpleAccountAbi = [
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

const unlimitedDelegationControlId = resourceToHex({
  type: "system",
  namespace: "",
  name: "unlimited",
});

// TODO: rename to `hasDelegation`?
async function getDelegation({
  client,
  worldAddress,
  userAddress,
  sessionAddress,
  // TODO: move everything to latest instead of pending
  blockTag = "pending",
}: {
  client: Client;
  worldAddress: Address;
  userAddress: Address;
  sessionAddress: Address;
  blockTag?: "pending" | "latest";
}) {
  const record = await getRecord(client, {
    address: worldAddress,
    table: worldConfig.namespaces.world.tables.UserDelegationControl,
    key: { delegator: userAddress, delegatee: sessionAddress },
    blockTag,
  });
  return record.delegationControlId === unlimitedDelegationControlId;
}
