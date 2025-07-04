// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC20Standard.sol";
//import "./ERC20Recommended.sol";
//import "./ERC20Desirable.sol";
//import "./ERC20Features.sol";

abstract contract ERC20TestNoAddOn is ERC20Standard {
    //    ERC20Desirable,
    //    ERC20Features

    function init(address token) internal virtual override {
        ERC20Abstract.init(token);
    }
}
