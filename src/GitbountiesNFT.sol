// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Base64} from "base64-sol/base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./lib/ERC6551AccountLib.sol";
import "./interfaces/IERC6551Registry.sol";

contract GitbountiesNFT is ERC721 {
    using Strings for uint256;

    uint256 public totalTokens; // The total number of bounties minted on this contract, for token indexing
    address public immutable implementation; // Gitbounties6551Implementation address
    address public immutable oracle;
    IERC6551Registry public immutable registry; // The 6551 registry address
    uint public immutable chainId = block.chainid; // The chainId of the network this contract is deployed
    address public immutable tokenContract = address(this); // The address of this contract
    uint salt = 0; // The salt to generate the account address

    constructor(
        address _implemenetaion,
        address _registry,
        address _oracle
    ) ERC721("GitbountiesNFT", "Bounties") {
        implementation = _implemenetaion;
        oracle = _oracle;
        registry = IERC6551Registry(_registry);
    }

    function getAccount(uint tokenId) public view returns (address) {
        return registry.account(implementation, chainId, tokenContract, tokenId, salt);
    }

    function createAccount(uint tokenId) public returns (address) {
        return registry.createAccount(implementation, chainId, tokenContract, tokenId, salt, "");
    }

    function mint() external payable {
        _safeMint(msg.sender, ++totalTokens);
        approve(oracle, totalTokens);
    }

    function addETH(uint tokenId) external payable {
        address account = getAccount(tokenId);
        (bool success, ) = account.call{value: msg.value}("");
        require(success, "Failed to send ETH");
    }

    function transferToken(uint tokenId, address receiver) external payable {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, receiver, tokenId, 1);

        owner = ownerOf(tokenId);
        safeTransferFrom(owner, receiver, tokenId);

        _afterTokenTransfer(owner, receiver, tokenId, 1);
    }

    function burn(uint tokenId) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        owner = ownerOf(tokenId);
        address account = createAccount(tokenId);
        safeTransferFrom(owner, account, tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    function resolveBounty(uint tokenId, address receiver) external payable {
        this.transferToken(tokenId, receiver);
        this.burn(tokenId);
    }
}
