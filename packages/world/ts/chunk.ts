import type { ReadonlyVec3, Vec3 } from "./vec3";

export const CHUNK_SIZE = 16;

export function voxelToChunkPos([x, y, z]: ReadonlyVec3): Vec3 {
  return [
    Math.floor(x / CHUNK_SIZE),
    Math.floor(y / CHUNK_SIZE),
    Math.floor(z / CHUNK_SIZE),
  ];
}

export function chunkToVoxelPos([x, y, z]: ReadonlyVec3): Vec3 {
  return [x * CHUNK_SIZE, y * CHUNK_SIZE, z * CHUNK_SIZE];
}
