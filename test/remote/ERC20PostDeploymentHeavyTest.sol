// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC20/Heavy/ERC20Test.sol";
import "ercx/ERC20/ERC20MetadataTest.sol";

/**
 * @dev This contract can test arbitrary deployed ERC20 contracts.
 *      export INFURA_API_KEY=0123456789
 *      export ERCx_ADDRESS=0x014B50466590340D41307Cc54DCee990c8D58aa8
 *      forge test --fork-url https://mainnet.infura.io/v3/$INFURA_API_KEY --match-contract ERC20PostDeploymentTest --ffi
 *
 */
contract ERC20PostDeploymentTest is ERC20Test, ERC20MetadataTest {
    function setUp() public virtual override(ERC20MetadataTest) {
        init(vm.envAddress("ERCx_ADDRESS"));
    }

    function init(address _token) internal virtual override(ERC20Test, ERC20MetadataTest) {
        ERC20Test.init(_token);
        ERC20MetadataTest.init(_token);
    }
}
