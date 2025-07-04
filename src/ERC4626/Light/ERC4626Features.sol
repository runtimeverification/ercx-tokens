// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC4626Abstract.sol";

/// @notice Abstract contract that consists of testing functions with test for properties
/// that are neither desirable nor undesirable but instead implementation choices.
abstract contract ERC4626Features is ERC4626Abstract {
    /**
     *
     *
     * Check if zero amount calls are possible
     *
     *
     */

    /// @notice Calling `convertToShares` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` of zero amount is not possible.
    /// @custom:ercx-categories assets, shares, zero amount
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallConvertToSharesAssets(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `convertToAssets` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` of zero amount is not possible.
    /// @custom:ercx-categories assets, shares, zero amount
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallConvertToAssetsShares(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `previewDeposit` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewDeposit` of zero amount is not possible.
    /// @custom:ercx-categories deposit, zero amount
    /// @custom:ercx-concerned-function previewDeposit
    function testPreviewDepositZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallPreviewDepositAssets(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `deposit` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `deposit` of zero amount is not possible.
    /// @custom:ercx-categories deposit, zero amount
    /// @custom:ercx-concerned-function deposit
    function testDepositZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerDepositAssetsToReceiver(alice, 0, alice);
        assertTrue(success);
    }

    /// @notice Calling `previewMint` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewMint` of zero amount is not possible.
    /// @custom:ercx-categories mint, zero amount
    /// @custom:ercx-concerned-function previewMint
    function testPreviewMintZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallPreviewMintShares(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `mint` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `mint` of zero amount is not possible.
    /// @custom:ercx-categories mint, zero amount
    /// @custom:ercx-concerned-function mint
    function testMintZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerMintSharesToReceiver(alice, 0, alice);
        assertTrue(success);
    }

    /// @notice Calling `previewWithdraw` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewWithdraw` of zero amount is not possible.
    /// @custom:ercx-categories withdraw, zero amount
    /// @custom:ercx-concerned-function previewWithdraw
    function testPreviewWithdrawZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallPreviewWithdrawAssets(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `withdraw` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `withdraw` of zero amount is not possible.
    /// @custom:ercx-categories withdraw, zero amount
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerWithdrawAssetsToReceiverFromOwner(alice, 0, alice, alice);
        assertTrue(success);
    }

    /// @notice Calling `previewRedeem` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewRedeem` of zero amount is not possible.
    /// @custom:ercx-categories redeem, zero amount
    /// @custom:ercx-concerned-function previewRedeem
    function testPreviewRedeemZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerCallPreviewRedeemShares(alice, 0);
        assertTrue(success);
    }

    /// @notice Calling `redeem` of zero amount is possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `redeem` of zero amount is not possible.
    /// @custom:ercx-categories redeem, zero amount
    /// @custom:ercx-concerned-function redeem
    function testRedeemZeroAmountIsPossible()
    public virtual {
        (bool success,) = tryCallerRedeemSharesToReceiverFromOwner(alice, 0, alice, alice);
        assertTrue(success);
    }

    /**
     *
     *
     * Calling of convertToAssets() checks
     *
     *
     */

    /// @notice The contract follows the integer overflow limit used by Solmate ERC4626 implementation for `convertToAssets`,
    /// i.e., calling `convertToAssets(shares)` reverts due to integer overflow when `shares > type(uint256).max / vault.totalAssets()`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The contract does not follow the integer overflow limit used by Solmate ERC4626 implementation for `convertToAssets`,
    /// i.e., there exists some `shares > type(uint256).max / vault.totalAssets()` where `convertToAssets(shares)` does not revert due to integer overflow.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsIntOverflowLimitFollowsSolmate() 
    public virtual {
        uint256 totalSupply = cut4626.totalSupply();
        uint256 totalAssets = cut4626.totalAssets();
        if (totalSupply > 0) {
            // restrict `shares` to force overflow
            uint256 shares = MAX_UINT256 / totalAssets + 1;
            (bool success,) = tryCallerCallConvertToAssetsShares(alice, shares);
            assertFalse(
                success,
                "Calling `convertToAssets` may not revert when there is an integer overflow caused by an unreasonably large input."
            );
        }
    }

    /**
     *
     *
     * Calling of convertToShares() checks
     *
     *
     */

    /// @notice The contract follows the integer overflow limit used by Solmate ERC4626 implementation for `convertToShares`,
    /// i.e., calling `convertToShares(assets)` reverts due to integer overflow when `assets > type(uint256).max / vault.totalSupply()`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The contract does not follow the integer overflow limit used by Solmate ERC4626 implementation for `convertToShares`,
    /// i.e., there exists some `assets > type(uint256).max / vault.totalSupply()` where `convertToShares(assets)` does not revert due to integer overflow.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesIntOverflowLimitFollowsSolmate() 
    public virtual {
        uint256 totalSupply = cut4626.totalSupply();
        if (totalSupply > 0) {
            // restrict `assets` to force overflow
            uint256 assets = MAX_UINT256 / totalSupply + 1;
            (bool success,) = tryCallerCallConvertToSharesAssets(alice, assets);
            assertFalse(
                success,
                "Calling `convertToShares` may not revert when there is an integer overflow caused by an unreasonably large input."
            );
        }
    }

    /**
     *
     *
     * Calling of deposit() checks.
     *
     *
     */

    /// @notice Calling `deposit` reverts when the amount of assets to deposit is greater than `maxDeposit(tokenReceiver)`
    /// OR `maxDeposit(account) == type(uint256).max`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `deposit` does not revert on some amount of assets that is greater than `maxDeposit(tokenReceiver)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories assets, deposit
    /// @custom:ercx-concerned-function deposit
    function testDepositRevertsWhenAssetsGtMaxDeposit(uint256 assets, uint256 aliceAssets, uint256 bobShares) public virtual
    initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) {
        uint256 maxDepositBob = cut4626.maxDeposit(bob);
        // Pass the test if cut4626.maxDeposit(bob) == type(uint256).max
        if (maxDepositBob != MAX_UINT256) {
            vm.assume(assets > maxDepositBob);
            vm.assume(assets <= asset.balanceOf(alice));
            // 1. Alice tries to deposit assets that is greater than maxDepositBob to Bob
            (bool callDeposit,) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, assets, bob);
            // 2. Check that the deposit call fail
            assertFalse(
                callDeposit, "Alice can deposit an amount of assets that is greater than `maxDeposit(bob)` for Bob."
            );
        } else {
            emit log(
                "`maxDeposit(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default."
            );
        }
    }

    /// @notice Calling `maxDeposit MUST return 2 ** 256 - 1
    /// if there is no limit on the maximum amount of assets that may be deposited.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback Calling `maxDeposit` does not return 2 ** 256 - 1, i.e., there might be a limit set for `maxDeposit`.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositReturnMaxUint256IfNoLimit() 
    public virtual {
        assertEq(cut4626.maxDeposit(alice), MAX_UINT256, "Calling `maxDeposit` does not return 2 ** 256 - 1.");
    }

    /**
     *
     *
     * Calling of withdraw() checks.
     *
     *
     */

    /// @notice `maxWithdraw(account) == convertToAssets(vault.balanceOf(account))` (referenced from Solmate and OZ implementation)
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `maxWithdraw(account) != convertToAssets(vault.balanceOf(account))`
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function maxWithdraw
    function testMaxWithdrawEqConvertToAssetsOfBalanceOfShares(uint256 aliceShares)
    public virtual initializeSharesTwoUsers(aliceShares, 0) {
        vm.assume(aliceShares > 0);
        uint256 balanceOfShares = cut4626.balanceOf(alice);
        // prevent `balanceOfShares` from integer overflow
        if (cut4626.totalSupply() > 0) {
            vm.assume(balanceOfShares < MAX_UINT256 / (cut4626.totalAssets() + 1));
        }
        assertEq(
            cut4626.maxWithdraw(alice),
            cut4626.convertToAssets(cut4626.balanceOf(alice)),
            "`maxWithdraw(account) != convertToAssets(vault.balanceOf(account))`"
        );
    }

    /// @notice Calling `withdraw` reverts when the amount of assets to withdraw is greater than `maxWithdraw(tokenOwner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `withdraw` does not revert on some amount of assets that is greater than `maxWithdraw(tokenOwner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories assets, withdraw
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawRevertsWhenAssetsGtMaxWithdraw(uint256 assets, uint256 aliceShares)
    public virtual initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares) {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        uint256 maxWithdrawAlice = cut4626.maxWithdraw(alice);
        vm.assume(assets > maxWithdrawAlice);
        // 1. Alice withdraw an amount of assets that is greater than maxWithdraw(alice) to Bob
        (bool callWithdraw,) = tryCallerWithdrawAssetsToReceiverFromOwner(alice, assets, bob, alice);
        // 2. Check that the withdraw call failed
        assertFalse(
            callWithdraw, "Alice can withdraw an amount of assets that is greater than `maxWithdraw(alice)` for Bob."
        );
    }

    /**
     *
     *
     * Calling of mint() checks.
     *
     *
     */

    /// @notice Calling `mint` reverts when the amount of shares to mint is greater than `maxMint(tokenReceiver)`
    /// OR `maxMint(account) == type(uint256).max`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback Calling `mint` does not revert on some amount of shares that is greater than `maxMint(tokenReceiver)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories shares, mint
    /// @custom:ercx-concerned-function mint
    function testMintRevertsWhenSharesGtMaxMint(uint256 shares, uint256 aliceAssets, uint256 bobShares) public virtual
    initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares) {
        // Pass the test if cut4626.maxMint(bob) == type(uint256).max 
        if (cut4626.maxMint(bob) != MAX_UINT256) {
            vm.assume(shares > cut4626.maxMint(bob));
            uint256 previewedAssets = cut4626.previewMint(shares);
            vm.assume(previewedAssets > 0);
            vm.assume(previewedAssets <= asset.balanceOf(alice));
            // 1. Alice tries to mint an amount of shares that is greater than maxMint(bob) to Bob
            (bool callMint,) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
            // 2. Check that the mint call failed
            assertFalse(callMint, "Alice can mint an amount of shares that is greater than `maxMint(bob)` for Bob.");
        } else {
            emit log(
                "`maxMint(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default."
            );
        }
    }

    /// @notice Calling `maxMint` returns 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback Calling `maxMint` does not return 2 ** 256 - 1, i.e., there might be a limit set for `maxMint`.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintReturnMaxUint256IfNoLimit()
    public virtual {
       assertEq(cut4626.maxMint(alice), MAX_UINT256, "Calling `maxMint` does not return 2 ** 256 - 1.");
    }

    /**
     *
     *
     * Calling of redeem() checks.
     *
     *
     */

    /// @notice `maxRedeem(account) == vault.balanceOf(account)` (referenced from Solmate and OZ implementation)
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `maxRedeem(account) != vault.balanceOf(account)`
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function maxRedeem
    function testMaxRedeemEqBalanceOfShares(uint256 aliceShares)
    public virtual initializeSharesTwoUsers(aliceShares, 0) {
        vm.assume(aliceShares > 0);
        assertEq(cut4626.maxRedeem(alice), cut4626.balanceOf(alice), "`maxRedeem(account) != vault.balanceOf(account)`");
    }

    /// @notice Calling `redeem` reverts when the amount of shares to redeem is greater than `maxRedeem(tokenOwner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `redeem` does not revert on some amount of shares that is greater than `maxRedeem(tokenOwner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemRevertsWhenSharesGtMaxRedeem(uint256 shares, uint256 aliceShares)
    public virtual initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares) {
        vm.assume(aliceShares > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        uint256 maxRedeemAlice = cut4626.maxRedeem(alice);
        vm.assume(shares > maxRedeemAlice);
        // 1. Alice tries to redeem an amount of shares > maxRedeemAlice to Bob
        (bool callRedeem,) = tryCallerRedeemSharesToReceiverFromOwner(alice, shares, bob, alice);
        // 2. Check that the redeem call failed
        assertFalse(callRedeem, "Alice can redeem an amount of shares that is greater than `maxRedeem(alice)` for Bob.");
    }

    /**
     *
     *
     * Vault transferrable checks.
     *
     *
     */

    /// @notice The vault token is transferrable via `transfer`,
    /// i.e., it does not revert on calls to `transfer`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The vault token is non-transferrable via `transfer`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories eip20
    function testSharesIsTransferAble(uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0)
    public virtual {
        vm.assume(aliceShares > 0);
        uint256 aliceSharesBefore = cut4626.balanceOf(alice);
        tryCallerTransferReceiverShares(alice, bob, aliceShares);
        uint256 aliceSharesAfter = cut4626.balanceOf(alice);
        assertNotEq(aliceSharesBefore, aliceSharesAfter, "The vault token is not transferrable via `transfer`.");
    }

    /// @notice The vault token is transferrable via `transferFrom`,
    /// i.e., it does not revert on calls to `transferFrom`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The vault token is non-transferrable via `transferFrom`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories eip20
    function testSharesIsTransferFromAble(uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0)
    public virtual {
        vm.assume(aliceShares > 0);
        (bool callApprove,) = tryCallerApproveApproveeShares(alice, bob, aliceShares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve shares for Bob.");
        uint256 aliceSharesBefore = cut4626.balanceOf(alice);
        tryCallerTransferFromSenderToReceiverShares(bob, alice, carol, aliceShares);
        uint256 aliceSharesAfter = cut4626.balanceOf(alice);
        assertNotEq(aliceSharesBefore, aliceSharesAfter, "The vault token is not transferrable via `transferFrom`.");
    }

    /**
     *
     *
     * Discrepancy checks between convertTo* and preview*
     *
     *
     */

    /// @notice There is no discrepancy between `convertToShares` and `previewDeposit`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback There is discrepancy between `convertToShares` and `previewDeposit`.
    /// @custom:ercx-categories shares, assets, deposit
    /// @custom:ercx-concerned-function previewDeposit
    function testNoDiscrepancyConvertToSharesAndPreviewDeposit(uint256 assets) public virtual
    assetsOverflowRestriction(assets) {
        vm.assume(assets > 0);
        uint256 ctsShares = cut4626.convertToShares(assets);
        uint256 pdShares = cut4626.previewDeposit(assets);
        assertEq(ctsShares, pdShares, "`convertToShares(assets) != previewDeposit(assets)`");
    }

    /// @notice There is no discrepancy between `convertToAssets` and `previewMint`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback There is discrepancy between `convertToAssets` and `previewMint`.
    /// @custom:ercx-categories shares, assets, mint
    /// @custom:ercx-concerned-function previewMint
    function testNoDiscrepancyConvertToAssetsAndPreviewMint(uint256 shares) public virtual
    sharesOverflowRestriction(shares) {
        vm.assume(shares > 0);
        uint256 ctaShares = cut4626.convertToAssets(shares);
        uint256 pmShares = cut4626.previewMint(shares);
        assertEq(ctaShares, pmShares, "`convertToAssets(shares) != previewMint(shares)`");
    }

    /// @notice There is no discrepancy between `convertToShares` and `previewWithdraw`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback There is discrepancy between `convertToShares` and `previewWithdraw`.
    /// @custom:ercx-categories shares, assets, withdraw
    /// @custom:ercx-concerned-function previewWithdraw
    function testNoDiscrepancyConvertToSharesAndPreviewWithdraw(uint256 assets) public virtual
    assetsOverflowRestriction(assets) {
        vm.assume(assets > 0);
        uint256 ctsShares = cut4626.convertToShares(assets);
        uint256 pwShares = cut4626.previewWithdraw(assets);
        assertEq(ctsShares, pwShares, "`convertToShares(assets) != previewWithdraw(assets)`");
    }

    /// @notice There is no discrepancy between `convertToAssets` and `previewRedeem`.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback There is discrepancy between `convertToAssets` and `previewRedeem`.
    /// @custom:ercx-categories shares, assets, redeem
    /// @custom:ercx-concerned-function previewRedeem
    function testNoDiscrepancyConvertToAssetsAndPreviewRedeem(uint256 shares) public virtual
    sharesOverflowRestriction(shares) {
        vm.assume(shares > 0);
        uint256 ctaShares = cut4626.convertToAssets(shares);
        uint256 prShares = cut4626.previewRedeem(shares);
        assertEq(ctaShares, prShares, "`convertToAssets(shares) != previewRedeem(shares)`");
    }

    /**
     *
     *
     * `totalAssets` and `totalSupply` functions feature checks
     *
     *
     */

    /// @notice `vault.totalAssets() < asset.balanceOf(vault)`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalAssets() >= asset.balanceOf(vault)`
    /// @custom:ercx-categories assets, total assets
    /// @custom:ercx-concerned-function totalAssets
    function testTotalAssetsLtVaultAssetsBalance()
	public virtual {
		uint256 totalAssets = cut4626.totalAssets();
		uint256 balance = asset.balanceOf(address(cut4626));
        assertLt(totalAssets, balance, "`vault.totalAssets() >= asset.balanceOf(vault)`");
    }

    /// @notice `vault.totalAssets() > asset.balanceOf(vault)`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalAssets() <= asset.balanceOf(vault)`
    /// @custom:ercx-categories assets, total assets
    /// @custom:ercx-concerned-function totalAssets
    function testTotalAssetsGtVaultAssetsBalance()
	public virtual {
		uint256 totalAssets = cut4626.totalAssets();
		uint256 balance = asset.balanceOf(address(cut4626));
        assertGt(totalAssets, balance, "`vault.totalAssets() <= asset.balanceOf(vault)`");
    }

    /// @notice `vault.totalAssets() > 0`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalAssets() == 0`
    /// @custom:ercx-categories total assets
    /// @custom:ercx-concerned-function totalAssets
    function testTotalAssetsGtZero()
	public virtual {
		uint256 totalAssets = cut4626.totalAssets();
        assertGt(totalAssets, 0, "`vault.totalAssets() == 0`");
    }

    /// @notice `vault.totalSupply() > 0`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalSupply() == 0`
    /// @custom:ercx-categories total supply
    /// @custom:ercx-concerned-function totalSupply
    function testTotalSupplyGtZero()
	public virtual {
		uint256 totalSupply = cut4626.totalSupply();
        assertGt(totalSupply, 0, "`vault.totalSupply() == 0`");
    }

    /// @notice `vault.totalAssets() < vault.totalSupply()`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalAssets() >= vault.totalSupply()`
    /// @custom:ercx-categories total assets, total supply
    /// @custom:ercx-concerned-function totalAssets, totalSupply
    function testTotalAssetsLtTotalSupply()
	public virtual {
		uint256 totalAssets = cut4626.totalAssets();
        uint256 totalSupply = cut4626.totalSupply();
        assertLt(totalAssets, totalSupply, "`vault.totalAssets() >= vault.totalSupply()`");
    }

    /// @notice `vault.totalAssets() > vault.totalSupply()`
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback `vault.totalAssets() <= vault.totalSupply()`
    /// @custom:ercx-categories total assets, total supply
    /// @custom:ercx-concerned-function totalAssets, totalSupply
    function testTotalAssetsGtTotalSupply()
	public virtual {
		uint256 totalAssets = cut4626.totalAssets();
        uint256 totalSupply = cut4626.totalSupply();
        assertGt(totalAssets, totalSupply, "`vault.totalAssets() <= vault.totalSupply()`");
    }
}
