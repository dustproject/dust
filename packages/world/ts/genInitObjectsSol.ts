import { objects } from "./objects.ts";

// Template for the Solidity file
function generateInitObjectsSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectTypeMetadata, ObjectTypeMetadataData } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { ObjectTypes } from "../src/ObjectType.sol";

function initObjects() {
${objects
  .map((obj) => {
    return `  ObjectTypeMetadata.set(ObjectTypes.${obj.name}, ObjectTypeMetadataData({ mass: ${obj.mass.toString()}, energy: ${obj.energy.toString()} }));`;
  })
  .join("\n")}
}
`;
}

// Execute the generator when this module is run directly
if (require.main === module) {
  console.info(generateInitObjectsSol());
}
