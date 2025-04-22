// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC4626Standard.sol";
// import "../ERC4626Security.sol";
// import "./ERC4626Features.sol";

abstract contract ERC4626Test is
    ERC4626Standard
    // ERC4626Security
    // ERC4626Features 
    {
    function init(address token) internal virtual override {
        ERC4626Abstract.init(token);
    }
}