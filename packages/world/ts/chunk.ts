import type { ReadonlyVec3, Vec3 } from "./vec3";

export const chunkSize = 16;

export function voxelToChunkPos([x, y, z]: ReadonlyVec3): Vec3 {
  return [
    Math.floor(x / chunkSize),
    Math.floor(y / chunkSize),
    Math.floor(z / chunkSize),
  ];
}

export function chunkToVoxelPos([x, y, z]: ReadonlyVec3): Vec3 {
  return [x * chunkSize, y * chunkSize, z * chunkSize];
}
