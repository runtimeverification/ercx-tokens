// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC20/Light/ERC20Test.sol";

contract USDTTest is ERC20Test {
    function setUp() public {
        address tokenAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        ERC20Test.init(tokenAddress);
    }
}
