import { objects } from "../objects";

// Template for the Solidity file
function generateObjectTypesSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ObjectType } from "../ObjectType.sol";

${objects
  .map((obj) => {
    return `ObjectType constant ${obj.name} = ObjectType.wrap(${obj.id});`;
  })
  .join("\n")}
`;
}

console.info(generateObjectTypesSol());
