// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERCAbstract.sol";
import "openzeppelin-contracts/interfaces/IERC4626.sol";
import "openzeppelin-contracts/utils/math/Math.sol";

/// @notice Abstract contract that defines internal functions that are used in ERC4626 test suite
abstract contract ERC4626Abstract is ERCAbstract {
    /**
     *
     * Glossary                                                                         *
     * -------------------------------------------------------------------------------- *
     * tokenSender   : address that sends tokens (usually in a transaction)             *
     * tokenReceiver : address that receives tokens (usually in a transaction)          *
     * tokenApprover : address that approves tokens (usually in an approval)            *
     * tokenApprovee : address that tokenApprover approves of (usually in an approval)  *
     *
     */

    /**
     *
     *
     * Declaration of state variables and events
     *
     *
     */

    // IERC4626 interface from Openzeppelin
    IERC4626 public cut4626;
    address assetAddress;
    IERC20 public asset;

    // Error tolerance
    uint256 internal delta = 0;

    // Some events, expected to be emitted from the contract.
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    function init(address token) internal virtual {
        cut4626 = IERC4626(token);
        assetAddress = cut4626.asset();
        asset = IERC20(assetAddress);
    }

    /**
     *
     *
     * Maximum values
     *
     *
     */
    function maxShares() internal view virtual returns (uint256) {
        return MAX_UINT256;
    }

    function maxAssets() internal view virtual returns (uint256) {
        return MAX_UINT256;
    }

    /**
     *
     *
     * Additional assertions
     *
     *
     */
    function assertApproxGeAbs(uint256 a, uint256 b, uint256 maxDelta) internal {
        if (!(a >= b)) {
            assertGe(b - a, maxDelta);
        }
    }

    function assertApproxGeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
        if (!(a >= b)) {
            assertGe(b - a, maxDelta, err);
        }
    }

    function assertApproxLeAbs(uint256 a, uint256 b, uint256 maxDelta) internal {
        if (!(a <= b)) {
            assertLe(a - b, maxDelta);
        }
    }

    function assertApproxLeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
        if (!(a <= b)) {
            assertLe(a - b, maxDelta, err);
        }
    }

    /**
     *
     *
     * Initialization modifier
     *
     *
     */

    /// @notice Parameterized initialization of the underlying assets of two dummy users,
    /// `aliceAssetsBalance` -> `alice` and `bobAssetsBalance` -> `bob`.
    modifier initializeAssetsTwoUsers(uint256 aliceAssetsBalance, uint256 bobAssetsBalance) {
        vm.assume(aliceAssetsBalance <= Math.saturatingSub(maxAssets(), bobAssetsBalance));
        vm.assume(asset.totalSupply() <= Math.saturatingSub(maxAssets(), aliceAssetsBalance + bobAssetsBalance));
        // Give aliceAssetsBalance tokens to Alice
        (bool dealSuccessAlice,) = _dealERC20Token(assetAddress, alice, aliceAssetsBalance);
        // Skip the test if we cannot deal assets to Alice
        conditionalSkip(!dealSuccessAlice, "Inconclusive test: Issue with dealing assets for dummy user, Alice.");
        // Give bobAssetsBalance tokens to Bob
        (bool dealSuccessBob,) = _dealERC20Token(assetAddress, bob, bobAssetsBalance);
        // Skip the test if we cannot deal assets to Bob
        conditionalSkip(!dealSuccessBob, "Inconclusive test: Issue with dealing assets for dummy user, Bob.");
        _;
    }

    /// @notice Parameterized initialization of the shares of two dummy users,
    /// `aliceSharesBalance` -> `alice` and `bobSharesBalance` -> `bob`.
    modifier initializeSharesTwoUsers(uint256 aliceSharesBalance, uint256 bobSharesBalance) {
        vm.assume(aliceSharesBalance <= Math.saturatingSub(maxShares(), bobSharesBalance));
        vm.assume(cut4626.totalSupply() <= Math.saturatingSub(maxShares(), aliceSharesBalance + bobSharesBalance));
        // Deal Alice enough assets to self mint shares' balance
        dealAssetsAndMintShares(alice, aliceSharesBalance);
        // Deal Bob enough assets to self mint shares' balance
        dealAssetsAndMintShares(bob, bobSharesBalance);
        _;
    }

    /// @notice Parameterized initialization of the underlying assets of one dummy user,
    /// `userAssetsBalance` -> `user`.
    modifier initializeAssetsOneNonZeroAddress(address user, uint256 userAssetsBalance) {
        vm.assume(user != address(0x0));
        vm.assume(userAssetsBalance <= Math.saturatingSub(maxAssets(), asset.totalSupply()));
        // Give user1AssetsBalance tokens to user
        (bool dealSuccess,) = _dealERC20Token(assetAddress, user, userAssetsBalance);
        // Skip the test if we cannot deal assets to user
        conditionalSkip(!dealSuccess, "Inconclusive test: Issue with dealing assets for dummy user.");
        _;
    }

    /// @notice Parameterized initialization of the underlying assets of two dummy users,
    /// `user1AssetsBalance` -> `user1` and `user2AssetsBalance` -> `user2`.
    modifier initializeAssetsTwoUniqueNonZeroAddresses(
        address user1,
        address user2,
        uint256 user1AssetsBalance,
        uint256 user2AssetsBalance
    ) {
        vm.assume(user1 != address(0x0));
        vm.assume(user2 != address(0x0));
        vm.assume(user1 != user2);
        vm.assume(user1AssetsBalance <= Math.saturatingSub(maxAssets(), user2AssetsBalance));
        vm.assume(asset.totalSupply() <= Math.saturatingSub(maxAssets(), user1AssetsBalance + user2AssetsBalance));
        // Give user1AssetsBalance tokens to user 1
        (bool dealSuccess1,) = _dealERC20Token(assetAddress, user1, user1AssetsBalance);
        // Skip the test if we cannot deal assets to user 1
        conditionalSkip(!dealSuccess1, "Inconclusive test: Issue with dealing assets for dummy user 1.");
        // Give user2AssetsBalance tokens to user 2
        (bool dealSuccess2,) = _dealERC20Token(assetAddress, user2, user2AssetsBalance);
        // Skip the test if we cannot deal assets to user 2
        conditionalSkip(!dealSuccess2, "Inconclusive test: Issue with dealing assets for dummy user 2.");
        _;
    }

    /// @notice Parameterized initialization of the shares of one dummy user,
    /// `userSharesBalance` -> `user`.
    modifier initializeSharesOneNonZeroAddress(address user, uint256 userSharesBalance) {
        vm.assume(user != address(0x0));
        vm.assume(userSharesBalance <= Math.saturatingSub(maxShares(), cut4626.totalSupply()));
        // Deal user enough assets to self mint shares' balance
        dealAssetsAndMintShares(user, userSharesBalance);
        _;
    }

    /// @notice Parameterized initialization of the shares of two dummy users,
    /// `user1SharesBalance` -> `user1` and `user2SharesBalance` -> `user2`.
    modifier initializeSharesTwoUniqueNonZeroAddresses(
        address user1,
        address user2,
        uint256 user1SharesBalance,
        uint256 user2SharesBalance
    ) {
        vm.assume(user1 != address(0x0));
        vm.assume(user2 != address(0x0));
        vm.assume(user1 != user2);
        vm.assume(user1SharesBalance <= Math.saturatingSub(maxShares(), user2SharesBalance));
        vm.assume(cut4626.totalSupply() <= Math.saturatingSub(maxShares(), user1SharesBalance + user2SharesBalance));
        // Deal user 1 enough assets to self mint shares' balance
        dealAssetsAndMintShares(user1, user1SharesBalance);
        // Deal user 2 enough assets to self mint shares' balance
        dealAssetsAndMintShares(user2, user2SharesBalance);
        _;
    }

    /// @notice Deal enough assets to `user` and she self mints `userSharesBalance`
    function dealAssetsAndMintShares(address user, uint256 userSharesBalance) internal {
        // Make sure that the user does not possess any initial share
        // Otherwise, we will be minting extra shares to her
        // Note: This assumption is important especially for fuzzed address as it
        // may contain some initial shares.
        vm.assume(cut4626.balanceOf(user) == 0);
        // If `userSharesBalance` is to be initialized to zero, we will skip the following
        if (userSharesBalance != 0) {
            // shares overflow restriction on userSharesBalance
            if (cut4626.totalSupply() > 0) {
                vm.assume(userSharesBalance < maxShares() / (cut4626.totalAssets() + 1));
            }
            // Give user assets to exchange for shares
            (bool dealSuccess,) = _dealERC20Token(assetAddress, user, cut4626.previewMint(userSharesBalance));
            // Skip the test if we cannot deal assets to user
            conditionalSkip(!dealSuccess, "Inconclusive test: Issue with dealing assets for dummy user.");
            // User self mints shares
            (bool callMint,) = tryCallerMintSharesToReceiverWithChecksAndApproval(user, userSharesBalance, user);
            // Skip the test if we cannot mint shares to user
            conditionalSkip(!callMint, "Inconclusive test: Issue with minting shares for dummy user.");
        }
    }

    /// @notice To prevent assets overflow in functions such as `convertToShares`
    /// When converting from assets to shares, the amount of assets is multipled by the totalSupply.
    /// Hence, to avoid integer overflow, we need to make sure assets < maxAssets() / totalSupply.
    /// @dev Limit for overflow is reference from Solmate EIP-4626 and OZ ERC4626.sol.
    modifier assetsOverflowRestriction(uint256 assets) {
        if (cut4626.totalSupply() > 0) {
            vm.assume(assets < maxAssets() / cut4626.totalSupply());
        }
        _;
    }

    /// @notice To prevent shares overflow in functions such as `convertToAssets`
    /// When converting from shares to assets, the amount of shares is multipled by the totalAssets + 1
    /// (OZ implementation). Hence, to avoid integer overflow, we need to make sure
    /// shares < maxShares() / (totalAssets + 1).
    /// @dev Limit for overflow is reference from OZ ERC4626.sol
    /// NOTE: Limit for overflow from Solmate EIP-4626 is shares < maxShares() / totalAssets instead
    modifier sharesOverflowRestriction(uint256 shares) {
        if (cut4626.totalSupply() > 0) {
            vm.assume(shares < maxShares() / (cut4626.totalAssets() + 1));
        }
        _;
    }

    /**
     *
     *
     * assets helper functions.
     *
     *
     */

    /// @notice Try calling `approve` function for `tokenApprovee` an an `amount` of assets
    function tryApproveApproveeAssets(address tokenApprovee, uint256 amount) internal returns (bool, bool) {
        bytes memory data = abi.encodeWithSelector(asset.approve.selector, tokenApprovee, amount);
        (bool success, bytes memory returnData) = assetAddress.call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `approve` function for `tokenApprovee` an `amount` of assets
    function tryCallerApproveApproveeAssets(address caller, address tokenApprovee, uint256 amount)
        internal
        returns (bool, bool)
    {
        vm.startPrank(caller);
        (bool success, bool result) = tryApproveApproveeAssets(tokenApprovee, amount);
        vm.stopPrank();
        return (success, result);
    }

    /// @notice Try calling `transfer` function to `tokenReceiver` an `amount` of assets
    function tryTransferReceiverAssets(address tokenReceiver, uint256 amount) internal returns (bool, bool) {
        bytes memory data = abi.encodeWithSelector(asset.transfer.selector, tokenReceiver, amount);
        (bool success, bytes memory returnData) = assetAddress.call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `transfer` function to `tokenReceiver` an `amount` of assets
    function tryCallerTransferReceiverAssets(address caller, address tokenReceiver, uint256 amount)
        internal
        returns (bool, bool)
    {
        vm.startPrank(caller);
        (bool success, bool result) = tryTransferReceiverAssets(tokenReceiver, amount);
        vm.stopPrank();
        return (success, result);
    }

    /// @notice Try calling `transferFrom` function from `tokenSender` to `tokenReceiver` an `amount` of assets
    function tryTransferFromSenderToReceiverAssets(address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (bool, bool)
    {
        bytes memory data = abi.encodeWithSelector(asset.transferFrom.selector, tokenSender, tokenReceiver, amount);
        (bool success, bytes memory returnData) = assetAddress.call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `transferFrom` function from `tokenSender` to `tokenReceiver` an `amount` of assets
    function tryCallerTransferFromSenderToReceiverAssets(
        address caller,
        address tokenSender,
        address tokenReceiver,
        uint256 amount
    ) internal returns (bool, bool) {
        vm.startPrank(caller);
        (bool success, bool result) = tryTransferFromSenderToReceiverAssets(tokenSender, tokenReceiver, amount);
        vm.stopPrank();
        return (success, result);
    }

    /**
     *
     *
     * shares helper functions.
     *
     *
     */

    /// @notice Try calling `approve` function for `tokenApprovee` an an `amount` of shares
    function tryApproveApproveeShares(address tokenApprovee, uint256 amount) internal returns (bool, bool) {
        bytes memory data = abi.encodeWithSelector(cut4626.approve.selector, tokenApprovee, amount);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `approve` function for `tokenApprovee` an `amount` of shares
    function tryCallerApproveApproveeShares(address caller, address tokenApprovee, uint256 amount)
        internal
        returns (bool, bool)
    {
        vm.startPrank(caller);
        (bool success, bool result) = tryApproveApproveeShares(tokenApprovee, amount);
        vm.stopPrank();
        return (success, result);
    }

    /// @notice Try calling `transfer` function to `tokenReceiver` an `amount` of shares
    function tryTransferReceiverShares(address tokenReceiver, uint256 amount) internal returns (bool, bool) {
        bytes memory data = abi.encodeWithSelector(cut4626.transfer.selector, tokenReceiver, amount);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `transfer` function to `tokenReceiver` an `amount` of shares
    function tryCallerTransferReceiverShares(address caller, address tokenReceiver, uint256 amount)
        internal
        returns (bool, bool)
    {
        vm.startPrank(caller);
        (bool success, bool result) = tryTransferReceiverShares(tokenReceiver, amount);
        vm.stopPrank();
        return (success, result);
    }

    /// @notice Try calling `transferFrom` function from `tokenSender` to `tokenReceiver` an `amount` of shares
    function tryTransferFromSenderToReceiverShares(address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (bool, bool)
    {
        bytes memory data = abi.encodeWithSelector(cut4626.transferFrom.selector, tokenSender, tokenReceiver, amount);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `transferFrom` function from `tokenSender` to `tokenReceiver` an `amount` of shares
    function tryCallerTransferFromSenderToReceiverShares(
        address caller,
        address tokenSender,
        address tokenReceiver,
        uint256 amount
    ) internal returns (bool, bool) {
        vm.startPrank(caller);
        (bool success, bool result) = tryTransferFromSenderToReceiverShares(tokenSender, tokenReceiver, amount);
        vm.stopPrank();
        return (success, result);
    }

    /**
     *
     *
     * Helper functions for view functions of ERC-4626 vaults.
     *
     *
     */

    /// @notice Try calling `name` function
    function tryCallName() internal returns (bool, string memory) {
        bytes memory data = abi.encodeWithSelector(cut4626.name.selector);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        string memory returnValue;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (string));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `name` function
    /// Note: This function does not do any assumption check
    function tryCallerCallName(address caller) internal returns (bool callSuccess, string memory returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallName();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `symbol` function
    function tryCallSymbol() internal returns (bool, string memory) {
        bytes memory data = abi.encodeWithSelector(cut4626.symbol.selector);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        string memory returnValue;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (string));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `symbol` function
    /// Note: This function does not do any assumption check
    function tryCallerCallSymbol(address caller) internal returns (bool callSuccess, string memory returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallSymbol();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `vault.decimals` function
    function tryCallVaultDecimals() internal returns (bool, uint8) {
        bytes memory data = abi.encodeWithSelector(cut4626.decimals.selector);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint8 returnValue;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint8));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `vault.decimals` function
    /// Note: This function does not do any assumption check
    function tryCallerCallVaultDecimals(address caller) internal returns (bool callSuccess, uint8 returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallVaultDecimals();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `asset.decimals` function
    function tryCallAssetDecimals() internal returns (bool, uint8) {
        bytes memory data = abi.encodeWithSelector(cut4626.decimals.selector);
        (bool success, bytes memory returnData) = address(asset).call(data);
        uint8 returnValue;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint8));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `asset.decimals` function
    /// Note: This function does not do any assumption check
    function tryCallerCallAssetDecimals(address caller) internal returns (bool callSuccess, uint8 returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallAssetDecimals();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `asset` function
    function tryCallAsset() internal returns (bool, address) {
        bytes memory data = abi.encodeWithSelector(cut4626.asset.selector);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        address returnValue = address(0x0);
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (address));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `asset` function
    /// Note: This function does not do any assumption check
    function tryCallerCallAsset(address caller) internal returns (bool callSuccess, address returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallAsset();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `totalAssets` function
    function tryCallTotalAssets() internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.totalAssets.selector);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `totalAssets` function
    /// Note: This function does not do any assumption check
    function tryCallerCallTotalAssets(address caller) internal returns (bool callSuccess, uint256 returnValue) {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallTotalAssets();
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `convertToShares` function on an amount of `assets`
    function tryCallConvertToSharesAssets(uint256 assets) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.convertToShares.selector, assets);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `convertToShares` function on an amount of `assets`
    /// Note: This function does not do any assumption check
    function tryCallerCallConvertToSharesAssets(address caller, uint256 assets)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallConvertToSharesAssets(assets);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `convertToAssets` function on an amount of `shares`
    function tryCallConvertToAssetsShares(uint256 shares) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.convertToAssets.selector, shares);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `convertToAssets` function on an amount of `shares`
    /// Note: This function does not do any assumption check
    function tryCallerCallConvertToAssetsShares(address caller, uint256 shares)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallConvertToAssetsShares(shares);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `maxDeposit` function on a receiver `address`
    function tryCallMaxDepositReceiver(address receiver) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.maxDeposit.selector, receiver);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `maxDeposit` function on a receiver `address`
    /// Note: This function does not do any assumption check
    function tryCallerCallMaxDepositReceiver(address caller, address receiver)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallMaxDepositReceiver(receiver);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `previewDeposit` function on an amount of `assets`
    function tryCallPreviewDepositAssets(uint256 assets) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.previewDeposit.selector, assets);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `previewDeposit` function on an amount of `assets`
    /// Note: This function does not do any assumption check
    function tryCallerCallPreviewDepositAssets(address caller, uint256 assets)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallPreviewDepositAssets(assets);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `maxWithdraw` function on an owner `address`
    function tryCallMaxWithdrawOwner(address owner) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.maxWithdraw.selector, owner);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `maxWithdraw` function on an owner `address`
    /// Note: This function does not do any assumption check
    function tryCallerCallMaxWithdrawOwner(address caller, address owner)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallMaxWithdrawOwner(owner);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `previewWithdraw` function on an amount of `assets`
    function tryCallPreviewWithdrawAssets(uint256 assets) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.previewWithdraw.selector, assets);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `previewWithdraw` function on an amount of `assets`
    /// Note: This function does not do any assumption check
    function tryCallerCallPreviewWithdrawAssets(address caller, uint256 assets)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallPreviewWithdrawAssets(assets);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `maxMint` function on a receiver `address`
    function tryCallMaxMintReceiver(address receiver) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.maxMint.selector, receiver);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `maxMint` function on a receiver `address`
    /// Note: This function does not do any assumption check
    function tryCallerCallMaxMintReceiver(address caller, address receiver)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallMaxMintReceiver(receiver);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `previewMint` function on an amount of `shares`
    function tryCallPreviewMintShares(uint256 shares) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.previewMint.selector, shares);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `previewMint` function on an amount of `shares`
    /// Note: This function does not do any assumption check
    function tryCallerCallPreviewMintShares(address caller, uint256 shares)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallPreviewMintShares(shares);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `maxRedeem` function on an owner `address`
    function tryCallMaxRedeemOwner(address owner) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.maxRedeem.selector, owner);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `maxRedeem` function on an owner `address`
    /// Note: This function does not do any assumption check
    function tryCallerCallMaxRedeemOwner(address caller, address owner)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallMaxRedeemOwner(owner);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /// @notice Try calling `previewRedeem` function on an amount of `shares`
    function tryCallPreviewRedeemShares(uint256 shares) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.previewRedeem.selector, shares);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `previewRedeem` function on an amount of `shares`
    /// Note: This function does not do any assumption check
    function tryCallerCallPreviewRedeemShares(address caller, uint256 shares)
        internal
        returns (bool callSuccess, uint256 returnValue)
    {
        vm.startPrank(caller);
        (callSuccess, returnValue) = tryCallPreviewRedeemShares(shares);
        vm.stopPrank();
        return (callSuccess, returnValue);
    }

    /**
     *
     *
     * deposit, withdraw, mint and redeem helper functions.
     *
     *
     */

    /// @notice Try calling `deposit` function on an amount of `assets` for `receiver`
    function tryDepositAssetsToReceiver(uint256 assets, address receiver) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.deposit.selector, assets, receiver);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `deposit` function on an amount of `assets` for `receiver`
    /// Note: This function does not do any assumption check or approval call unlike the following function
    function tryCallerDepositAssetsToReceiver(address caller, uint256 assets, address receiver)
        internal
        returns (bool callDeposit, uint256 mintedShares)
    {
        vm.startPrank(caller);
        (callDeposit, mintedShares) = tryDepositAssetsToReceiver(assets, receiver);
        vm.stopPrank();
        return (callDeposit, mintedShares);
    }

    /// @notice A `caller` tries to call `deposit` function on an amount of `assets` for `receiver` with checks and approval
    /// @dev To ensure `assets` has indeed been deposited whenever `deposit` is called
    /// successfully, we need the conditions that:
    /// 1. assetsOverflowRestriction(assets)
    /// 2. assets <= asset.balanceOf(caller)
    /// 3. caller approves asset.balanceOf(caller) to vault so that it has more than
    ///    enough allowance to call `deposit`
    function tryCallerDepositAssetsToReceiverWithChecksAndApproval(address caller, uint256 assets, address receiver)
        internal
        assetsOverflowRestriction(assets)
        returns (bool callDeposit, uint256 mintedShares)
    {
        uint256 callerAssets = asset.balanceOf(caller);
        vm.assume(assets <= callerAssets);
        (bool callApprove,) = tryCallerApproveApproveeAssets(caller, address(cut4626), callerAssets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Caller cannot approve vault assets.");
        vm.startPrank(caller);
        (callDeposit, mintedShares) = tryDepositAssetsToReceiver(assets, receiver);
        vm.stopPrank();
        return (callDeposit, mintedShares);
    }

    /// @notice Try calling `withdraw` function on an amount of `assets` for `receiver` from `owner`
    function tryWithdrawAssetsToReceiverFromOwner(uint256 assets, address receiver, address owner)
        internal
        returns (bool, uint256)
    {
        bytes memory data = abi.encodeWithSelector(cut4626.withdraw.selector, assets, receiver, owner);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `withdraw` function on an amount of `assets` for `receiver` from `owner`
    /// Note: This function does not do any assumption check or approval call unlike the following function
    function tryCallerWithdrawAssetsToReceiverFromOwner(address caller, uint256 assets, address receiver, address owner)
        internal
        returns (bool callWithdraw, uint256 burnedShares)
    {
        vm.startPrank(caller);
        (callWithdraw, burnedShares) = tryWithdrawAssetsToReceiverFromOwner(assets, receiver, owner);
        vm.stopPrank();
        return (callWithdraw, burnedShares);
    }

    /// @notice A `caller` tries to call `withdraw` function on an amount of `assets` for `receiver` from `owner` with checks and approval
    /// @dev To ensure `assets` has indeed been withdrawed whenever `withdraw` is called by non-owner
    /// successfully, we need the conditions that:
    /// 1. assetsOverflowRestriction(assets)
    /// 2. sharesOverflowRestriction(vault.balanceOf(owner)) [coded within the function]
    /// 3. previewWithdraw(assets) <= vault.balanceOf(owner)
    /// 4. owner approves vault.balanceOf(owner) to caller so that he/she have more than
    ///    enough allowance to call `withdraw`
    function tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(
        address caller,
        uint256 assets,
        address receiver,
        address owner
    ) internal assetsOverflowRestriction(assets) returns (bool callWithdraw, uint256 burnedShares) {
        uint256 ownerShares = cut4626.balanceOf(owner);
        // sharesOverflowRestriction on vault.balance[owner]
        if (cut4626.totalSupply() > 0) {
            vm.assume(ownerShares < maxShares() / (cut4626.totalAssets() + 1));
        }
        vm.assume(cut4626.previewWithdraw(assets) <= ownerShares);
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, caller, ownerShares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Owner cannot approve caller shares.");
        vm.startPrank(caller);
        (callWithdraw, burnedShares) = tryWithdrawAssetsToReceiverFromOwner(assets, receiver, owner);
        vm.stopPrank();
        return (callWithdraw, burnedShares);
    }

    /// @notice A `owner` tries to call `withdraw` function on an amount of `assets` for `receiver` from his own shares with checks
    /// @dev To ensure `assets` has indeed been withdrawed whenever `withdraw` is called by owner
    /// successfully, we need the conditions that:
    /// 1. assetsOverflowRestriction(assets)
    /// 2. sharesOverflowRestriction(vault.balanceOf(owner)) [coded within the function]
    /// 3. previewWithdraw(assets) <= vault.balanceOf(owner)
    /// Note: When owner withdraws assets from its own account, no approval is needed,
    /// unlike the case for `tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval`.
    function tryOwnerWithdrawAssetsToReceiverWithChecks(address owner, uint256 assets, address receiver)
        internal
        assetsOverflowRestriction(assets)
        returns (bool callWithdraw, uint256 burnedShares)
    {
        uint256 ownerShares = cut4626.balanceOf(owner);
        // sharesOverflowRestriction on vault.balance[owner]
        if (cut4626.totalSupply() > 0) {
            vm.assume(ownerShares < maxShares() / (cut4626.totalAssets() + 1));
        }
        vm.assume(cut4626.previewWithdraw(assets) <= ownerShares);
        vm.startPrank(owner);
        (callWithdraw, burnedShares) = tryWithdrawAssetsToReceiverFromOwner(assets, receiver, owner);
        vm.stopPrank();
        return (callWithdraw, burnedShares);
    }

    /// @notice Try calling `mint` function on an amount of `shares` for `receiver`
    function tryMintSharesToReceiver(uint256 shares, address receiver) internal returns (bool, uint256) {
        bytes memory data = abi.encodeWithSelector(cut4626.mint.selector, shares, receiver);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `mint` function on an amount of `shares` for `receiver`
    /// Note: This function does not do any assumption check or approval call unlike the following function
    function tryCallerMintSharesToReceiver(address caller, uint256 shares, address receiver)
        internal
        returns (bool callMint, uint256 depositedAssets)
    {
        vm.startPrank(caller);
        (callMint, depositedAssets) = tryMintSharesToReceiver(shares, receiver);
        vm.stopPrank();
        return (callMint, depositedAssets);
    }

    /// @notice A `caller` tries to call `mint` function on an amount of `shares` for `receiver` with checks and approval
    /// @dev To ensure `shares` has indeed been minted whenever `mint` is called
    /// successfully, we need the conditions that:
    /// 1. sharesOverflowRestriction(shares)
    /// 2. previewMint(shares) <= asset.balanceOf(caller)
    /// 3. caller approves asset.balanceOf(caller) to vault so that it has more than
    ///    enough allowance to call `mint`
    function tryCallerMintSharesToReceiverWithChecksAndApproval(address caller, uint256 shares, address receiver)
        internal
        sharesOverflowRestriction(shares)
        returns (bool callMint, uint256 depositedAssets)
    {
        uint256 callerAssets = asset.balanceOf(caller);
        vm.assume(cut4626.previewMint(shares) <= callerAssets);
        (bool callApprove,) = tryCallerApproveApproveeAssets(caller, address(cut4626), callerAssets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Caller cannot approve vault assets.");
        vm.startPrank(caller);
        (callMint, depositedAssets) = tryMintSharesToReceiver(shares, receiver);
        vm.stopPrank();
        return (callMint, depositedAssets);
    }

    /// @notice Try calling `redeem` function on an amount of `shares` for `receiver` from `owner`
    function tryRedeemSharesToReceiverFromOwner(uint256 shares, address receiver, address owner)
        internal
        returns (bool, uint256)
    {
        bytes memory data = abi.encodeWithSelector(cut4626.redeem.selector, shares, receiver, owner);
        (bool success, bytes memory returnData) = address(cut4626).call(data);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }

    /// @notice A `caller` tries to call `redeem` function on an amount of `shares` for `receiver` from `owner`
    /// Note: This function does not do any assumption check or approval call unlike the following function
    function tryCallerRedeemSharesToReceiverFromOwner(address caller, uint256 shares, address receiver, address owner)
        internal
        returns (bool callRedeem, uint256 redeemedAssets)
    {
        vm.startPrank(caller);
        (callRedeem, redeemedAssets) = tryRedeemSharesToReceiverFromOwner(shares, receiver, owner);
        vm.stopPrank();
        return (callRedeem, redeemedAssets);
    }

    /// @notice A `caller` tries to call `redeem` function on an amount of `shares` for `receiver` from `owner` with checks and approval
    /// @dev To ensure `shares` has indeed been redeemed whenever `redeem` is called by non-owner
    /// successfully, we need the conditions that:
    /// 1. sharesOverflowRestriction(shares)
    /// 2. shares <= vault.balanceOf(owner)
    /// 3. owner approves vault.balanceOf(owner) to caller so that he/she have more than
    ///    enough allowance to call `redeem`
    function tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(
        address caller,
        uint256 shares,
        address receiver,
        address owner
    ) internal sharesOverflowRestriction(shares) returns (bool callRedeem, uint256 redeemedAssets) {
        uint256 ownerShares = cut4626.balanceOf(owner);
        vm.assume(shares <= ownerShares);
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, caller, ownerShares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Owner cannot approve caller shares.");
        vm.startPrank(caller);
        (callRedeem, redeemedAssets) = tryRedeemSharesToReceiverFromOwner(shares, receiver, owner);
        vm.stopPrank();
        return (callRedeem, redeemedAssets);
    }

    /// @notice A `owner` tries to call `redeem` function on an amount of `shares` for `receiver` from his own shares with checks
    /// @dev To ensure `shares` has indeed been redeemed whenever `redeem` is called by owner
    /// successfully, we need the conditions that:
    /// 1. sharesOverflowRestriction(shares)
    /// 2. shares <= vault.balanceOf(owner)
    /// Note: When owner redeems shares from its own account, no approval is needed,
    /// unlike the case for `tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval`.
    function tryOwnerRedeemSharesToReceiverWithChecks(address owner, uint256 shares, address receiver)
        internal
        sharesOverflowRestriction(shares)
        returns (bool callRedeem, uint256 redeemedAssets)
    {
        uint256 ownerShares = cut4626.balanceOf(owner);
        vm.assume(shares <= ownerShares);
        vm.startPrank(owner);
        (callRedeem, redeemedAssets) = tryRedeemSharesToReceiverFromOwner(shares, receiver, owner);
        vm.stopPrank();
        return (callRedeem, redeemedAssets);
    }
}
