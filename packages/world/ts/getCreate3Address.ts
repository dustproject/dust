import {
  type Address,
  type ByteArray,
  type Hex,
  getCreate2Address,
  getCreateAddress,
} from "viem";

const DEFAULT_CREATE3_PROXY_INITCODE_HASH: Hex =
  "0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f";

export function getCreate3Address(opts: {
  from: Address;
  salt: ByteArray | Hex;
  proxyInitCodeHash?: Hex;
}): Hex {
  const proxyAddress = getCreate2Address({
    from: opts.from,
    salt: opts.salt,
    bytecodeHash: opts.proxyInitCodeHash ?? DEFAULT_CREATE3_PROXY_INITCODE_HASH,
  });

  const finalAddress = getCreateAddress({
    from: proxyAddress,
    nonce: 1n,
  });

  return finalAddress;
}
