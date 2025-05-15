import { describe, expect, it } from "vitest";
import { packVec3, unpackVec3 } from "../vec3";

describe("Vec3 and Uint96 conversions", () => {
  it("packVec3", () => {
    expect(packVec3([0, 0, 0])).toEqual(0n);
    expect(packVec3([39, 62, 16])).toEqual(719423019140960485392n);
    expect(packVec3([-12, 0, 3])).toEqual(79228162292903408709029330947n);
    expect(packVec3([-102, -2, 3044])).toEqual(79228160651143186140289305572n);
    expect(packVec3([-1002, -2, -3044])).toEqual(
      79228144049073519805987812380n,
    );
  });
  it("unpackVec3", () => {
    expect(unpackVec3(0n)).toEqual([0, 0, 0]);
    expect(unpackVec3(719423019140960485392n)).toEqual([39, 62, 16]);
    expect(unpackVec3(79228162292903408709029330947n)).toEqual([-12, 0, 3]);
    expect(unpackVec3(79228160651143186140289305572n)).toEqual([
      -102, -2, 3044,
    ]);
    expect(unpackVec3(79228144049073519805987812380n)).toEqual([
      -1002, -2, -3044,
    ]);
  });
});
