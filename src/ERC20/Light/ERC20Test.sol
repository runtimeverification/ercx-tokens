// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC20Standard.sol";
import "./ERC20Security.sol";
import "./ERC20Features.sol";

abstract contract ERC20Test is
    ERC20Standard,
    ERC20Security,
    ERC20Features
    {

    function init(address token) internal virtual override {
        ERC20Abstract.init(token);
    }
}