// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC1155/ERC1155Test.sol";

/**
 * @dev This contract can test arbitrary deployed ERC1155 contracts.
 *      export INFURA_API_KEY=0123456789
 *      export ERCx_ADDRESS=0x76BE3b62873462d2142405439777e971754E8E77
 *      forge test --fork-url https://mainnet.infura.io/v3/$INFURA_API_KEY --match-contract ERC1155PostDeploymentTest --ffi
 *
 */
contract ERC1155PostDeploymentTest is ERC1155Test {
    function setUp() public virtual {
        init(vm.envAddress("ERCx_ADDRESS"));
    }

    function init(address _token) internal virtual override(ERC1155Test) {
        ERC1155Test.init(_token);
    }
}
