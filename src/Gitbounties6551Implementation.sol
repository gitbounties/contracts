// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "openzeppelin-contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";
import "openzeppelin-contracts/token/ERC1155/IERC1155Receiver.sol";
import "openzeppelin-contracts/interfaces/IERC1271.sol";

//6551 references
import "erc6551/src/interfaces/IERC6551Account.sol";
import "erc6551/src/lib/ERC6551AccountLib.sol";

contract Gitbounties6551Implementation is IERC165, IERC1271, IERC6551Account, IERC721Receiver {

    //// ERRORS ////
    error GitbountiesDoesNotAccept721s();
    error GitbountiesDoesNotAccept1155s();
    ////////////////

    event BountiesAdded(address indexed sender, uint256 amount, uint256 newBalance);

    event BountiesReduced(address indexed recipient, uint256 amount, uint256 newBalance);

    event IssueResolved(address indexed recipient, uint256 amount);

    function nonce() external pure returns (uint256) {
        return (0);
    }

    function state() external pure returns (uint256) {
        return (0);
    }

    receive() external payable {
        emit BountiesAdded(msg.sender, msg.value, address(this).balance);
    }

    function executeCall(
        address to,
        uint256 amount,
        bytes calldata data
    ) external payable returns (bytes memory result) {
        require(_isValidSigner(msg.sender), "Invalid signer");

        // address payable currentOwner = payable(to);
        // (bool success, bytes memory result) = currentOwner.call{ value: amount }(data);
        bool success;
        (success, result) = to.call{ value: amount }(data);
        
        require(success, "Failed to reduce Bounties");
        uint newBalance = address(this).balance;
        emit BountiesReduced(to, amount, newBalance);
    }


    function token()
        public
        view
        returns (uint256 chainId, address tokenContract, uint256 tokenId)
    {
        return ERC6551AccountLib.token();
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this
            .token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    function onERC721Received(
        address /*operator*/,
        address from,
        uint256 tokenId,
        bytes calldata /*data*/
    ) external override returns (bytes4) {
        (uint256 nftChainId, address nftAddress, uint256 nftId) = token();
        if (
            nftChainId != block.chainid ||
            tokenId != nftId ||
            msg.sender != nftAddress
        ) {
            revert GitbountiesDoesNotAccept721s();
        } else {
            address payable formerOwner = payable(from);
            uint finalBalance = address(this).balance;
            (bool sent, ) = formerOwner.call{ value: finalBalance }("");
            require(sent, "Failed to send Bounties");
            emit IssueResolved(formerOwner, finalBalance);
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*id*/,
        uint256 /*value*/,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        revert GitbountiesDoesNotAccept1155s();
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }
         
        return "";
    }
}
