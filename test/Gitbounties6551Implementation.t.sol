// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "../../lib/forge-std/src/Test.sol";
import "../../lib/reference/src/interfaces/IERC6551Account.sol";
import "../../lib/reference/src/interfaces/IERC6551Executable.sol";
import "../../lib/reference/src/ERC6551Registry.sol";
import "../../contracts/Gitbounties6551Implementation.sol";
import "../../lib/reference/test/mocks/MockERC721.sol";
import "../../lib/reference/test/mocks/MockERC6551Account.sol";

contract Gitbounties6551ImplementationTest is Test {
    ERC6551Registry public registry;
    Gitbounties6551Implementation public implementation;
    MockERC721 nft = new MockERC721();

    function setUp() public {
        registry = new ERC6551Registry();
        implementation = new Gitbounties6551Implementation();
    }

    function testDeploy() public {
        address deployedAccount = registry.createAccount(
            address(implementation),
            block.chainId,
            address(0),
            0,
            0,
            ""
        );
    }
}