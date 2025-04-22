import { objects } from "./objects";

// Template for the Solidity file
function generateInitObjectsSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectTypeMetadata, ObjectTypeMetadataData } from "../src/codegen/tables/ObjectTypeMetadata.sol";
import { ObjectTypes } from "../src/ObjectType.sol";

function initObjects() {
${objects
  .filter((obj) => obj.mass || obj.energy)
  .map((obj) => {
    return `  ObjectTypeMetadata.set(ObjectTypes.${obj.name}, ObjectTypeMetadataData({ mass: ${obj.mass ?? 0}, energy: ${obj.energy ?? 0} }));`;
  })
  .join("\n")}
}
`;
}

// Execute the generator when this module is run directly
if (require.main === module) {
  console.info(generateInitObjectsSol());
}
