// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC4626/Light/ERC4626Test.sol";
import {ERC20Mock} from "openzeppelin-contracts/mocks/ERC20Mock.sol";
import {ERC4626Mock} from "openzeppelin-contracts/mocks/ERC4626Mock.sol";

contract ERC4626MockTest is ERC4626Test {
    function setUp() public {
        ERC20Mock underlyingToken = new ERC20Mock();
        address underlyingTokenAddress = address(underlyingToken);
        ERC4626Mock token = new ERC4626Mock(underlyingTokenAddress);
        // give initial shares
        token.mint(address(this), 1e18);
        // give initial assets to the underlying token
        underlyingToken.mint(address(token), 1e18);
        ERC4626Test.init(address(token));
    }
}
