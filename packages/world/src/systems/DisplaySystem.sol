// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { System } from "@latticexyz/world/src/System.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";

import { BaseEntity } from "../codegen/tables/BaseEntity.sol";
import { DisplayURI } from "../codegen/tables/DisplayURI.sol";

import { Energy, EnergyData } from "../codegen/tables/Energy.sol";
import { ObjectType } from "../codegen/tables/ObjectType.sol";

import { Position, ReversePosition } from "../utils/Vec3Storage.sol";

import { EntityId } from "../EntityId.sol";
import { ObjectTypeId } from "../ObjectTypeId.sol";
import { ObjectTypeLib } from "../ObjectTypeLib.sol";
import { IDisplay } from "../ProgramInterfaces.sol";
import { Vec3 } from "../Vec3.sol";
import { getLatestEnergyData } from "../utils/EnergyUtils.sol";
import { getForceField } from "../utils/ForceFieldUtils.sol";

contract DisplaySystem is System {
  using ObjectTypeLib for ObjectTypeId;

  function getDisplayURI(EntityId caller, EntityId entityId, bytes memory extraData)
    public
    view
    returns (string memory)
  {
    require(entityId.exists(), "Entity does not exist");

    EntityId base = entityId.baseEntityId();
    Vec3 entityCoord = Position._get(base);

    (EntityId forceField,) = getForceField(entityCoord);
    uint256 machineEnergyLevel = 0;
    if (forceField.exists()) {
      (EnergyData memory machineData,,) = getLatestEnergyData(forceField);
      machineEnergyLevel = machineData.energy;
    }
    if (machineEnergyLevel > 0) {
      bytes memory _getDisplayURI = abi.encodeCall(IDisplay.getDisplayURI, (caller, base, extraData));
      bytes memory returnData = base.getProgram().staticcallOrRevert(_getDisplayURI);
      return abi.decode(returnData, (string));
    }

    return "";
  }

  function setDisplayURI(EntityId, /* caller */ EntityId entityId, string memory uri) public {
    // TODO: auth?

    EntityId base = entityId.baseEntityId();
    require(ObjectType._get(base).canHoldDisplay(), "You can only set the display content of a basic display");
    Vec3 entityCoord = Position._get(base);
    require(ReversePosition._get(entityCoord) == base, "Entity is not at the specified position");

    DisplayURI._set(base, uri);
  }
}
