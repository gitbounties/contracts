// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/GitbountiesNFT.sol";
import "../src/Gitbounties6551Implementation.sol";
import "../src/interfaces/IERC6551Registry.sol";

contract DeployScript is Script {
    IERC6551Registry goerliRegistry =
        IERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Gitbounties6551Implementation gitbounties6551Implementation = new Gitbounties6551Implementation();
        GitbountiesNFT gitbountiesNFT = new GitbountiesNFT(
            address(gitbounties6551Implementation),
            address(goerliRegistry)
        );

        vm.stopBroadcast();
    }
}
