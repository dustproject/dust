# Registration

## Preview an app in the client

Before registering an app to make it available to everyone, you can preview your app in the production client by using the `debug-app` URL parameter.

Example: `https://alpha.dustproject.org/?debug-app=https://your-dust-app.com/dust-app.json`

## Register a global app

To make an app available in everyone's client, you have to register it in the global app registry.

1. Register a new MUD namespace.

   ```solidity
    import { ResourceId, WorldResourceIdInstance, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
    import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

    IWorld world = IWorld(0x253eb85B3C953bFE3827CC14a151262482E7189C);
    ResourceId appNamespaceId = WorldResourceIdLib.encodeNamespace(bytes14(bytes("your-dust-app")));
    if (!ResourceIds.getExists(appNamespaceId)) {
      world.registerNamespace(appNamespaceId);
    }
   ```

2. Register by setting a resource tag that points to your ([app's manifest](https://esm.sh/pr/dustproject/dust/dustkit@d9cb17b/json-schemas/app-config.json))

   ```solidity
   import { metadataSystem } from
   "@latticexyz/world-module-metadata/src/codegen/experimental/systems/MetadataSystemLib.sol";

   metadataSystem.setResourceTag(appNamespaceId, "dust.appConfigUrl", bytes("https://your-dust-app.com/dust-app.json"));
   ```

## Register a contextual app

To show a contextual app when interacting with an entity that has [your program installed](../programs/registration.md), your program needs to implement the [`appConfigURI` function](https://github.com/dustproject/dust/blob/main/packages/dustkit/contracts/IAppConfigURI.sol).

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

contract CustomProgram {
  function appConfigURI(EntityId viaEntity) external returns (string memory uri) {
    return "https://your-dust-app.com/dust-app.json";
  }
}
```
