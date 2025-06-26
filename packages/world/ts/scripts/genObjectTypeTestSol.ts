import { type Category, categories, objectNames } from "../objects";

// Template for the Solidity file
function generateObjectTypeTestSol(): string {
  return `// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DustTest, console } from "./DustTest.sol";

import { ObjectType, ObjectTypeLib, ObjectTypes } from "../src/types/ObjectType.sol";

contract ObjectTypeTest is DustTest {
  function testCategories() public pure {
  ${Object.entries(categories)
    .map(([name, data]: [string, Category]) => {
      const categoryObjects = data.objects;
      const objectsNotInCategory = objectNames.filter(
        (obj) => !categoryObjects.includes(obj),
      );
      const categoryCheck = data.checkName ?? `is${name}`;
      return `
      {
        ${categoryObjects.map((obj) => `assertTrue(ObjectTypes.${obj}.${categoryCheck}(), "${categoryCheck}");`).join("\n")}
        ${objectsNotInCategory.map((obj) => `assertFalse(ObjectTypes.${obj}.${categoryCheck}(), "!${categoryCheck}");`).join("\n")}
      }
      `;
    })
    .join("\n")}
  }
}
`;
}

console.info(generateObjectTypeTestSol());
