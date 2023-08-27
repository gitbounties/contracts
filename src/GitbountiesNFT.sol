// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Base64} from "base64-sol/base64.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "erc6551/src/lib/ERC6551AccountLib.sol";
import "erc6551/src/interfaces/IERC6551Registry.sol";

contract GitbountiesNFT is ERC721 {
    using Strings for uint256;

    // TODO store this data off chain
    struct Metadata {
        // Title of the issue
        string title;
        /// Owner of the repository (OWNER/REPO)
        string owner;
        /// Name of the repository (OWNER/REPO)
        string repo;
    }

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
        uint256 tokenId = ++totalTokens;

        _safeMint(msg.sender, tokenId);

        // approve the oracle wallet when the token is minted
        approve(oracle, tokenId);
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

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        super._afterTokenTransfer(from, to, firstTokenId, 1);
        // need to approve the oracle again after the transfer
        _approve(oracle, firstTokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        address account = getAccount(tokenId);

        // TODO hardcoded for now
        bytes memory image = abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="256" height="256" xmlns="http://www.w3.org/2000/svg">',
                        '  <defs>',
                        '    <linearGradient id="textGradient" x1="0%" y1="0%" x2="100%" y2="100%">',
                        '      <stop offset="1.84%" stop-color="#ae67fa" />',
                        '      <stop offset="102.67%" stop-color="#f49867" />',
                        '    </linearGradient>',
                        '    <radialGradient id="radGradient" cx="50%" cy="50%">',
                        '      <stop offset="0%" stop-color="rgba(0, 40, 83, 1)" />',
                        '      <stop offset="50%" stop-color="rgba(4, 12, 24, 1)" />',
                        '    </radialGradient>',
                        '  </defs>',
                        '  <style>',
                        '    :root {',
                        '        --text-color: #E5E7EB;',
                        '    }',
                        '    text {',
                        '        font-family: "Open Sans", Arial, sans-serif;',
                        '    }',
                        '    .normal-text {',
                        '        fill: var(--text-color);',
                        '        white-space: normal;',
                        '        word-wrap: break-word;',
                        '        max-width: 256px;',
                        '    }',
                        '  </style>',
                        '  <rect x="0" y="0" width="256" height="256" fill="url(#radGradient)"/>',
                        '  <text x="145" y="20" font-size="16" fill="url(#textGradient)" id="logo-text">',
                        '    GITBOUNTIES',
                        '  </text>',
                        '  <text x="128" y="110" font-size="10" class="normal-text" text-anchor="middle" >',
                        '    MrPicklePinosaur/shrs',
                        '  </text>',
                        '  <text x="128" y="128" font-size="16" class="normal-text" lengthAdjust="spacingAndGlyphs" text-anchor="middle" >',
                        '    [Bug]: Nesting shrs breaks exit command',
                        '  </text>',
                        '  <text x="128" y="200" font-size="24" text-anchor="middle" fill="#84CC16" >',
                        '    OPEN',
                        '  </text>',
                        '  <text x="128" y="240" font-size="10" class="normal-text" text-anchor="middle" >',
                        '    0.01 ETH',
                        '  </text>',
                        '</svg>'
                    )
                )
            )
        );

        // check if bounty has been closed
        // if (ownerOf(tokenId) == account) {
        // } else {}

        string memory uri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"GITBOUNTIES", "image":"',
                            image,
                            '",',
                            '"description": "A bounty for an open source contribution. Solve it to get the reward!",',
                            '"attributes":[{"trait_type":"Balance","value":"',
                            '0.0', // TODO: fetch the value inside the bounty
                            ' ETH"},{"trait_type":"Status","value":"Open"}]',
                            '}'
                        )
                    )
                )
            )
        );
        return uri;
    }

}
