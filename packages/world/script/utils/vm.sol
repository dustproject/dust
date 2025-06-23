// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { VmSafe as Vm } from "forge-std/Vm.sol";

Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

