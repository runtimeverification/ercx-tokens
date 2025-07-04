// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC721/Light/ERC721Test.sol";

/**
 * @dev This contract can test arbitrary deployed ERC721 contracts.
 *      export INFURA_API_KEY=0123456789
 *      export ERCx_ADDRESS=0xE4B91fAf8810F8895772E7cA065D4CB889120f94
 *      forge test --fork-url https://mainnet.infura.io/v3/$INFURA_API_KEY --match-contract ERC721PostDeploymentTest --ffi
 *
 */
contract ERC721PostDeploymentTest is ERC721Test {
    function setUp() public virtual {
        init(vm.envAddress("ERCx_ADDRESS"));
    }

    function init(address _token) internal virtual override(ERC721Test) {
        ERC721Test.init(_token);
    }
}
