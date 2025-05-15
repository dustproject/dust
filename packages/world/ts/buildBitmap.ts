export function buildBitmap(ids: number[]) {
  if (!ids.length) throw new Error("empty set");
  const maxId = Math.max(...ids);
  const byteLen = (maxId >> 3) + 1;
  const bytes = new Uint8Array(byteLen);

  // set bits
  for (const id of ids) {
    bytes[id >> 3]! |= 1 << (id & 7);
  }

  // chop into 32-byte words, build big-endian literals
  const words: bigint[] = [];
  for (let off = 0; off < bytes.length; off += 32) {
    const chunk = bytes.slice(off, off + 32); // little-endian
    const buf = new Uint8Array(32);
    buf.set(chunk);
    buf.reverse(); // flip to big-endian

    let w = 0n;
    for (const b of buf) w = (w << 8n) | BigInt(b);
    words.push(w);
  }

  return { byteLen, words };
}
