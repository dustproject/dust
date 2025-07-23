import type { ReadonlyVec3, Vec3 } from "./vec3";

export const chunkSize = 16;

export function voxelToChunkPos(vec3: ReadonlyVec3): Vec3 {
  return [
    Math.floor(vec3[0] / chunkSize),
    Math.floor(vec3[1] / chunkSize),
    Math.floor(vec3[2] / chunkSize),
  ];
}

export function chunkToVoxelPos([x, y, z]: ReadonlyVec3): Vec3 {
  return [x * chunkSize, y * chunkSize, z * chunkSize];
}
