// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC4626/Light/ERC4626Test.sol";

contract XMPLTest is ERC4626Test {
    function setUp() public {
        address tokenAddress = 0x4937A209D4cDbD3ecD48857277cfd4dA4D82914c;
        ERC4626Test.init(tokenAddress);
    }
}
