// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC4626Abstract.sol";

/// @notice Abstract contract that consists of testing functions which test for properties from the standard
/// stated in the official EIP4626 specification.
abstract contract ERC4626Standard is ERC4626Abstract {
    /**
     *
     *
     *
     * MANDATORY checks.
     *
     *
     *
     */

    /**
     *
     *
     * EIP-20's optional metadata mandatory checks.
     *
     *
     */

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `name`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `name` is not callable.
    /// @custom:ercx-categories eip20
    function testNameCallable() public {
        (bool success,) = tryCallName();
        assertTrue(success, "The function `name` is not callable.");
    }

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `symbol`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `symbol` is not callable.
    /// @custom:ercx-categories eip20
    function testSymbolCallable() public {
        (bool success,) = tryCallSymbol();
        assertTrue(success, "The function `symbol` is not callable.");
    }

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `decimals`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `decimals` is not callable.
    /// @custom:ercx-categories eip20
    function testDecimalsCallable() public {
        (bool success,) = tryCallVaultDecimals();
        assertTrue(success, "The function `decimals` is not callable.");
    }

    /**
     *
     *
     * `asset` function mandatory checks
     *
     *
     */

    /// @notice Calling `asset` function MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `asset` function reverts.
    /// @custom:ercx-categories assets
    /// @custom:ercx-concerned-function asset
    function testAssetDoesNotRevert() public {
        (bool success,) = tryCallAsset();
        assertTrue(success, "Calling the `asset` function reverts.");
    }

    /**
     *
     *
     * `totalAssets` function mandatory checks
     *
     *
     */

    /// @notice Calling `totalAssets` function MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `totalAssets` function reverts.
    /// @custom:ercx-categories assets, total assets
    /// @custom:ercx-concerned-function totalAssets
    function testTotalAssetsDoesNotRevert() public {
        (bool success,) = tryCallTotalAssets();
        assertTrue(success, "Calling the `totalAssets` function reverts.");
    }

    /**
     *
     *
     * `convertToShares` function mandatory checks
     *
     *
     */

    /// @notice Calling `convertToShares` MUST NOT show any variations depending on the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` shows variations in outputs depending on the caller.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: convertToShares.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesNoVariationOnCaller(
        address user1,
        address user2,
        uint256 user1Assets,
        uint256 user2Assets,
        uint256 assets
    )
        public
        initializeAssetsTwoUniqueNonZeroAddresses(user1, user2, user1Assets, user2Assets)
        assetsOverflowRestriction(assets)
    {
        vm.assume(assets > 0);
        (bool call1, uint256 sharesSeenBy1) = tryCallerCallConvertToSharesAssets(user1, assets);
        (bool call2, uint256 sharesSeenBy2) = tryCallerCallConvertToSharesAssets(user2, assets);
        conditionalSkip(!call1 || !call2, "Inconclusive test: Unable to call `convertToShares`");
        assertEq(
            sharesSeenBy1,
            sharesSeenBy2,
            "Shares seen by dummy user 1 differs from shares seen by dummy user 2 after successful `convertToShares` call."
        );
    }

    /// @notice Calling `convertToShares` MUST NOT revert when there is no integer overflow caused by an unreasonably large input.
    /// @dev Limit for overflow is reference from  Solmate EIP-4626
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` reverts even if there is no integer overflow caused by an unreasonably large input.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesDoesNotRevertWhenNoIntOverflow(uint256 assets)
        public
        assetsOverflowRestriction(assets)
    {
        vm.assume(assets > 0);
        (bool success,) = tryCallConvertToSharesAssets(assets);
        assertTrue(
            success,
            "Calling `convertToShares` reverts even if there is no integer overflow caused by an unreasonably large input."
        );
    }

    /**
     *
     *
     * `convertToAssets` function mandatory checks
     *
     *
     */

    /// @notice Calling `convertToAssets` MUST NOT show any variations depending on the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` shows variations in outputs depending on the caller.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsNoVariationOnCaller(
        address user1,
        address user2,
        uint256 user1Shares,
        uint256 user2Shares,
        uint256 shares
    )
        public
        initializeSharesTwoUniqueNonZeroAddresses(user1, user2, user1Shares, user2Shares)
        sharesOverflowRestriction(shares)
    {
        vm.assume(shares > 0);
        (bool call1, uint256 assetsSeenBy1) = tryCallerCallConvertToAssetsShares(user1, shares);
        (bool call2, uint256 assetsSeenBy2) = tryCallerCallConvertToAssetsShares(user2, shares);
        conditionalSkip(!call1 || !call2, "Inconclusive test: Unable to call `convertToAssets`");
        assertEq(
            assetsSeenBy1,
            assetsSeenBy2,
            "Assets seen by dummy user 1 differs from assets seen by dummy user 2 after successful `convertToAssets` call."
        );
    }

    /// @notice Calling `convertToAssets` MUST NOT revert when there is no integer overflow caused by an unreasonably large input.
    /// @dev Limit for overflow is reference from  Solmate EIP-4626
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` reverts when there is no integer overflow caused by an unreasonably large input.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsDoesNotRevertWhenNoIntOverflow(uint256 shares)
        public
        sharesOverflowRestriction(shares)
    {
        vm.assume(shares > 0);
        (bool success,) = tryCallConvertToAssetsShares(shares);
        assertTrue(
            success,
            "Calling `convertToAssets` reverts even if there is no integer overflow caused by an unreasonably large input."
        );
    }

    /**
     *
     *
     * `maxDeposit` function mandatory checks
     *
     *
     */

    /// @notice Calling `maxDeposit` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxDeposit` reverts.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositDoesNotRevert(address user) public isNotZeroAddress(user) {
        (bool success,) = tryCallMaxDepositReceiver(user);
        assertTrue(success, "Calling the `maxDeposit` function reverts.");
    }

    /// @notice `maxDeposit` assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
    /// @dev Initialize Dummy user 1 and dummy user 2 different asset balances and check if calling `maxDeposit` on them returns the same value.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxDeposit` does not assume that the user has infinite assets, i.e. relies on balanceOf of asset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: maxDeposit.
    /// @custom:ercx-categories assets, deposit, balance
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositNotRelyBalanceOfAssets(
        address user1,
        address user2,
        uint256 user1Assets,
        uint256 user2Assets
    ) public initializeAssetsTwoUniqueNonZeroAddresses(user1, user2, user1Assets, user2Assets) {
        vm.assume(user1Assets > 0);
        vm.assume(user2Assets > 0);
        vm.assume(user1Assets != user2Assets);
        (bool callFor1, uint256 maxDeposit1) = tryCallerCallMaxDepositReceiver(user2, user1);
        (bool callFor2, uint256 maxDeposit2) = tryCallerCallMaxDepositReceiver(user1, user2);
        conditionalSkip(!callFor1 || !callFor2, "Inconclusive test: Failed to call `maxDeposit`.");
        assertEq(
            maxDeposit1,
            maxDeposit2,
            "`maxDeposit(user1) != maxDeposit(user2)` even though both balances of assets differ."
        );
    }

    /// @notice `maxDeposit` MUST NOT return a value higher than the actual maximum that would be accepted,
    /// i.e., a `deposit` call can be called on any amount that is lesser than or equal to `maxDeposit(receiver)`
    /// OR `maxDeposit(account) == type(uint256).max`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxDeposit` returns a value higher than the actual maximum that would be accepted,
    /// i.e., a `deposit` call cannot be called on an amount that is lesser than or equal to `maxDeposit(receiver)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories assets, deposit
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositNotHigherThanActualMax(
        address depositor,
        address receiver,
        uint256 assets,
        uint256 depositorAssets
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(depositor, depositorAssets)
        assetsOverflowRestriction(assets)
    {
        // Pass the test if cut4626.maxDeposit(receiver) == type(uint256).max
        if (cut4626.maxDeposit(receiver) != MAX_UINT256) {
            vm.assume(assets <= depositorAssets);
            vm.assume(cut4626.previewDeposit(assets) > 0);
            // Pass the test if cut4626.maxDeposit(receiver) == 0
            if (cut4626.maxDeposit(receiver) > 0) {
                vm.assume(assets <= cut4626.maxDeposit(receiver));
                // 1. depositor deposits an amount of assets that is <= maxDeposit(receiver) to receiver
                (bool callDeposit,) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(depositor, assets, receiver);
                // 2. Check that the deposit call succeeded
                assertTrue(
                    callDeposit,
                    "depositor cannot deposit a number of assets that is lesser than `maxDeposit(receiver)` for receiver."
                );
            } else {
                emit log("`maxDeposit(account) == 0`, and thus, the test passes by default.");
            }
        } else {
            emit log(
                "`maxDeposit(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default."
            );
        }
    }

    /**
     *
     *
     * `previewDeposit` function mandatory checks
     *
     *
     */

    /// @notice Calling `previewDeposit` returns as close to and no more than the exact amount of Vault shares (up to `delta`-approximation) that would be minted in a deposit call in the same transaction.
    /// I.e. deposit should return the same or more shares as previewDeposit if called in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewDeposit` returns more than the exact amount of Vault shares (up to `delta`-approximation) that would be minted in a deposit call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories shares, deposit
    /// @custom:ercx-concerned-function previewdeposit
    function testPreviewDepositSameOrLessThanDeposit(
        address depositor,
        address receiver,
        uint256 assets,
        uint256 depositorAssets
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(depositor, depositorAssets)
        assetsOverflowRestriction(assets)
    {
        vm.assume(assets > 0);
        vm.assume(assets <= depositorAssets);
        // 1. Find out the previewDeposit(assets)
        uint256 previewedShares = cut4626.previewDeposit(assets);
        vm.assume(previewedShares > 0);
        // 2. Find out the mintedShares output value from `deposit(assets, receiver)` call
        (bool callDeposit, uint256 mintedShares) =
            tryCallerDepositAssetsToReceiverWithChecksAndApproval(depositor, assets, receiver);
        // Skip the test if the deposit call failed and mintedShares == 0
        conditionalSkip(
            !callDeposit && mintedShares == 0, "Inconclusive test: depositor cannot deposit assets for receiver."
        );
        // 3. Compare the values found in step 1 and 2
        assertApproxLeAbs(
            previewedShares,
            mintedShares,
            delta,
            "`previewDeposit(assets) > deposit(assets)` (up to `delta`-approximation)"
        );
    }

    /**
     *
     *
     * `deposit` function mandatory checks
     *
     *
     */

    /// @notice Calling `deposit` emits Deposit event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `deposit` does not emit Deposit event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: deposit, approve.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function deposit
    function testDepositEmitDepositEvent(address depositor, address receiver, uint256 assets, uint256 depositorAssets)
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(depositor, depositorAssets)
        assetsOverflowRestriction(assets)
    {
        vm.assume(assets > 0);
        vm.assume(assets <= depositorAssets);
        uint256 shares = cut4626.previewDeposit(assets);
        vm.assume(shares > 0);
        // 1. depositor must approve vault sufficient allowance of assets
        (bool callApprove,) = tryCallerApproveApproveeAssets(depositor, address(cut4626), depositorAssets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: depositor cannot approve assets for vault.");
        // 3. This event emission check can only be done if deposit call in step 2 succeeds
        vm.expectEmit(true, true, false, false);
        emit Deposit(depositor, receiver, assets, shares);
        // 2. depositor tries to call `deposit(assets, receiver)`
        (bool callDeposit,) = tryCallerDepositAssetsToReceiver(depositor, assets, receiver);
        // Skip the test if the deposit call failed
        conditionalSkip(
            !callDeposit, "Inconclusive test: depositor cannot deposit positive amount of assets to receiver."
        );
        assertTrue(callDeposit, "depositor cannot deposit assets for receiver.");
    }

    /// @notice `deposit` supports EIP-20 `approve` / `transferFrom` on `asset` as a deposit flow, i.e.,
    /// the caller must first approve the vault enough assets' allowance before he/she can make a deposit, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `deposit` does not support EIP-20 `approve` / `transferFrom` on `asset` as a deposit flow.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories deposit, assets
    /// @custom:ercx-concerned-function deposit
    function testDepositSupportsEIP20ApproveTransferFromAssets(
        address depositor,
        address receiver,
        uint256 depositorAssets,
        uint256 assets
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(depositor, depositorAssets)
        assetsOverflowRestriction(assets)
    {
        vm.assume(depositorAssets > 0);
        vm.assume(assets > 0);
        uint256 previewDepositShares = cut4626.previewDeposit(assets);
        vm.assume(previewDepositShares > 0);
        vm.assume(assets <= depositorAssets);
        // 1. depositor approves enough assets allowance to the vault
        (bool callApprove,) = tryCallerApproveApproveeAssets(depositor, address(cut4626), depositorAssets);
        // 2. Check that approve call succeeded
        assertTrue(callApprove, "depositor cannot approve vault assets.");
        // 3. depositor calls `deposit(assets, receiver)`
        (bool callDeposit,) = tryCallerDepositAssetsToReceiver(depositor, assets, receiver);
        // 4. Check that the deposit call succeeded
        assertTrue(
            callDeposit,
            "depositor cannot deposit assets to receiver even though she has provided enough assets' allowance to the vault."
        );
    }

    /// @notice The `deposit` call fails if the caller did not approve the vault enough assets' allowance before he/she can make a deposit, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `deposit` call succeeds even though the caller did not approve the vault enough assets' allowance before he/she can make a deposit, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories deposit, assets
    /// @custom:ercx-concerned-function deposit
    function testDepositFailsIfInsufficientAssetsAllowanceToVault(
        address depositor,
        address receiver,
        uint256 depositorAssets,
        uint256 assets
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(depositor, depositorAssets)
        assetsOverflowRestriction(depositorAssets)
    {
        vm.assume(assets > 0);
        vm.assume(depositorAssets > 0);
        vm.assume(assets < depositorAssets);
        uint256 previewDepositShares = cut4626.previewDeposit(depositorAssets);
        vm.assume(previewDepositShares > 0);
        // 1. depositor approves enough assets allowance to the vault
        (bool callApprove,) = tryCallerApproveApproveeAssets(depositor, address(cut4626), assets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: depositor cannot approve vault assets.");
        // 2. depositor calls `deposit(assets, receiver)`
        (bool callDeposit,) = tryCallerDepositAssetsToReceiver(depositor, depositorAssets, receiver);
        // 3. Check that the deposit call failed
        assertFalse(
            callDeposit,
            "depositor can deposit assets to receiver even though she has not provided enough assets' allowance to the vault."
        );
    }

    /**
     *
     *
     * `maxWithdraw` function mandatory checks
     *
     *
     */

    /// @notice `maxWithdraw` MUST NOT return a value higher than the actual maximum that would be accepted,
    /// i.e., a `withdraw` call can be called on any amount that is lesser than or equal to `maxWithdraw(owner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxWithdraw` returns a value higher than the actual maximum that would be accepted,
    /// i.e., a `withdraw` call cannot be called on an amount that is lesser than or equal to `maxWithdraw(owner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories assets, withdraw
    /// @custom:ercx-concerned-function maxWithdraw
    function testMaxWithdrawNotHigherThanActualMax(
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 withdrawerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(withdrawer, withdrawerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(withdrawerShares)
    {
        vm.assume(withdrawerShares > 0);
        vm.assume(assets > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // Do the property test only if maxWithdraw > 0
        if (cut4626.maxWithdraw(withdrawer) > 0) {
            vm.assume(assets <= cut4626.maxWithdraw(withdrawer));
            // 1. withdrawer tries calling `withdraw(assets, receiver, withdrawer)` (i.e., from her own shares) where `assets <= cut4626.maxWithdraw(withdrawer)`
            (bool callWithdraw,) = tryOwnerWithdrawAssetsToReceiverWithChecks(withdrawer, assets, receiver);
            // 2. Check that the withdraw call succeeded
            assertTrue(
                callWithdraw,
                "withdrawer cannot withdraw an amount of assets that is lesser than `maxWithdraw(withdrawer)` for receiver."
            );
        }
    }

    /// @notice Calling `maxWithdraw` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxWithdraw` reverts.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function maxWithdraw
    function testMaxWithdrawDoesNotRevert(address user) public isNotZeroAddress(user) {
        (bool success,) = tryCallMaxWithdrawOwner(user);
        assertTrue(success, "Calling the `maxWithdraw` function reverts.");
    }

    /**
     *
     *
     * `previewWithdraw` function mandatory checks
     *
     *
     */

    /// @notice Calling `previewWithdraw` returns as close to and no fewer than the exact amount of Vault shares (up to `delta`-approximation) that would be burned in a withdraw call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if called in the same transaction
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewWithdraw` returns lesser than the exact amount of Vault shares (up to `delta`-approximation) that would be burned in a withdraw call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: withdraw.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function previewWithdraw
    function testPreviewWithdrawSameOrMoreThanWithdraw(
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 withdrawerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(withdrawer, withdrawerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(withdrawerShares)
    {
        vm.assume(withdrawerShares > 0);
        vm.assume(assets > 0);
        // 1. Find out cut4626.previewWithdraw(assets)
        uint256 shares = cut4626.previewWithdraw(assets);
        vm.assume(shares <= withdrawerShares);
        vm.assume(shares > 0);
        // 2. Find out the withdrawnShares output value from `withdraw(assets, receiver, withdrawer)` call
        (bool callWithdraw, uint256 withdrawnShares) =
            tryOwnerWithdrawAssetsToReceiverWithChecks(withdrawer, assets, receiver);
        // Skip the test if the withdraw call failed and withdrawnShares == 0
        conditionalSkip(
            !callWithdraw && withdrawnShares == 0, "Inconclusive test: withdrawer cannot withdraw assets for receiver."
        );
        // 3. Compare the values found in step 1 and 2
        assertApproxGeAbs(
            shares, withdrawnShares, delta, "`previewWithdraw(assets) < withdraw(assets)` (up to `delta`-approximation)"
        );
    }

    /**
     *
     *
     * `withdraw` function mandatory checks
     *
     *
     */

    /// @notice Calling `withdraw` emits the Withdraw event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `withdraw` does not emit Withdraw event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: withdraw.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawEmitWithdrawEvent(
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 withdrawerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(withdrawer, withdrawerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(withdrawerShares)
    {
        vm.assume(withdrawerShares > 0);
        vm.assume(assets > 0);
        uint256 shares = cut4626.previewWithdraw(assets);
        vm.assume(shares <= withdrawerShares);
        vm.assume(shares > 0);
        // 2. This event emission check can only be done if withdraw call in step 2 succeeds
        vm.expectEmit(true, true, true, true);
        emit Withdraw(withdrawer, receiver, withdrawer, assets, shares);
        // 1. withdrawer tries to call `withdraw(assets, receiver, withdrawer)`
        // note: owner self withdraw does not need approval of allowance
        (bool callWithdraw,) = tryCallerWithdrawAssetsToReceiverFromOwner(withdrawer, assets, receiver, withdrawer);
        // Skip the test if the withdraw call failed
        conditionalSkip(
            !callWithdraw, "Inconclusive test: withdrawer cannot withdraw positive amount of assets to receiver."
        );
        assertTrue(callWithdraw, "withdrawer cannot withdraw assets for receiver.");
    }

    /// @notice `withdraw` supports a withdraw flow where the shares are burned from the owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `withdraw` may not support a withdraw flow where the shares are burned from the owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSupportsBurnSharesFromOwnerWhereOwnerIsMsgSender(
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 withdrawerShares
    )
        public
        initializeSharesOneNonZeroAddress(withdrawer, withdrawerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(withdrawerShares)
    {
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(withdrawerShares > 0);
        vm.assume(assets > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        uint256 shares = cut4626.previewWithdraw(assets);
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(shares <= withdrawerShares);
        vm.assume(shares > 0);
        // 1. withdrawer (the `owner` of the `shares`) tries to call `withdraw(assets, receiver, withdrawer)` without approval of allowance
        (bool callWithdraw, uint256 burnedShares) =
            tryOwnerWithdrawAssetsToReceiverWithChecks(withdrawer, assets, receiver);
        // 2a. Check that the withdraw call succeeded
        assertTrue(callWithdraw, "withdrawer cannot withdraw assets for receiver.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 withdrawerSharesAfter = cut4626.balanceOf(withdrawer);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");
        assertApproxEqAbs(
            totalSupplyBefore - totalSupplyAfter,
            burnedShares,
            delta,
            "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
        // 2c. Check that the right amount of shares is burnt from the withdrawer shares' balance
        assertGt(
            withdrawerShares, withdrawerSharesAfter, "withdrawer's balance of shares does not decrease as expected."
        );
        assertApproxEqAbs(
            withdrawerShares - withdrawerSharesAfter,
            burnedShares,
            delta,
            "withdrawer's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
    }

    /// @notice `withdraw` supports a withdraw flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `withdraw` may not support a withdraw flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSupportsBurnSharesFromOwnerWhereOwnerApprovesMsgSender(
        address owner,
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 ownerShares
    )
        public
        initializeSharesOneNonZeroAddress(owner, ownerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(ownerShares)
    {
        vm.assume(withdrawer != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(withdrawer != owner); // Did not use `unique2Addresses` modifier as stack too deep
        vm.assume(ownerShares > 0);
        vm.assume(assets > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(cut4626.previewWithdraw(assets) <= ownerShares);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // 1. withdrawer (non-`owner` of the `shares`) tries to call `withdraw(assets, receiver, owner)` with approval of allowance
        (bool callWithdraw, uint256 burnedShares) =
            tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(withdrawer, assets, receiver, owner);
        // 2a. Check that the withdraw call succeeded
        assertTrue(
            callWithdraw,
            "withdrawer cannot withdraw owner's assets for receiver even though owner has approved withdrawer enough allowance."
        );
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(
            totalSupplyBefore, cut4626.totalSupply(), "The total supply of the vault does not decrease as expected."
        );
        assertApproxEqAbs(
            totalSupplyBefore - cut4626.totalSupply(),
            burnedShares,
            delta,
            "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
        // 2c. Check that the right amount of shares is burnt from the owner shares' balance
        assertGt(ownerShares, cut4626.balanceOf(owner), "owner's balance of shares does not decrease as expected.");
        assertApproxEqAbs(
            ownerShares - cut4626.balanceOf(owner),
            burnedShares,
            delta,
            "owner's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
    }

    /**
     *
     *
     * `maxMint` function mandatory checks
     *
     *
     */

    /// @notice Calling `maxMint` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxMint` reverts.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintDoesNotRevert(address user) public isNotZeroAddress(user) {
        (bool success,) = tryCallMaxMintReceiver(user);
        assertTrue(success, "Calling the `maxMint` function reverts.");
    }

    /// @notice `maxMint` assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
    /// @dev Initialize dummy user 1 and 2 different asset balances and check if calling `maxMint` on them returns the same value.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxMint` does not assume that the user has infinite assets, i.e. relies on balanceOf of asset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: maxMint.
    /// @custom:ercx-categories assets, mint, balance
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintNotRelyBalanceOfAssets(address user1, address user2, uint256 user1Assets, uint256 user2Assets)
        public
        initializeAssetsTwoUniqueNonZeroAddresses(user1, user2, user1Assets, user2Assets)
    {
        vm.assume(user1Assets > 0);
        vm.assume(user2Assets > 0);
        vm.assume(user1Assets != user2Assets);
        (bool callFor1, uint256 maxMint1) = tryCallerCallMaxMintReceiver(user2, user1);
        (bool callFor2, uint256 maxMint2) = tryCallerCallMaxMintReceiver(user1, user2);
        conditionalSkip(!callFor1 || !callFor2, "Inconclusive test: Failed to call `maxMint`.");
        assertEq(maxMint1, maxMint2, "`maxMint(user1) != maxMint(user2)` even though both balances of assets differ.");
    }

    /// @notice `maxMint` MUST NOT return a value higher than the actual maximum that would be accepted,
    /// i.e., a `mint` call can be called on any amount that is lesser than or equal to `maxMint(receiver)`
    /// OR `maxMint(account) == type(uint256).max`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxMint` returns a value higher than the actual maximum that would be accepted,
    /// i.e., a `mint` call cannot be called on an amount that is lesser than or equal to `maxMint(receiver)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories shares, mint
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintNotHigherThanActualMax(address minter, address receiver, uint256 shares, uint256 minterAssets)
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(minter, minterAssets)
        sharesOverflowRestriction(shares)
    {
        // Pass the test if cut4626.maxMint(receiver) == type(uint256).max
        if (cut4626.maxMint(receiver) != MAX_UINT256) {
            vm.assume(shares > 0);
            vm.assume(minterAssets > 0);
            uint256 previewedAssets = cut4626.previewMint(shares);
            vm.assume(previewedAssets > 0);
            vm.assume(previewedAssets <= minterAssets);
            // Pass the test if maxMint == 0
            if (cut4626.maxMint(receiver) > 0) {
                vm.assume(shares <= cut4626.maxMint(receiver));
                // 1. minter mints an amount of shares <= maxMint(receiver) to receiver
                (bool callMint,) = tryCallerMintSharesToReceiverWithChecksAndApproval(minter, shares, receiver);
                // 2. Check that the mint call succeeded
                assertTrue(
                    callMint,
                    "minter cannot mint a number of shares that is lesser than `maxMint(receiver)` for receiver."
                );
            } else {
                emit log("`maxMint(account) == 0`, and thus, the test passes by default.");
            }
        } else {
            emit log(
                "`maxMint(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default."
            );
        }
    }

    /**
     *
     *
     * `previewMint` function mandatory checks
     *
     *
     */

    /// @notice `previewMint` returns as close to and no fewer than the exact amount of assets (up to `delta`-approximation) that would be deposited in a mint call in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `previewMint` does not return as close to and no fewer than the exact amount of assets (up to `delta`-approximation) that would be deposited in a mint call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: mint, approve.
    /// @custom:ercx-categories assets, mint
    /// @custom:ercx-concerned-function previewMint
    function testPreviewMintSameOrMoreThanMint(address minter, address receiver, uint256 shares, uint256 minterAssets)
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(minter, minterAssets)
        sharesOverflowRestriction(shares)
    {
        vm.assume(minterAssets > 0);
        vm.assume(shares > 0);
        // 1. Find out cut4626.previewMint(shares)
        uint256 previewedAssets = cut4626.previewMint(shares);
        vm.assume(previewedAssets > 0);
        vm.assume(previewedAssets <= minterAssets);
        // 2. Find out the mintedAssets output value from `mint(shares, receiver)` call
        (bool callMint, uint256 mintedAssets) =
            tryCallerMintSharesToReceiverWithChecksAndApproval(minter, shares, receiver);
        // Skip the test if the mint call failed and mintedAssets == 0
        conditionalSkip(!callMint && mintedAssets == 0, "Inconclusive test: minter cannot mint shares for receiver.");
        // 3. Compare the values found in step 1 and 2
        assertApproxGeAbs(
            previewedAssets, mintedAssets, delta, "`previewMint(shares) < mint(shares)` (up to `delta`-approximation)"
        );
    }

    /**
     *
     *
     * `mint` function mandatory checks
     *
     *
     */

    /// @notice Calling `mint` emits the Deposit event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `mint` does not emits the Deposit event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: mint, approve.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function mint
    function testMintEmitDepositEvent(address minter, address receiver, uint256 shares, uint256 minterAssets)
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(minter, minterAssets)
        sharesOverflowRestriction(shares)
    {
        vm.assume(minterAssets > 0);
        vm.assume(shares > 0);
        uint256 assets = cut4626.previewMint(shares);
        vm.assume(assets > 0);
        vm.assume(assets <= minterAssets);
        // 1. minter must approve vault sufficient allowance of assets
        (bool callApprove,) = tryCallerApproveApproveeAssets(minter, address(cut4626), minterAssets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: minter cannot approve assets for vault.");
        // 3. This event emission check can only be done if mint call in step 2 succeeds
        vm.expectEmit(true, true, false, false);
        emit Deposit(minter, receiver, assets, shares);
        // 2. minter tries to call `mint(shares, receiver)`
        (bool callMint,) = tryCallerMintSharesToReceiver(minter, shares, receiver);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: minter cannot mint positive amount of shares to receiver.");
        assertTrue(callMint, "minter cannot mint shares for receiver.");
    }

    /// @notice `mint` supports EIP-20 `approve` / `transferFrom` on `asset` as a mint flow, i.e.,
    /// the caller must first approve the vault enough assets' allowance before he/she can make a mint call, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `mint` does not support EIP-20 `approve` / `transferFrom` on `asset` as a mint flow.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories mint, assets
    /// @custom:ercx-concerned-function mint
    function testMintSupportsEIP20ApproveTransferFromAssets(
        address minter,
        address receiver,
        uint256 minterAssets,
        uint256 shares
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(minter, minterAssets)
        sharesOverflowRestriction(shares)
    {
        vm.assume(minterAssets > 0);
        vm.assume(shares > 0);
        uint256 previewMintAssets = cut4626.previewMint(shares);
        vm.assume(previewMintAssets > 0);
        vm.assume(previewMintAssets <= minterAssets);
        // 1. minter approves enough assets allowance to the vault
        (bool callApprove,) = tryCallerApproveApproveeAssets(minter, address(cut4626), minterAssets);
        // 2. Check that approve call succeeded
        assertTrue(callApprove, "minter cannot approve vault assets.");
        // 3. minter calls `mint(shares, receiver)`
        (bool callMint,) = tryCallerMintSharesToReceiver(minter, shares, receiver);
        // 4. Check that the mint call succeeded
        assertTrue(
            callMint,
            "minter cannot mint shares to receiver even though she has provided enough assets' allowance to the vault."
        );
    }

    /// @notice The `mint` call fails if the caller did not approve the vault enough assets' allowance before he/she can make a mint call, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `mint` call succeeds even though the caller did not approve the vault enough assets' allowance before he/she can make a mint call, where
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories mint, assets
    /// @custom:ercx-concerned-function mint
    function testMintFailsIfInsufficientAssetsAllowanceToVault(
        address minter,
        address receiver,
        uint256 minterAssets,
        uint256 shares,
        uint256 approvedAssets
    )
        public
        isNotZeroAddress(receiver)
        initializeAssetsOneNonZeroAddress(minter, minterAssets)
        sharesOverflowRestriction(shares)
    {
        vm.assume(minterAssets > 0);
        vm.assume(shares > 0);
        uint256 previewMintAssets = cut4626.previewMint(shares);
        vm.assume(previewMintAssets > 0);
        vm.assume(previewMintAssets <= minterAssets);
        vm.assume(approvedAssets < previewMintAssets);
        // 1. minter approves enough assets allowance to the vault
        (bool callApprove,) = tryCallerApproveApproveeAssets(minter, address(cut4626), approvedAssets);
        // Skip test if approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: minter cannot approve vault assets.");
        // 2. minter calls `mint(shares, receiver)`
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiver(minter, shares, receiver);
        if (callMint) {
            // 3a. Check that the depositedAssets <= approvedAssets if the mint call succeeded
            assertLe(
                depositedAssets,
                approvedAssets,
                "minter can mint shares to receiver even though she has not provided enough assets' allowance to the vault."
            );
        } else {
            // 3b. Check that the mint call failed otherwise
            assertFalse(
                callMint,
                "minter can mint shares to receiver even though she has not provided enough assets' allowance to the vault."
            );
        }
    }

    /**
     *
     *
     * `maxRedeem` function mandatory checks
     *
     *
     */

    /// @notice `maxRedeem` MUST NOT return a value higher than the actual maximum that would be accepted,
    /// i.e., a `redeem` call can be called on any amount that is lesser than or equal to `maxRedeem(owner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxRedeem` returns a value higher than the actual maximum that would be accepted,
    /// i.e., a `redeem` call cannot be called on an amount that is lesser than or equal to `maxRedeem(owner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function maxRedeem
    function testMaxRedeemNotHigherThanActualMax(
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 redeemerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(redeemer, redeemerShares)
        sharesOverflowRestriction(shares)
    {
        vm.assume(redeemerShares > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // Do the property test only if maxRedeem > 0
        if (cut4626.maxRedeem(redeemer) > 0) {
            vm.assume(shares <= cut4626.maxRedeem(redeemer));
            // 1. redeemer tries calling `redeem(shares, receiver, redeemer)` (i.e., from her own shares) where `shares <= cut4626.maxRedeem(redeemer)`
            (bool callRedeem,) = tryOwnerRedeemSharesToReceiverWithChecks(redeemer, shares, receiver);
            // 2. Check that the redeem call succeeded
            assertTrue(
                callRedeem,
                "redeemer cannot redeem an amount of shares that is lesser than `maxRedeem(redeemer)` for receiver."
            );
        }
    }

    /// @notice Calling `maxRedeem` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxRedeem` reverts.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function maxRedeem
    function testMaxRedeemDoesNotRevert(address user) public isNotZeroAddress(user) {
        (bool success,) = tryCallMaxRedeemOwner(user);
        assertTrue(success, "Calling the `maxRedeem` function reverts.");
    }

    /**
     *
     *
     * `previewRedeem` function mandatory checks
     *
     *
     */

    /// @notice Calling `previewRedeem` returns as close to and no more than the exact amount of assets (up to `delta`-approximation) that would be withdrawn in a redeem call in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewRedeem` returns more than the exact amount of assets (up to `delta`-approximation) that would be withdrawn in a redeem call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: redeem.
    /// @custom:ercx-categories redeem, assets
    /// @custom:ercx-concerned-function previewRedeem
    function testPreviewRedeemSameOrLessThanRedeem(
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 redeemerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(redeemer, redeemerShares)
        sharesOverflowRestriction(shares)
    {
        vm.assume(shares > 0);
        vm.assume(shares <= redeemerShares);
        // 1. Find out cut4626.previewRedeem(shares)
        uint256 previewedAssets = cut4626.previewRedeem(shares);
        vm.assume(previewedAssets > 0);
        // 2. Find out the redeemedAssets output value from `redeem(shares, receiver, redeemer)` call
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(redeemer, shares, receiver);
        // Skip the test if the redeem call failed and redeemedAssets == 0
        conditionalSkip(
            !callRedeem && redeemedAssets == 0, "Inconclusive test: redeemer cannot redeem shares for receiver."
        );
        // 3. Compare the values found in step 1 and 2
        assertApproxLeAbs(
            previewedAssets,
            redeemedAssets,
            delta,
            "`previewRedeem(shares) > redeem(shares)` (up to `delta`-approximation)"
        );
    }

    /**
     *
     *
     * `redeem` function mandatory checks
     *
     *
     */

    /// @notice Calling `redeem` emits the Withdraw event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `redeem` does not emit Withdraw event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: redeem.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function redeem
    function testRedeemEmitWithdrawEvent(address redeemer, address receiver, uint256 shares, uint256 redeemerShares)
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(redeemer, redeemerShares)
        sharesOverflowRestriction(shares)
    {
        vm.assume(shares > 0);
        vm.assume(shares <= redeemerShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 2. This event emission check can only be done if withdraw call in step 2 succeeds
        vm.expectEmit(true, true, true, true);
        emit Withdraw(redeemer, receiver, redeemer, assets, shares);
        // 1. redeemer tries to call `redeem(shares, receiver, redeemer)`
        // note: owner self-redeeming does not need approval of allowance
        (bool callRedeem,) = tryCallerRedeemSharesToReceiverFromOwner(redeemer, shares, receiver, redeemer);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: redeemer cannot redeem positive amount of shares to receiver.");
        assertTrue(callRedeem, "redeemer cannot redeem shares for receiver.");
    }

    /// @notice `redeem` supports a redeem flow where the shares are burned from owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `redeem` may not support a redeem flow where the shares are burned from owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemSupportsBurnSharesFromOwnerWhereOwnerIsMsgSender(
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 redeemerShares
    )
        public
        isNotZeroAddress(receiver)
        initializeSharesOneNonZeroAddress(redeemer, redeemerShares)
        sharesOverflowRestriction(shares)
    {
        uint256 totalSupplyBefore = cut4626.totalSupply();
        vm.assume(shares > 0);
        vm.assume(shares <= redeemerShares);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // 1. redeemer (the `owner` of the `shares`) tries to call `redeem(shares, receiver, redeemer)` without approval of allowance
        (bool callRedeem,) = tryOwnerRedeemSharesToReceiverWithChecks(redeemer, shares, receiver);
        // 2a. Check that the redeem call succeeded
        assertTrue(callRedeem, "redeemer cannot redeem shares for receiver.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 redeemerSharesAfter = cut4626.balanceOf(redeemer);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");
        assertApproxEqAbs(
            totalSupplyBefore - totalSupplyAfter,
            shares,
            delta,
            "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
        // 2c. Check that the right amount of shares is burnt from redeemer shares' balance
        assertGt(redeemerShares, redeemerSharesAfter, "redeemer's balance of shares does not decrease as expected.");
        assertApproxEqAbs(
            redeemerShares - redeemerSharesAfter,
            shares,
            delta,
            "redeemer's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
    }

    /// @notice `redeem` supports a redeem flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `redeem` supports a redeem flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemSupportsBurnSharesFromOwnerWhereOwnerApprovesMsgSender(
        address owner,
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 ownerShares
    )
        public
        unique2NonZeroAddresses(owner, redeemer)
        initializeSharesOneNonZeroAddress(owner, ownerShares)
        sharesOverflowRestriction(shares)
    {
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        uint256 totalSupplyBefore = cut4626.totalSupply();
        vm.assume(shares > 0);
        vm.assume(shares <= ownerShares);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // 1. redeemer (non-`owner` of the `shares`) tries to call `redeem(shares, receiver, owner)` with apporval of allowance
        (bool callRedeem,) =
            tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(redeemer, shares, receiver, owner);
        // 2a. Check that the redeem call succeeded
        assertTrue(
            callRedeem,
            "redeemer cannot redeem owner's shares for receiver even though owner has approved redeemer enough allowance."
        );
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 ownerSharesAfter = cut4626.balanceOf(owner);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");
        assertApproxEqAbs(
            totalSupplyBefore - totalSupplyAfter,
            shares,
            delta,
            "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
        // 2c. Check that the right amount of shares is burnt from owner shares' balance
        assertGt(ownerShares, ownerSharesAfter, "owner's balance of shares does not decrease as expected.");
        assertApproxEqAbs(
            ownerShares - ownerSharesAfter,
            shares,
            delta,
            "owner's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation)."
        );
    }

    /**
     *
     *
     *
     * RECOMMENDED checks.
     *
     *
     *
     */

    /**
     *
     *
     * `withdraw` function recommended checks
     *
     *
     */

    /// @notice A `withdraw` call of some amount of assets SHOULD be successful if there is
    /// sufficient shares' allowance from the owner to the msg.sender, i.e., the `withdraw` function SHOULD check
    /// msg.sender can spend owner funds, assets needs to be converted to shares and shares should be checked
    /// for allowance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `withdraw` call of some amount of assets was not successful even though there is
    /// sufficient shares' allowance from the owner to the msg.sender.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// sufficient shares' allowance from the owner to the msg.sender.
    /// @custom:ercx-categories shares, assets, withdraw, allowance
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSenderCanSpendBelowSharesAllowance(
        address owner,
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 ownerShares
    )
        public
        initializeSharesOneNonZeroAddress(owner, ownerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(ownerShares)
    {
        vm.assume(withdrawer != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(withdrawer != owner); // Did not use `unique2Addresses` modifier as stack too deep
        vm.assume(ownerShares > 0);
        vm.assume(assets > 0);
        uint256 shares = cut4626.previewWithdraw(assets);
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(shares <= ownerShares);
        // 1. owner approves enough shares allowance to withdrawer
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, withdrawer, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: owner cannot approve shares for withdrawer.");
        // 2. withdrawer tries to call `withdraw(assets, receiver, owner)`
        (bool callWithdraw,) = tryCallerWithdrawAssetsToReceiverFromOwner(withdrawer, assets, receiver, owner);
        // 3. Check that the withdraw call succeeded
        assertTrue(
            callWithdraw,
            "withdrawer cannot withdraw assets from owner's account for receiver even though he has enough allowance from owner."
        );
    }

    /// @notice A `withdraw` call of some amount of assets SHOULD NOT be successful if there is
    /// insufficient shares' allowance from the owner to the msg.sender, i.e., the `withdraw` function SHOULD
    /// check msg.sender can spend owner funds, assets needs to be converted to shares and shares should be
    /// checked for allowance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `withdraw` call of some amount of assets was successful even though there is
    /// insufficient shares' allowance from the owner to the msg.sender.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories shares, assets, withdraw, allowance
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSenderCannotSpendAboveSharesAllowance(
        address owner,
        address withdrawer,
        address receiver,
        uint256 assets,
        uint256 approvedShares,
        uint256 ownerShares
    )
        public
        initializeSharesOneNonZeroAddress(owner, ownerShares)
        assetsOverflowRestriction(assets)
        sharesOverflowRestriction(ownerShares)
    {
        vm.assume(withdrawer != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(withdrawer != owner); // Did not use `unique2Addresses` modifier as stack too deep
        vm.assume(ownerShares > 0);
        vm.assume(assets > 0);
        vm.assume(cut4626.previewWithdraw(assets) < ownerShares);
        vm.assume(approvedShares < cut4626.previewWithdraw(assets));
        vm.assume(approvedShares < ownerShares);
        // 1. owner approves insufficient shares allowance to withdrawer
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, withdrawer, approvedShares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: owner cannot approve shares for withdrawer.");
        // 2. withdrawer tries to call `withdraw(assets, withdrawer, owner)`
        (bool callWithdraw,) = tryCallerWithdrawAssetsToReceiverFromOwner(withdrawer, assets, withdrawer, owner);
        // 3. Check that the withdraw call failed
        assertFalse(
            callWithdraw,
            "withdrawer can withdraw assets from owner's account for withdrawer even though he does not have enough allowance from owner."
        );
    }

    /**
     *
     *
     * `redeem` function recommended checks
     *
     *
     */

    /// @notice A `redeem` call of some amount of shares SHOULD be successful if there is
    /// sufficient shares' allowance from the owner to the msg.sender, i.e., the `redeem` function SHOULD check
    /// msg.sender can spend owner funds using allowance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `redeem` call of some amount of shares was not successful even though there is
    /// sufficient shares' allowance from the owner to the msg.sender, i.e., the `redeem` function SHOULD check
    /// msg.sender can spend owner funds using allowance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories shares, redeem, allowance
    /// @custom:ercx-concerned-function redeem
    function testRedeemSenderCanSpendBelowSharesAllowance(
        address owner,
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 ownerShares
    ) public initializeSharesOneNonZeroAddress(owner, ownerShares) sharesOverflowRestriction(shares) {
        vm.assume(redeemer != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(redeemer != owner); // Did not use `unique2Addresses` modifier as stack too deep
        vm.assume(shares > 0);
        vm.assume(shares <= ownerShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 1. owner approves enough shares allowance to redeemer
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, redeemer, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: owner cannot approve shares for redeemer.");
        // 2. redeemer tries to call `redeem(shares, receiver, owner)`
        (bool callRedeem,) = tryCallerRedeemSharesToReceiverFromOwner(redeemer, shares, receiver, owner);
        // 3. Check that the redeem call succeeded
        assertTrue(
            callRedeem,
            "redeemer cannot redeem shares from owner's account for receiver even though he has enough allowance from owner."
        );
    }

    /// @notice A `redeem` call of some amount of shares SHOULD NOT be successful if there is
    /// insufficient shares' allowance from the owner to the msg.sender, i.e., the `redeem` function SHOULD check
    /// msg.sender can spend owner funds using allowance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `redeem` call of some amount of shares was successful even though there is
    /// insufficient shares' allowance from the owner to the msg.sender, i.e., the `redeem` function SHOULD check
    /// msg.sender can spend owner funds using allowance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories shares, redeem, allowance
    /// @custom:ercx-concerned-function redeem
    function testRedeemSenderCannotSpendAboveSharesAllowance(
        address owner,
        address redeemer,
        address receiver,
        uint256 shares,
        uint256 ownerShares
    ) public initializeSharesOneNonZeroAddress(owner, ownerShares) sharesOverflowRestriction(shares) {
        vm.assume(redeemer != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(receiver != address(0x0)); // Did not use `isNotZeroAddress` modifier as stack too deep
        vm.assume(redeemer != owner); // Did not use `unique2Addresses` modifier as stack too deep
        vm.assume(shares > 0);
        vm.assume(shares <= ownerShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 1. owner approves insufficient shares allowance to redeemer
        (bool callApprove,) = tryCallerApproveApproveeShares(owner, redeemer, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: owner cannot approve shares for redeemer.");
        // 2. redeemer tries to call `redeem(shares + 1, receiver, owner)`
        (bool callRedeem,) = tryCallerRedeemSharesToReceiverFromOwner(redeemer, shares + 1, receiver, owner);
        // 3. Check that the redeem call failed
        assertFalse(
            callRedeem,
            "redeemer can redeem shares from owner's account for receiver even though he does not have enough allowance from owner."
        );
    }

    /**
     *
     *
     * vault.decimals() check
     *
     *
     */

    /// @notice The `vault.decimals()` SHOULD be greater than or equal to `asset.decimals()`.
    /// @dev Source: Last paragraph of https://eips.ethereum.org/EIPS/eip-4626#security-considerations
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `vault.decimals()` is lesser than `asset.decimals()`.
    /// @custom:ercx-categories eip20
    /// @custom:ercx-concerned-function decimals
    function testVaultDecimalsGeAssetDecimals() public {
        (bool vaultSuccess, uint8 vaultDecimals) = tryCallVaultDecimals();
        (bool assetSuccess, uint8 assetDecimals) = tryCallAssetDecimals();
        // Skip the test if the vault.decimal call failed
        conditionalSkip(!vaultSuccess, "Inconclusive test: vault is unable to call `decimals()`");
        // Skip the test if the asset.decimal call failed
        conditionalSkip(!assetSuccess, "Inconclusive test: asset is unable to call `decimals()`");
        assertGe(vaultDecimals, assetDecimals, "The `vault.decimals()` is lesser than `asset.decimals()`.");
    }
}
