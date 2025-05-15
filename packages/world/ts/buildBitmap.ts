export function buildBitmap(ids: number[]) {
  const bytes: Uint8Array[] = [];

  for (const id of ids) {
    const index = id >>> 3; // byte index inside logical bitmap
    const byte = id & 7; // bit position inside that byte
    const word = index >>> 5; // which 32-byte word
    const pos = 31 - (index & 31); // byte position *inside* that word

    if (!bytes[word]) bytes[word] = new Uint8Array(32);
    bytes[word]![pos]! |= 1 << byte; // set bit (big-endian layout)
  }

  // pack each 32-byte buffer into a bigint literal
  const words = bytes.map((buf) => {
    let w = 0n;
    for (const b of buf ?? new Uint8Array(32)) w = (w << 8n) | BigInt(b);
    return w;
  });

  return { words, byteLen: (Math.max(...ids) >>> 3) + 1 };
}
