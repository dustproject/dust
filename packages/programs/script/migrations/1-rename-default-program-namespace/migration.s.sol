// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";

import { Migration } from "@dust/world/script/migrations/Migration.sol";
import { IndexerResult } from "@dust/world/script/utils/indexer.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";
import { ProgramId } from "@dust/world/src/types/ProgramId.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { AccessGroupCount } from "../../../src/codegen/tables/AccessGroupCount.sol";
import { AccessGroupMember } from "../../../src/codegen/tables/AccessGroupMember.sol";
import { AccessGroupOwner } from "../../../src/codegen/tables/AccessGroupOwner.sol";
import { EntityAccessGroup } from "../../../src/codegen/tables/EntityAccessGroup.sol";
import { TextSignContent } from "../../../src/codegen/tables/TextSignContent.sol";
import { EntityProgram } from "@dust/world/src/codegen/tables/EntityProgram.sol";

bytes14 constant OLD_NAMESPACE = "dfprograms_1";
bytes14 constant NEW_NAMESPACE = "defaultprogram";

contract RenameDefaultProgramNamespace is Migration {
  function getOutputPath() internal pure override returns (string memory) {
    return getMigrationOutputPath("1-rename-default-program-namespace");
  }

  function runMigration() internal override {
    console.log("\nRenaming default program namespace");

    IndexerResult memory accessGroupCounts =
      recordingQuery(string.concat("SELECT count FROM dfprograms_1__AccessGroupCount"), "(uint256)");
    for (uint256 i = 0; i < accessGroupCounts.rows.length; i++) {
      bytes memory row = accessGroupCounts.rows[i];
      (uint256 count) = abi.decode(row, (uint256));

      AccessGroupCount.set(count);
    }

    IndexerResult memory accessGroupOwners =
      recordingQuery(string.concat("SELECT groupId, owner FROM dfprograms_1__AccessGroupOwner"), "(uint256,bytes32)");
    for (uint256 i = 0; i < accessGroupOwners.rows.length; i++) {
      bytes memory row = accessGroupOwners.rows[i];
      (uint256 groupId, bytes32 owner) = abi.decode(row, (uint256, bytes32));

      AccessGroupOwner.set(groupId, EntityId.wrap(owner));
    }

    IndexerResult memory accessGroupMembers = recordingQuery(
      string.concat("SELECT groupId, member, hasAccess FROM dfprograms_1__AccessGroupMembe"), "(uint256,bytes32,bool)"
    );
    for (uint256 i = 0; i < accessGroupMembers.rows.length; i++) {
      bytes memory row = accessGroupMembers.rows[i];
      (uint256 groupId, bytes32 member, bool hasAccess) = abi.decode(row, (uint256, bytes32, bool));

      AccessGroupMember.set(groupId, EntityId.wrap(member), hasAccess);
    }

    IndexerResult memory entityAccessGroups =
      recordingQuery(string.concat("SELECT entityId, groupId FROM dfprograms_1__EntityAccessGrou"), "(bytes32,uint256)");
    for (uint256 i = 0; i < entityAccessGroups.rows.length; i++) {
      bytes memory row = entityAccessGroups.rows[i];
      (bytes32 entityId, uint256 groupId) = abi.decode(row, (bytes32, uint256));

      EntityAccessGroup.set(EntityId.wrap(entityId), groupId);
    }

    IndexerResult memory textSignContents =
      recordingQuery(string.concat("SELECT entityId, content FROM dfprograms_1__TextSignContent"), "(bytes32,string)");
    for (uint256 i = 0; i < textSignContents.rows.length; i++) {
      bytes memory row = textSignContents.rows[i];
      (bytes32 entityId, string memory content) = abi.decode(row, (bytes32, string));

      TextSignContent.set(EntityId.wrap(entityId), content);
    }

    IndexerResult memory entityPrograms =
      recordingQuery(string.concat("SELECT entityId, program FROM EntityProgram"), "(bytes32,bytes32)");
    for (uint256 i = 0; i < entityPrograms.rows.length; i++) {
      bytes memory row = entityPrograms.rows[i];
      (bytes32 entityId, bytes32 program) = abi.decode(row, (bytes32, bytes32));
      ResourceId newProgram = getNewResourceId(ResourceId.wrap(program));
      if (newProgram.unwrap() == program) {
        continue;
      }

      EntityProgram.set(EntityId.wrap(entityId), ProgramId.wrap(newProgram.unwrap()));
    }

    console.log("\nMigration Complete!");
  }
}

function getNewResourceId(ResourceId program) pure returns (ResourceId) {
  ResourceId oldFFProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: OLD_NAMESPACE, name: "ForceFieldProgra" });
  ResourceId newFFProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: NEW_NAMESPACE, name: "ForceFieldProgra" });

  if (program.unwrap() == oldFFProgramId.unwrap()) {
    return newFFProgramId;
  }

  ResourceId oldChestProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: OLD_NAMESPACE, name: "ChestProgram" });
  ResourceId newChestProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: NEW_NAMESPACE, name: "ChestProgram" });

  if (program.unwrap() == oldChestProgramId.unwrap()) {
    return newChestProgramId;
  }

  ResourceId oldBedProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: OLD_NAMESPACE, name: "BedProgram" });
  ResourceId newBedProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: NEW_NAMESPACE, name: "BedProgram" });

  if (program.unwrap() == oldBedProgramId.unwrap()) {
    return newBedProgramId;
  }

  ResourceId oldSpawnTileProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: OLD_NAMESPACE, name: "SpawnTileProgram" });
  ResourceId newSpawnTileProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: NEW_NAMESPACE, name: "SpawnTileProgram" });

  if (program.unwrap() == oldSpawnTileProgramId.unwrap()) {
    return newSpawnTileProgramId;
  }

  ResourceId oldTextSignProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: OLD_NAMESPACE, name: "TextSignProgram" });
  ResourceId newTextSignProgramId =
    WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: NEW_NAMESPACE, name: "TextSignProgram" });

  if (program.unwrap() == oldTextSignProgramId.unwrap()) {
    return newTextSignProgramId;
  }

  return program;
}
