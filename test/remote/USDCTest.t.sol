// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC20/Light/ERC20Test.sol";

contract USDCTest is ERC20Test {
    function setUp() public {
        address tokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        ERC20Test.init(tokenAddress);
    }
}
