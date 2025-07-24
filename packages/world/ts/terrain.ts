import { type Hex, type PublicClient, pad, toBytes } from "viem";
import { CHUNK_SIZE, voxelToChunkPos } from "./chunk";
import { getCreate3Address } from "./getCreate3Address";
import { type Vec3, packVec3 } from "./vec3";

// Should match SSTORE2.sol
const DATA_OFFSET = 1;

// Should match TerrainLib.sol
const EXPECTED_VERSION = 0x00;
const VERSION_PADDING = 1;
const BIOME_PADDING = 1;
const SURFACE_PADDING = 1;

function getChunkSalt(coord: Vec3) {
  return pad(toBytes(packVec3(coord)), { size: 32 });
}

function mod(a: number, b: number): number {
  return ((a % b) + b) % b;
}

function getRelativeCoord([x, y, z]: Vec3): Vec3 {
  return [mod(x, CHUNK_SIZE), mod(y, CHUNK_SIZE), mod(z, CHUNK_SIZE)];
}

function getBlockIndex([x, y, z]: Vec3): number {
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
  chunkCoord: Vec3,
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
  const chunkCoord: Vec3 = voxelToChunkPos([x, y, z]);

  const bytecode = await getChunkBytecode(
    publicClient,
    worldAddress,
    chunkCoord,
  );

  const index = getBlockIndex([x, y, z]);
  return readBytes1(bytecode, index);
}

export async function getBiome(
  worldAddress: Hex,
  publicClient: PublicClient,
  [x, y, z]: Vec3,
): Promise<number> {
  const chunkCoord: Vec3 = voxelToChunkPos([x, y, z]);

  const bytecode = await getChunkBytecode(
    publicClient,
    worldAddress,
    chunkCoord,
  );

  return readBytes1(bytecode, 1);
}
