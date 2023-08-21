// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GitbountiesNFT.sol";
import "../src/Gitbounties6551Implementation.sol";
import "../src/interfaces/IERC6551Registry.sol";



contract Gitbounties6551ImplementationTest is Test {
    address deployer = address(420);
    address minter = address(69);
    //  Setup vars
    uint256 constant FORK_BLOCK_NUMBER = 9236519; // All tests executed at this block
    string GOERLI_RPC_URL = "GOERLI_RPC_URL";
    uint256 forkId =
        vm.createSelectFork(vm.envString(GOERLI_RPC_URL), FORK_BLOCK_NUMBER);

    IERC6551Registry goerliRegistry;

    Gitbounties6551Implementation gitbounties6551Implementation;
    GitbountiesNFT gitbountiesNFT;

    function setUp() public {
        vm.deal(deployer, 1000 ether);
        vm.deal(minter, 1000 ether);
        vm.startPrank(deployer, deployer);
        goerliRegistry = IERC6551Registry(
            0x02101dfB77FDE026414827Fdc604ddAF224F0921
        );
        gitbounties6551Implementation = new Gitbounties6551Implementation();
        gitbountiesNFT = new GitbountiesNFT(
            address(gitbounties6551Implementation),
            address(goerliRegistry)
        );
        vm.stopPrank();
    }

    function testMint() public {
        vm.startPrank(minter, minter);
        gitbountiesNFT.mint{value: 1000000000000}();
        vm.stopPrank();
        // check that nft 1 exists
    }

    function testCreateAccount() public {
        address nftAccount = goerliRegistry.account(
            address(gitbounties6551Implementation),
            5,
            address(gitbountiesNFT),
            1,
            0
        );
    }

    function testGetAccount() public {
        testMint();
        address accountAccordingToNFT = gitbountiesNFT.getAccount(1);
        address accountAccordingToRegistry = goerliRegistry.account(
            address(gitbounties6551Implementation),
            31337, // HEVM chainId for some reason
            address(gitbountiesNFT),
            1,
            0
        );
        assertEq(accountAccordingToNFT, accountAccordingToRegistry);
    }

    function testAddBounties() public {
        testMint();
        vm.startPrank(minter, minter);
        gitbountiesNFT.getAccount(1).call{value: 1.2345 ether}("");
        vm.stopPrank();
    }

    function testAddMoreBounties() public {
        testAddBounties();
        vm.startPrank(minter, minter);
        gitbountiesNFT.getAccount(1).call{value: 100.1 ether}("");
        vm.stopPrank();
    }

    function testAddEvenMoreBounties() public {
        testAddMoreBounties();
        vm.startPrank(minter, minter);
        gitbountiesNFT.getAccount(1).call{value: 100.14494949 ether}("");
        vm.stopPrank();
    }
}
