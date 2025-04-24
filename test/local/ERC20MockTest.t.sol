// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.6.2 <0.9.0;
pragma solidity =0.8.20;

import "ercx/ERC20/Light/ERC20Test.sol";
import {ERC20Mock} from "openzeppelin-contracts/mocks/ERC20Mock.sol";

contract ERC20MockTest is ERC20Test {

    function setUp() public {
        ERC20Mock token = new ERC20Mock();
        token.mint(address(this), 1000e18);
        ERC20Test.init(address(token));
    }

}