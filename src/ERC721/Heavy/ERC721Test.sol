// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC721Standard.sol";
import "./ERC721Security.sol";
import "./ERC721Features.sol";

abstract contract ERC721Test is
  ERC721Standard,
  ERC721Security,
  ERC721Features
  {
    function init(address token) internal virtual override {
        ERC721Abstract.init(token);
    }

}
