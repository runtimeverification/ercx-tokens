// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC20/Light/ERC20Test.sol";

contract ZeroAddressTest is ERC20Test {
    function setUp() public {
        address tokenAddress = address(0);
        ERC20Test.init(tokenAddress);
    }
}
