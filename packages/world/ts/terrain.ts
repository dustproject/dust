import { type Hex, type PublicClient, pad, toBytes } from "viem";
import { CHUNK_SIZE, voxelToChunkPos } from "./chunk";
import { getCreate3Address } from "./getCreate3Address";
import { type ReadonlyVec3, type Vec3, packVec3 } from "./vec3";

const bytecodeCache = new Map<string, string>();

// Should match SSTORE2.sol
const DATA_OFFSET = 1;

// Should match TerrainLib.sol
const EXPECTED_VERSION = 0x00;
const VERSION_PADDING = 1;
const BIOME_PADDING = 1;
const SURFACE_PADDING = 1;

function getChunkSalt(coord: ReadonlyVec3) {
  return pad(toBytes(packVec3(coord)), { size: 32 });
}

function getCacheKey(worldAddress: Hex, [x, y, z]: ReadonlyVec3): string {
  return `${worldAddress}:${x},${y},${z}`;
}

function deconstructCacheKey(key: string): [Hex, Vec3] {
  const [worldAddress, x, y, z] = key.split(":");
  return [worldAddress as Hex, [Number(x), Number(y), Number(z)]];
}

function mod(a: number, b: number): number {
  return ((a % b) + b) % b;
}

function getRelativeCoord([x, y, z]: ReadonlyVec3): ReadonlyVec3 {
  return [mod(x, CHUNK_SIZE), mod(y, CHUNK_SIZE), mod(z, CHUNK_SIZE)];
}

function getBlockIndex([x, y, z]: ReadonlyVec3): number {
  const [rx, ry, rz] = getRelativeCoord([x, y, z]);
  const index =
    VERSION_PADDING +
    BIOME_PADDING +
    SURFACE_PADDING +
    rx * CHUNK_SIZE ** 2 +
    ry * CHUNK_SIZE +
    rz;
  return index;
}

function readBytes1(bytecode: string, offset: number): number {
  if (!bytecode || bytecode === "0x")
    throw new Error("InvalidPointer: no bytecode found");

  const start = 2 + (DATA_OFFSET + offset) * 2;
  const hexByte = bytecode.slice(start, start + 2);
  if (hexByte.length !== 2) throw new Error("ReadOutOfBounds");

  return Number.parseInt(hexByte, 16);
}

export async function getChunkBytecode(
  publicClient: PublicClient,
  worldAddress: Hex,
  chunkCoord: ReadonlyVec3,
): Promise<string> {
  const chunkPointer = getCreate3Address({
    from: worldAddress,
    salt: getChunkSalt(chunkCoord),
  });

  const bytecode = await publicClient.getCode({ address: chunkPointer });
  if (!bytecode) throw new Error("Chunk not explored");

  // Read version byte
  const version = readBytes1(bytecode, 0);
  if (version !== EXPECTED_VERSION) {
    throw new Error("Unsupported chunk encoding version");
  }

  return bytecode;
}

export async function getTerrainBlockType(
  publicClient: PublicClient,
  worldAddress: Hex,
  [x, y, z]: Vec3,
): Promise<number> {
  const chunkCoord = voxelToChunkPos([x, y, z]);
  const cacheKey = getCacheKey(worldAddress, chunkCoord);

  let bytecode = bytecodeCache.get(cacheKey);
  if (!bytecode) {
    bytecode = await getChunkBytecode(publicClient, worldAddress, chunkCoord);
    bytecodeCache.set(cacheKey, bytecode);
  }

  return readTerrainBlockType(bytecode, [x, y, z]);
}

export async function getTerrainBlockTypes(
  publicClient: PublicClient,
  worldAddress: Hex,
  coords: Vec3[],
): Promise<number[]> {
  const chunkGroups = new Map<string, Vec3[]>();

  for (const coord of coords) {
    const chunkCoord = voxelToChunkPos(coord);
    const chunkKey = getCacheKey(worldAddress, chunkCoord);

    if (!chunkGroups.has(chunkKey)) {
      chunkGroups.set(chunkKey, []);
    }
    chunkGroups.get(chunkKey)!.push(coord);
  }

  const chunkPromises = Array.from(chunkGroups.keys()).map(
    async (chunkCacheKey) => {
      const [worldAddress, chunkCoord] = deconstructCacheKey(chunkCacheKey);

      let bytecode = bytecodeCache.get(chunkCacheKey);
      if (!bytecode) {
        bytecode = await getChunkBytecode(
          publicClient,
          worldAddress,
          chunkCoord,
        );
        bytecodeCache.set(chunkCacheKey, bytecode);
      }

      return { chunkCacheKey, bytecode };
    },
  );

  const chunkResults = await Promise.all(chunkPromises);
  const chunkBytecodes = new Map(
    chunkResults.map((r) => [r.chunkCacheKey, r.bytecode]),
  );

  return coords.map((coord) => {
    const chunkCoord = voxelToChunkPos(coord);
    const chunkCacheKey = getCacheKey(worldAddress, chunkCoord);
    const bytecode = chunkBytecodes.get(chunkCacheKey)!;
    return readTerrainBlockType(bytecode, coord);
  });
}

export function readTerrainBlockType(
  chunkBytecode: string,
  [x, y, z]: Vec3,
): number {
  return readBytes1(chunkBytecode, getBlockIndex([x, y, z]));
}

export async function getBiome(
  worldAddress: Hex,
  publicClient: PublicClient,
  [x, y, z]: Vec3,
): Promise<number> {
  const chunkCoord = voxelToChunkPos([x, y, z]);
  const cacheKey = getCacheKey(worldAddress, chunkCoord);

  let bytecode = bytecodeCache.get(cacheKey);
  if (!bytecode) {
    bytecode = await getChunkBytecode(publicClient, worldAddress, chunkCoord);
    bytecodeCache.set(cacheKey, bytecode);
  }

  return readBiome(bytecode);
}

export function readBiome(chunkBytecode: string): number {
  return readBytes1(chunkBytecode, 1);
}
