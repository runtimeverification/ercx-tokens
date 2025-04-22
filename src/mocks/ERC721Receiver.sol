// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721Receiver is IERC721Receiver {

    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}