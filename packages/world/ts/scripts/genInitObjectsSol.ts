import { includes } from "@latticexyz/common/utils";
import { categories, objects, objectsByName } from "../objects";

// Template for the Solidity file
function generateInitObjectsSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectPhysics, ObjectPhysicsData } from "../src/codegen/tables/ObjectPhysics.sol";
import { ObjectTypes } from "../src/types/ObjectType.sol";

function initObjects() {
${objects
  .filter((obj) => obj.mass || obj.energy)
  .map((obj) => {
    return `  ObjectPhysics.set(ObjectTypes.${obj.name}, ObjectPhysicsData({ mass: ${obj.mass ?? 0}, energy: ${obj.energy ?? 0} }));`;
  })
  .join("\n")}
}
`;
}

function validateSeeds() {
  const seeds = objects.filter((obj) =>
    includes(categories.Seed.objects, obj.name),
  );
  for (const seed of seeds) {
    if (!seed.crop) {
      throw new Error(`Seed ${seed.name} has no crop`);
    }

    const growsInto = objectsByName[seed.crop];
    if (!growsInto) {
      throw new Error(
        `Seed ${seed.name} grows into ${seed.crop} but object does not exist`,
      );
    }

    if (seed.mass !== undefined) {
      throw new Error(`Seed ${seed.name} has mass`);
    }

    const totalCropEnergy = (growsInto.mass ?? 0n) + (growsInto.energy ?? 0n);
    const growableEnergy = seed.growableEnergy;

    if (totalCropEnergy !== growableEnergy) {
      throw new Error(
        `Seed ${seed.name} does not maintain mass+energy balance ${totalCropEnergy} != ${growableEnergy}`,
      );
    }
  }
}

validateSeeds();

console.info(generateInitObjectsSol());
