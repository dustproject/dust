import { objects } from "../objects";

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

console.info(generateInitObjectsSol());
