// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721IncorrectReceiver is IERC721Receiver {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    /**
     * Returns a modified version of the standard `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        uint8 cases = 4;
        uint256 randomMistakeNumber = _getRandomNumber(cases);
        if (randomMistakeNumber == 1) {
            // Omit the first address parameter
            return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
        } else if (randomMistakeNumber == 2) {
            // Omit the second address parameter
            return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
        } else if (randomMistakeNumber == 3) {
            // Omit the uint256 parameter
            return bytes4(keccak256("onERC721Received(address,address,bytes)"));
        } else if (randomMistakeNumber == 4) {
            // Omit the bytes parameter
            return bytes4(keccak256("onERC721Received(address,address,uint256)"));
        } else if (randomMistakeNumber == 5) {
            // Swap the first and second address parameters
            return bytes4(keccak256("onERC721Received(uint256,address,bytes)"));
        } else if (randomMistakeNumber == 6) {
            // Swap the first address and uint256 parameters
            return bytes4(keccak256("onERC721Received(uint256,address,bytes)"));
        } else if (randomMistakeNumber == 7) {
            // Swap the first address and bytes parameters
            return bytes4(keccak256("onERC721Received(bytes,address,uint256)"));
        } else if (randomMistakeNumber == 8) {
            // Swap the second address and uint256 parameters
            return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
        } else if (randomMistakeNumber == 9) {
            // Swap the second address and bytes parameters
            return bytes4(keccak256("onERC721Received(address,bytes,uint256)"));
        } else if (randomMistakeNumber == 10) {
            // Swap the uint256 and bytes parameters
            return bytes4(keccak256("onERC721Received(address,address,uint256)"));
        } else if (randomMistakeNumber == 11) {
            // Omit the first address and the second address parameters
            return bytes4(keccak256("onERC721Received(uint256,uint256,bytes)"));
        } else if (randomMistakeNumber == 12) {
            // Omit the first address and the uint256 parameters
            return bytes4(keccak256("onERC721Received(uint256,address,address,bytes)"));
        } else if (randomMistakeNumber == 13) {
            // Omit the first address and the bytes parameter
            return bytes4(keccak256("onERC721Received(uint256,address,uint256)"));
        } else if (randomMistakeNumber == 14) {
            // Omit the second address and the uint256 parameters
            return bytes4(keccak256("onERC721Received(address,uint256,address,bytes)"));
        } else if (randomMistakeNumber == 15) {
            // Omit the second address and the bytes parameter
            return bytes4(keccak256("onERC721Received(address,uint256,uint256)"));
        } else if (randomMistakeNumber == 16) {
            // Omit the uint256 and bytes parameters
            return bytes4(keccak256("onERC721Received(address,address,address)"));
        } else {
            return bytes4(keccak256("onERC721Received()"));
        }
    }

    function _getRandomNumber(uint8 upperBound) internal view returns (uint256) {
        // Get the hash of the last block
        bytes32 blockHash = blockhash(block.number - 1);

        // Use the block hash to generate a pseudo-random number
        uint256 randomNumber = uint256(blockHash) % upperBound;

        return randomNumber;
    }
}
