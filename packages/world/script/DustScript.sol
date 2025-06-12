// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract DustScript is Script {
  function startBroadcast() internal {
    // Start broadcasting transactions from the deployer account
    address[] memory wallets = vm.getWallets();
    if (wallets.length > 0) {
      console.log("Using unlocked wallet %s", wallets[0]);
      vm.startBroadcast(wallets[0]);
    } else {
      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
      console.log("Using private key wallet %s", vm.addr(deployerPrivateKey));
      vm.startBroadcast(deployerPrivateKey);
    }
  }

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }
}
