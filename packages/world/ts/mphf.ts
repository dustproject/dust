/* ---------------------------------------------------------------
   buildBucket(ids)  →  { S, A0,A1,A2, gpack, table }
   --------------------------------------------------------------- */
export type Bucket = {
  S: number; // #keys (≤128)
  A0: number; // three odd 16-bit multipliers
  A1: number;
  A2: number;
  gpack: bigint; // 2-bit g[] packed little-endian in a uint256
  table: Uint8Array; // 2×S bytes, slot→id little-endian
};

export function buildBucket(ids: number[]): Bucket {
  if (ids.length === 0) throw new Error("empty set");
  if (ids.length > 128) throw new Error("split set first (S>128)");
  const n = ids.length;
  const S = Math.ceil(n * 1.25);

  /* ------------ helpers ---------------- */
  const odd16 = () => ((Math.random() * 0xffff) | 1) & 0xffff;

  const hash = (id: number, A: number) => ((id * A) >> 8) & 0xff;

  /* repeat until we get a peelable graph */
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const [A0, A1, A2] = [odd16(), odd16(), odd16()];

    const edges: [number, number, number][] = ids.map((id) => [
      hash(id, A0) % S,
      hash(id, A1) % S,
      hash(id, A2) % S,
    ]);

    /* ----------- peel order (reverse topological) ------------ */
    const deg = Array(S).fill(0);
    for (const edge of edges) {
      for (const v of edge) {
        ++deg[v];
      }
    }

    const stack: number[] = [];
    const order: number[] = Array(edges.length);

    for (const [i, edge] of edges.entries()) {
      if (deg[edge[0]] === 1 || deg[edge[1]] === 1 || deg[edge[2]] === 1)
        stack.push(i);
    }

    let ptr = edges.length;
    while (stack.length) {
      const ei = stack.pop()!;
      order[--ptr] = ei;
      for (const v of edges[ei]!) {
        if (--deg[v] === 1) {
          for (const [j, edge] of edges.entries()) {
            if (
              deg[edge[0]] &&
              deg[edge[1]] &&
              deg[edge[2]] &&
              edge.includes(v)
            )
              stack.push(j);
          }
        }
      }
    }
    if (ptr !== 0) continue; // graph had cycles – pick new multipliers

    /* ------------- assign 2-bit g[] --------------------------- */
    const g = new Uint8Array(S); // all 0 by default
    const used = new Uint8Array(S);

    for (const ei of order) {
      const [v0, v1, v2] = edges[ei]!;
      const need = ((S + ids[ei]! - (g[v0]! + g[v1]!)) % S) & 3;
      g[v2] = need;
      used[v2] = 1;
    }

    /* ------------- pack results ------------------------------ */
    let gpack = 0n;
    for (let i = 0; i < S; ++i) gpack |= BigInt(g[i]!) << BigInt(2 * i);

    const table = new Uint8Array(2 * S);
    for (const [i, edge] of edges.entries()) {
      const slot = (g[edge[0]]! + g[edge[1]]! + g[edge[2]]!) % S;
      table[2 * slot] = ids[i]! & 0xff; // little-endian
      table[2 * slot + 1] = ids[i]! >> 8;
    }

    return { S, A0, A1, A2, gpack, table };
  }
}
