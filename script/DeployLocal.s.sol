// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/GitbountiesNFT.sol";
import "../src/Gitbounties6551Implementation.sol";
import "../src/ERC6551Registry.sol";

contract DeployLocalScript is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ERC6551Registry registry = new ERC6551Registry();
        Gitbounties6551Implementation gitbounties6551Implementation = new Gitbounties6551Implementation();
        GitbountiesNFT gitbountiesNFT = new GitbountiesNFT(
            address(gitbounties6551Implementation),
            address(registry)
        );

        vm.stopBroadcast();
    }
}
