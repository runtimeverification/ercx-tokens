// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC4626/Heavy/ERC4626Test.sol";
import "ercx/ERC20/ERC20MetadataTest.sol";


/** @dev This contract can test arbitrary deployed ERC4626 contracts.
  *      export INFURA_API_KEY=0123456789
  *      export ERCx_ADDRESS=0xE4B91fAf8810F8895772E7cA065D4CB889120f94
  *      forge test --fork-url https://mainnet.infura.io/v3/$INFURA_API_KEY --match-contract ERC4626PostDeploymentTest --ffi
  **/
contract ERC4626PostDeploymentTest is ERC4626Test, ERC20MetadataTest {

    function setUp() public virtual override (ERC20MetadataTest) {
        init(
            vm.envAddress("ERCx_ADDRESS")
        );
    }

    function init(address _token) internal virtual override (ERC4626Test, ERC20MetadataTest) {
        ERC4626Test.init(_token);
        ERC20MetadataTest.init(_token);
    }

}