export interface Bucket {
  S: number; // Number of slots
  A: [number, number, number]; // hash multipliers
  G: [bigint, bigint, bigint, bigint]; // 1–4 uint256 words for g values
  table: bigint[]; // Lookup table (2 × S bytes)
}

export function buildBucket(ids: number[]): Bucket {
  if (!ids.length) throw new Error("empty set");
  if (ids.length > 128) throw new Error("split set first (n > 128)");

  const n = ids.length;
  const S = Math.ceil(n * 1.23);

  // Helper functions
  const odd16 = (): number => (Math.floor(Math.random() * 0xffff) | 1) & 0xffff;
  const hash = (id: number, A: number): number => ((id * A) >> 8) & 0xff;

  while (true) {
    const A: [number, number, number] = [odd16(), odd16(), odd16()];
    const edges: [number, number, number][] = ids.map((id) => [
      hash(id, A[0]) % S,
      hash(id, A[1]) % S,
      hash(id, A[2]) % S,
    ]);

    // Peeling process with peel vertex tracking
    const deg = new Uint8Array(S);
    for (const [v0, v1, v2] of edges) {
      deg[v0]!++;
      deg[v1]!++;
      deg[v2]!++;
    }

    const stack: [number, number][] = []; // [edge index, peel vertex]
    const order: [number, number][] = []; // [edge index, peel vertex]
    const peeled = new Set<number>();

    // Initialize stack with edges having a degree-1 vertex
    for (let i = 0; i < n; i++) {
      const [v0, v1, v2] = edges[i]!;
      if (deg[v0] === 1) stack.push([i, v0]);
      else if (deg[v1] === 1) stack.push([i, v1]);
      else if (deg[v2] === 1) stack.push([i, v2]);
    }

    while (stack.length) {
      const [ei, peelV] = stack.pop()!;
      if (peeled.has(ei)) continue;
      peeled.add(ei);
      order.push([ei, peelV]);
      const [v0, v1, v2] = edges[ei]!;
      for (const v of [v0, v1, v2]) {
        deg[v]!--;
        if (deg[v] === 1) {
          for (let j = 0; j < n; j++) {
            if (!peeled.has(j)) {
              const [u0, u1, u2] = edges[j]!;
              if (u0 === v || u1 === v || u2 === v) {
                stack.push([j, v]);
              }
            }
          }
        }
      }
    }

    if (peeled.size !== n) continue; // Retry if not fully peelable

    // Assign g values in reverse peeling order
    const g = new Uint8Array(S);
    const table = new Uint8Array(2 * S);
    for (let k = n - 1; k >= 0; k--) {
      const [ei, peelV] = order[k]!;
      const [v0, v1, v2] = edges[ei]!;
      // Identify the two other vertices
      let vOther1, vOther2;
      if (peelV === v0) {
        vOther1 = v1;
        vOther2 = v2;
      } else if (peelV === v1) {
        vOther1 = v0;
        vOther2 = v2;
      } else {
        vOther1 = v0;
        vOther2 = v1;
      }
      const slot = k; // Unique slot from 0 to n-1
      g[peelV] = (slot + S - ((g[vOther1]! + g[vOther2]!) % S)) % S;
      table[2 * slot] = ids[ei]! & 0xff;
      table[2 * slot + 1] = ids[ei]! >> 8;
    }

    // Pad remaining slots
    for (let s = n; s < S; s++) {
      table[2 * s] = 0xff;
      table[2 * s + 1] = 0xff;
    }

    // Pack g into gWords
    const G: [bigint, bigint, bigint, bigint] = [0n, 0n, 0n, 0n];
    for (let i = 0; i < g.length; ++i) {
      const w = i >> 5; // word index 0..3
      const off = 31 - (i & 31); // big-endian byte position
      G[w]! |= BigInt(g[i]!) << BigInt(off * 8);
    }

    // Pack hash multipliers

    return { S, A, G, table: packTable(table) };
  }
}

function packTable(bytes: Uint8Array): bigint[] {
  const out: bigint[] = [];
  let acc = 0n,
    filled = 0;

  for (const b of bytes) {
    acc |= BigInt(b) << BigInt(8 * filled++);
    if (filled === 32) {
      out.push(acc);
      acc = 0n;
      filled = 0;
    }
  }
  if (filled) out.push(acc); // now word 0 = slots 0-15
  return out;
}
