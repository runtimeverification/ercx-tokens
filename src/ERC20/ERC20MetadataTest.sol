// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @dev This test contract extracts metadata from an ERC20 token.
/// @dev The information is contained in the JSON-output.
/// @dev forge test --match-path src/ERC20MetadataTest.sol --fork-url $FORK_URL --json --silent | json_pp
contract ERC20MetadataTest is Test {
    IERC20Metadata token;

    function setUp() public virtual {
        init(vm.envAddress("ERCx_ADDRESS"));
    }

    function init(address _token) internal virtual {
        token = IERC20Metadata(_token);
    }

    /// @dev We revert so that the decimals()-value will be included in the reason-field of the JSON output
    function testFailDecimals() public view {
        revert(vm.toString(token.decimals()));
    }

    /// @dev We revert so that the name()-value will be included in the reason-field of the JSON output
    function testFailName() public view {
        revert(token.name());
    }

    /// @dev We revert so that the symbol()-value will be included in the reason-field of the JSON output
    function testFailSymbol() public view {
        revert(token.symbol());
    }
}
