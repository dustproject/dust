import { objects, objectsByName } from "../objects";

// Template for the Solidity file
function generateInitObjectsSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectPhysics, ObjectPhysicsData } from "../src/codegen/tables/ObjectPhysics.sol";
import { ObjectTypes } from "../src/ObjectType.sol";

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
  const seeds = objects.filter((obj) => obj.category === "Seed");
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
    const totalInputMassEnergy =
      (growsInto.mass ?? 0n) + (growsInto.energy ?? 0n);
    if (seed.mass !== undefined) {
      throw new Error(`Seed ${seed.name} has mass`);
    }
    if (seed.growableEnergy === undefined) {
      throw new Error(`Seed ${seed.name} has no energy`);
    }
    const totalOutputMassEnergy = seed.growableEnergy;
    if (totalInputMassEnergy !== totalOutputMassEnergy) {
      throw new Error(
        `Seed ${seed.name} does not maintain mass+energy balance ${totalInputMassEnergy} != ${totalOutputMassEnergy}`,
      );
    }
  }
}

validateSeeds();

console.info(generateInitObjectsSol());
