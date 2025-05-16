export function buildBitmap(ids: number[]) {
  if (ids.length === 0) throw new Error("empty set");
  ids.sort();

  // bytes[word][byteInWord] = the 8-bit chunk
  const bytes: Array<Uint8Array | undefined> = [];
  for (const id of ids) {
    const absByte = id >>> 3; // floor(id/8)
    const word = absByte >>> 5; // floor(absByte/32) == floor(id/256)
    const b = 31 - (absByte & 31); // MSB-first byte
    const bit = 1 << (id & 7); // which bit in that byte
    if (!bytes[word]) bytes[word] = new Uint8Array(32);
    bytes[word]![b]! |= bit;
  }

  // pack each non-zero Uint8Array into a bigint
  const words: { idx: number; val: bigint }[] = [];
  bytes.forEach((buf, i) => {
    if (!buf) return;
    let w = 0n;
    for (const byte of buf) {
      w = (w << 8n) | BigInt(byte);
    }
    if (w !== 0n) words.push({ idx: i, val: w });
  });

  return { words };
}
