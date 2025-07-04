// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC1155Standard.sol";
import "./ERC1155Security.sol";
import "./ERC1155Features.sol";

abstract contract ERC1155Test is ERC1155Standard, ERC1155Security, ERC1155Features {
    function init(address token) internal virtual override {
        ERC1155Abstract.init(token);
    }
}
