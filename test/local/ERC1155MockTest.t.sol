// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC1155/ERC1155Test.sol";
import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";

contract ERC1155MockTest is ERC1155Test {
    function setUp() public {
        ERC1155 token = new ERC1155("ERC1155Mock");
        ERC1155Test.init(address(token));
    }
}
