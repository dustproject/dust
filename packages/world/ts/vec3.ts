export type Vec3 = [x: number, y: number, z: number];

export type ReadonlyVec3 = Readonly<Vec3>;

/**
 * Pack an `[x,y,z]` vector into a single `uint96` to match `Vec3.sol` user type.
 **/
export function packVec3([x, y, z]: ReadonlyVec3): bigint {
  // Convert each signed 32-bit integer into an unsigned 32-bit number,
  // then to BigInt for safe 64-bit+ operations.
  const ux = BigInt(x >>> 0);
  const uy = BigInt(y >>> 0);
  const uz = BigInt(z >>> 0);

  // Pack the three numbers into a single 96-bit integer:
  // Shift ux left by 64 bits, uy left by 32 bits, and then OR them together.
  return (ux << 64n) | (uy << 32n) | uz;
}

/**
 * Unpack a `uint96` into an `[x,y,z]` vector.
 **/
export function unpackVec3(vec3: bigint): Vec3 {
  const mask = 0xffffffffn;

  // Extract the three 32-bit components.
  const xUint = (vec3 >> 64n) & mask; // most significant 32 bits
  const yUint = (vec3 >> 32n) & mask; // middle 32 bits
  const zUint = vec3 & mask; // least significant 32 bits

  // Convert unsigned 32-bit to signed 32-bit integer.
  const toSigned32 = (uint: bigint): number => {
    const half32 = 2n ** 31n; // 2^31
    const max32 = 2n ** 32n; // 2^32
    let signed = uint;
    if (signed >= half32) {
      signed -= max32;
    }
    return Number(signed);
  };

  return [toSigned32(xUint), toSigned32(yUint), toSigned32(zUint)];
}
