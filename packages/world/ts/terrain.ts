import { type Hex, type PublicClient, pad, toBytes } from "viem";
import { chunkSize, voxelToChunkPos } from "./chunk";
import { getCreate3Address } from "./getCreate3Address";
import { type Vec3, packVec3 } from "./vec3";

const DATA_OFFSET = 1;

const EXPECTED_VERSION = 0x00;

const VERSION_PADDING = 1;
const BIOME_PADDING = 1;
const SURFACE_PADDING = 1;

function _getChunkSalt(coord: Vec3) {
  return pad(toBytes(packVec3(coord)), { size: 32 });
}

function mod(a: number, b: number): number {
  return ((a % b) + b) % b;
}

function _getRelativeCoord([x, y, z]: Vec3): Vec3 {
  return [mod(x, chunkSize), mod(y, chunkSize), mod(z, chunkSize)];
}

function _getBlockIndex([x, y, z]: Vec3): number {
  const [rx, ry, rz] = _getRelativeCoord([x, y, z]);
  const index =
    VERSION_PADDING +
    BIOME_PADDING +
    SURFACE_PADDING +
    rx * chunkSize ** 2 +
    ry * chunkSize +
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

export async function getTerrainBlockType(
  worldAddress: Hex,
  publicClient: PublicClient,
  [x, y, z]: Vec3,
): Promise<number> {
  const chunkCoord: Vec3 = voxelToChunkPos([x, y, z]);

  const chunkPointer = getCreate3Address({
    from: worldAddress,
    salt: _getChunkSalt(chunkCoord),
  });

  const bytecode = await publicClient.getCode({ address: chunkPointer });
  if (!bytecode) throw new Error("InvalidPointer: no bytecode found");

  // Read version byte
  const version = readBytes1(bytecode, 0);
  if (version !== EXPECTED_VERSION)
    throw new Error("Unsupported chunk encoding version");

  // Get block index
  const index = _getBlockIndex([x, y, z]);
  const blockType = readBytes1(bytecode, index);

  return blockType;
}
