// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/interfaces/IERC6551Account.sol";
import "../src/interfaces/IERC6551Executable.sol";
import "../src/ERC6551Registry.sol";
import "../src/Gitbounties6551Implementation.sol";
import "./mocks/MockERC721.sol";
import "./mocks/MockERC6551Account.sol";

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
            block.chainid,
            address(0),
            0,
            0,
            ""
        );

        assertTrue(deployedAccount != address(0));

        address predictedAccount = registry.account(
            address(implementation),
            block.chainid,
            address(0),
            0,
            0
        );

        assertEq(predictedAccount, deployedAccount);
    }

    function testCall() public {
        nft.mint(vm.addr(1), 1);

        address account = registry.createAccount(
            address(implementation),
            block.chainid,
            address(nft),
            1,
            0,
            ""
        );

        assertTrue(account != address(0));

        IERC6551Account accountInstance = IERC6551Account(payable(account));
        IERC6551Executable executableAccountInstance = IERC6551Executable(account);

        assertEq(
            accountInstance.isValidSigner(vm.addr(1), ""),
            IERC6551Account.isValidSigner.selector
        );

        vm.deal(account, 1 ether);

        vm.prank(vm.addr(1));
        executableAccountInstance.execute(payable(vm.addr(2)), 0.5 ether, "", 0);

        assertEq(account.balance, 0.5 ether);
        assertEq(vm.addr(2).balance, 0.5 ether);
    }
}