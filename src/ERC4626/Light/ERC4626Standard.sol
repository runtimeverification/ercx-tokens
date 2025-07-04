// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC4626Abstract.sol";

/// @notice Abstract contract that consists of testing functions which test for properties from the standard
/// stated in the official EIP4626 specification.
abstract contract ERC4626Standard is ERC4626Abstract {

    /****************************
    *****************************
    *
    * MANDATORY checks.
    *
    *****************************
    ****************************/

    /****************************
    *
    * EIP-20's optional metadata mandatory checks.
    *
    ****************************/

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `name`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `name` is not callable.
    /// @custom:ercx-categories eip20
    function testNameCallable() 
    public virtual {
        (bool success, ) = tryCallName();
        assertTrue(success, "The function `name` is not callable.");
    }

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `symbol`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `symbol` is not callable.
    /// @custom:ercx-categories eip20
    function testSymbolCallable() 
    public virtual {
        (bool success, ) = tryCallSymbol();
        assertTrue(success, "The function `symbol` is not callable.");
    }

    /// @notice ERC4626 MUST implement EIP-20’s optional metadata extensions (in this case is `decimals`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The function `decimals` is not callable.
    /// @custom:ercx-categories eip20
    function testDecimalsCallable() 
    public virtual {
        (bool success, ) = tryCallVaultDecimals();
        assertTrue(success, "The function `decimals` is not callable.");
    }


    /****************************
    *
    * `asset` function mandatory checks
    *
    ****************************/

    /// @notice Calling `asset` function MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `asset` function reverts.
    /// @custom:ercx-categories assets
    /// @custom:ercx-concerned-function asset
    function testAssetDoesNotRevert() 
    public virtual {
        (bool success, ) = tryCallAsset();
        assertTrue(success, "Calling the `asset` function reverts.");
    }


    /****************************
    *
    * `totalAssets` function mandatory checks
    *
    ****************************/

    /// @notice Calling `totalAssets` function MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `totalAssets` function reverts.
    /// @custom:ercx-categories assets, total assets
    /// @custom:ercx-concerned-function totalAssets
    function testTotalAssetsDoesNotRevert() 
    public virtual {
        (bool success, ) = tryCallTotalAssets();
        assertTrue(success, "Calling the `totalAssets` function reverts.");
    }


    /****************************
    *
    * `convertToShares` function mandatory checks
    *
    ****************************/

    /// @notice Calling `convertToShares` MUST NOT show any variations depending on the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` shows variations in outputs depending on the caller.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: convertToShares.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesNoVariationOnCaller(uint256 aliceAssets, uint256 bobAssets, uint256 assets)  
    initializeAssetsTwoUsers(aliceAssets, bobAssets) assetsOverflowRestriction(assets) 
    public virtual {
        vm.assume(assets > 0);
        (bool callAlice, uint256 sharesSeenByAlice) = tryCallerCallConvertToSharesAssets(alice, assets);
        (bool callBob, uint256 sharesSeenByBob) = tryCallerCallConvertToSharesAssets(bob, assets);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `convertToShares`");
        assertEq(sharesSeenByAlice, sharesSeenByBob, "Shares seen by Alice differs from shares seen by Bob after successful `convertToShares` call.");
    }

    /// @notice Calling `convertToShares` MUST NOT revert when there is no integer overflow caused by an unreasonably large input.
    /// @dev Limit for overflow is reference from  Solmate EIP-4626
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` reverts even if there is no integer overflow caused by an unreasonably large input.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesDoesNotRevertWhenNoIntOverflow(uint256 assets)  
    assetsOverflowRestriction(assets) 
    public virtual {
        vm.assume(assets > 0);
        (bool success, ) = tryCallConvertToSharesAssets(assets);
        assertTrue(success, "Calling `convertToShares` reverts even if there is no integer overflow caused by an unreasonably large input.");
    }


    /****************************
    *
    * `convertToAssets` function mandatory checks
    *
    ****************************/

    /// @notice Calling `convertToAssets` MUST NOT show any variations depending on the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` shows variations in outputs depending on the caller.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsNoVariationOnCaller(uint256 aliceShares, uint256 bobShares, uint256 shares)  
    initializeSharesTwoUsers(aliceShares, bobShares) sharesOverflowRestriction(shares) 
    public virtual {  
        vm.assume(shares > 0);   
        (bool callAlice, uint256 assetsSeenByAlice) = tryCallerCallConvertToAssetsShares(alice, shares);
        (bool callBob, uint256 assetsSeenByBob) = tryCallerCallConvertToAssetsShares(bob, shares);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `convertToAssets`");
        assertEq(assetsSeenByAlice, assetsSeenByBob, "Assets seen by Alice differs from assets seen by Bob after successful `convertToAssets` call.");
    }

    /// @notice Calling `convertToAssets` MUST NOT revert when there is no integer overflow caused by an unreasonably large input.
    /// @dev Limit for overflow is reference from  Solmate EIP-4626
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` reverts when there is no integer overflow caused by an unreasonably large input.
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsDoesNotRevertWhenNoIntOverflow(uint256 shares)  
    sharesOverflowRestriction(shares) 
    public virtual {
        vm.assume(shares > 0);
        (bool success, ) = tryCallConvertToAssetsShares(shares);
        assertTrue(success, "Calling `convertToAssets` reverts even if there is no integer overflow caused by an unreasonably large input.");
    }


    /****************************
    *
    * `maxDeposit` function mandatory checks
    *
    ****************************/

    /// @notice Calling `maxDeposit` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxDeposit` reverts.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositDoesNotRevert()
    public virtual {
        (bool success, ) = tryCallMaxDepositReceiver(alice);
        assertTrue(success, "Calling the `maxDeposit` function reverts.");
    }

    /// @notice `maxDeposit` assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
    /// @dev Initialize Alice and Bob different asset balances and check if calling `maxDeposit` on them returns the same value.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxDeposit` does not assume that the user has infinite assets, i.e. relies on balanceOf of asset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: maxDeposit.
    /// @custom:ercx-categories assets, deposit, balance
    /// @custom:ercx-concerned-function maxDeposit
    function testMaxDepositNotRelyBalanceOfAssets(uint256 aliceAssets, uint256 bobAssets) 
    initializeAssetsTwoUsers(aliceAssets, bobAssets) 
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        uint256 bobAssetBalance = asset.balanceOf(bob);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(bobAssetBalance > 0);
        vm.assume(aliceAssetBalance != bobAssetBalance);
        (bool callForAlice, uint256 maxDepositAlice) = tryCallerCallMaxDepositReceiver(bob, alice);
        (bool callForBob, uint256 maxDepositBob) = tryCallerCallMaxDepositReceiver(alice, bob);
        conditionalSkip(!callForAlice || !callForBob, "Inconclusive test: Failed to call `maxDeposit`.");
        assertEq(maxDepositAlice, maxDepositBob, "`maxDeposit(alice) != maxDeposit(bob)` even though both balances of assets differ.");
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
    function testMaxDepositNotHigherThanActualMax(uint256 assets, uint256 aliceAssets) 
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets) 
    public virtual {
        // Pass the test if cut4626.maxDeposit(bob) == type(uint256).max 
        if (cut4626.maxDeposit(bob) != MAX_UINT256) {
            vm.assume(assets <= asset.balanceOf(alice));
            vm.assume(cut4626.previewDeposit(assets) > 0);
            // Pass the test if cut4626.maxDeposit(bob) == 0
            if (cut4626.maxDeposit(bob) > 0) {
                vm.assume(assets <= cut4626.maxDeposit(bob));    
                // 1. Alice deposits an amount of assets that is <= maxDepositBob to Bob
                (bool callDeposit, ) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, assets, bob);
                // 2. Check that the deposit call succeeded
                assertTrue(callDeposit, "Alice cannot deposit a number of assets that is lesser than `maxDeposit(bob)` for Bob.");                        
            }
            else {
                emit log("`maxDeposit(account) == 0`, and thus, the test passes by default.");
            }
        }            
        else {
            emit log("`maxDeposit(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default.");
        }
    }


    /****************************
    *
    * `previewDeposit` function mandatory checks
    *
    ****************************/

    /// @notice Calling `previewDeposit` returns as close to and no more than the exact amount of Vault shares (up to `delta`-approximation) that would be minted in a deposit call in the same transaction. 
    /// I.e. deposit should return the same or more shares as previewDeposit if called in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewDeposit` returns more than the exact amount of Vault shares (up to `delta`-approximation) that would be minted in a deposit call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories shares, deposit
    /// @custom:ercx-concerned-function previewdeposit
    function testPreviewDepositSameOrLessThanDeposit(uint256 assets, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(assets <= asset.balanceOf(alice));
        // 1. Find out the previewDeposit(assets)
        uint256 previewedShares = cut4626.previewDeposit(assets);
        vm.assume(previewedShares > 0);
        // 2. Find out the mintedShares output value from `deposit(assets, bob)` call
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, assets, bob);
        // Skip the test if the deposit call failed and mintedShares == 0
        conditionalSkip(!callDeposit && mintedShares == 0, "Inconclusive test: Alice cannot deposit assets for Bob.");
        // 3. Compare the values found in step 1 and 2
        assertApproxLeAbs(previewedShares, mintedShares, delta, "`previewDeposit(assets) > deposit(assets)` (up to `delta`-approximation)");
    }


    /****************************
    *
    * `deposit` function mandatory checks
    *
    ****************************/

    /// @notice Calling `deposit` emits Deposit event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `deposit` does not emit Deposit event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: deposit, approve.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function deposit
    function testDepositEmitDepositEvent(uint256 assets, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(assets > 0);
        vm.assume(assets <= aliceAssetBalance);
        uint256 shares = cut4626.previewDeposit(assets);
        vm.assume(shares > 0);
        // 1. Alice must approve vault sufficient allowance of assets
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), aliceAssetBalance);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve assets for vault.");
        // 3. This event emission check can only be done if deposit call in step 2 succeeds 
        vm.expectEmit(true, true, false, false);
        emit Deposit(alice, bob, assets, shares);
        // 2. Alice tries to call `deposit(assets, bob)`
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiver(alice, assets, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        assertTrue(callDeposit, "Alice cannot deposit assets for Bob."); 
    }

    /// @notice `deposit` supports EIP-20 `approve` / `transferFrom` on `asset` as a deposit flow, i.e.,
    /// the caller must first approve the vault enough assets' allowance before he/she can make a deposit, where 
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `deposit` does not support EIP-20 `approve` / `transferFrom` on `asset` as a deposit flow.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories deposit, assets
    /// @custom:ercx-concerned-function deposit
    function testDepositSupportsEIP20ApproveTransferFromAssets(uint256 aliceAssets, uint256 assets)
	initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
	public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(assets > 0);
        uint256 previewDepositShares = cut4626.previewDeposit(assets);
        vm.assume(previewDepositShares > 0);
        vm.assume(assets <= aliceAssetBalance);
        // 1. Alice approves enough assets allowance to the vault
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), aliceAssetBalance);
        // 2. Check that approve call succeeded
        assertTrue(callApprove, "Alice cannot approve vault assets.");
        // 3. Alice calls `deposit(assets, bob)`
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiver(alice, assets, bob);
        // 4. Check that the deposit call succeeded
        assertTrue(callDeposit, "Alice cannot deposit assets to Bob even though she has provided enough assets' allowance to the vault.");
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
    function testDepositFailsIfInsufficientAssetsAllowanceToVault(uint256 aliceAssets, uint256 assets)
	initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
	public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(assets > 0);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(assets < aliceAssetBalance);
        uint256 previewDepositShares = cut4626.previewDeposit(aliceAssetBalance);
        vm.assume(previewDepositShares > 0);
        // 1. Alice approves enough assets allowance to the vault
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), assets);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve vault assets.");
        // 2. Alice calls `deposit(assets, bob)`
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiver(alice, aliceAssetBalance, bob);
        // 3. Check that the deposit call failed
        assertFalse(callDeposit, "Alice can deposit assets to Bob even though she has not provided enough assets' allowance to the vault.");
	}


    /****************************
    *
    * `maxWithdraw` function mandatory checks
    *
    ****************************/

    /// @notice `maxWithdraw` MUST NOT return a value higher than the actual maximum that would be accepted, 
    /// i.e., a `withdraw` call can be called on any amount that is lesser than or equal to `maxWithdraw(owner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxWithdraw` returns a value higher than the actual maximum that would be accepted, 
    /// i.e., a `withdraw` call cannot be called on an amount that is lesser than or equal to `maxWithdraw(owner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories assets, withdraw
    /// @custom:ercx-concerned-function maxWithdraw
    function testMaxWithdrawNotHigherThanActualMax(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares) 
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // Do the property test only if maxWithdraw > 0
        if (cut4626.maxWithdraw(alice) > 0) {
            vm.assume(assets <= cut4626.maxWithdraw(alice));    
            // 1. Alice tries calling `withdraw(assets, bob, alice)` (i.e., from her own shares) where `assets <= cut4626.maxWithdraw(alice)`
            (bool callWithdraw, ) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, bob);
            // 2. Check that the withdraw call succeeded
            assertTrue(callWithdraw, "Alice cannot withdraw an amount of assets that is lesser than `maxWithdraw(alice)` for Bob.");
        }
    }

    /// @notice Calling `maxWithdraw` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxWithdraw` reverts.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function maxWithdraw
    function testMaxWithdrawDoesNotRevert()
    public virtual {
        (bool success, ) = tryCallMaxWithdrawOwner(alice);
        assertTrue(success, "Calling the `maxWithdraw` function reverts.");
    }


    /****************************
    *
    * `previewWithdraw` function mandatory checks
    *
    ****************************/

    /// @notice Calling `previewWithdraw` returns as close to and no fewer than the exact amount of Vault shares (up to `delta`-approximation) that would be burned in a withdraw call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if called in the same transaction
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewWithdraw` returns lesser than the exact amount of Vault shares (up to `delta`-approximation) that would be burned in a withdraw call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: withdraw.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function previewWithdraw
    function testPreviewWithdrawSameOrMoreThanWithdraw(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        // 1. Find out cut4626.previewWithdraw(assets)
        uint256 shares = cut4626.previewWithdraw(assets);
        vm.assume(shares <= aliceShares);
        vm.assume(shares > 0);
        // 2. Find out the withdrawnShares output value from `withdraw(assets, carol, alice)` call
        (bool callWithdraw, uint256 withdrawnShares) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, carol);
        // Skip the test if the withdraw call failed and withdrawnShares == 0
        conditionalSkip(!callWithdraw && withdrawnShares == 0, "Inconclusive test: Alice cannot withdraw assets for Carol.");
        // 3. Compare the values found in step 1 and 2
        assertApproxGeAbs(shares, withdrawnShares, delta, "`previewWithdraw(assets) < withdraw(assets)` (up to `delta`-approximation)");
    }


    /****************************
    *
    * `withdraw` function mandatory checks
    *
    ****************************/

    /// @notice Calling `withdraw` emits the Withdraw event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `withdraw` does not emit Withdraw event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: withdraw.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawEmitWithdrawEvent(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        uint256 shares = cut4626.previewWithdraw(assets);
        vm.assume(shares <= aliceShares);
        vm.assume(shares > 0);
        // 2. This event emission check can only be done if withdraw call in step 2 succeeds 
        vm.expectEmit(true, true, true, true);
        emit Withdraw(alice, carol, alice, assets, shares);
        // 1. Alice tries to call `withdraw(assets, carol, alice)`
        // note: owner self withdraw does not need approval of allowance
        (bool callWithdraw, ) = tryCallerWithdrawAssetsToReceiverFromOwner(alice, assets, carol, alice);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Alice cannot withdraw positive amount of assets to carol.");
        assertTrue(callWithdraw, "Alice cannot withdraw assets for Carol.");
    }

    /// @notice `withdraw` supports a withdraw flow where the shares are burned from the owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `withdraw` may not support a withdraw flow where the shares are burned from the owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSupportsBurnSharesFromOwnerWhereOwnerIsMsgSender(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        uint256 shares = cut4626.previewWithdraw(assets);
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(shares <= aliceShares);
        vm.assume(shares > 0);
        // 1. Alice (the `owner` of the `shares`) tries to call `withdraw(assets, carol, alice)` without approval of allowance
        (bool callWithdraw, uint256 burnedShares) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, carol);
        // 2a. Check that the withdraw call succeeded
        assertTrue(callWithdraw, "Alice cannot withdraw assets for Carol.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 aliceSharesAfter = cut4626.balanceOf(alice);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");            
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, burnedShares, delta, "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation).");
        // 2c. Check that the right amount of shares is burnt from the Alice shares' balance
        assertGt(aliceShares, aliceSharesAfter, "Alice's balance of shares does not decrease as expected.");
        assertApproxEqAbs(aliceShares - aliceSharesAfter, burnedShares, delta, "Alice's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation).");        
    }

    /// @notice `withdraw` supports a withdraw flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `withdraw` may not support a withdraw flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw, shares
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawSupportsBurnSharesFromOwnerWhereOwnerApprovesMsgSender(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        uint256 shares = cut4626.previewWithdraw(assets);
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(shares <= aliceShares);
        vm.assume(shares > 0);
        // 1. Bob (non-`owner` of the `shares`) tries to call `withdraw(assets, carol, alice)` with approval of allowance
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(bob, assets, carol, alice);
        // 2a. Check that the withdraw call succeeded
        assertTrue(callWithdraw, "Bob cannot withdraw Alice's assets for Carol even though Alice has approved Bob enough allowance.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");            
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, burnedShares, delta, "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation).");
        // 2c. Check that the right amount of shares is burnt from the Alice shares' balance
        assertGt(aliceShares, cut4626.balanceOf(alice), "Alice's balance of shares does not decrease as expected.");
        assertApproxEqAbs(aliceShares - cut4626.balanceOf(alice), burnedShares, delta, "Alice's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation).");
    }


    /****************************
    *
    * `maxMint` function mandatory checks
    *
    ****************************/

    /// @notice Calling `maxMint` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxMint` reverts.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintDoesNotRevert()
    public virtual {
        (bool success, ) = tryCallMaxMintReceiver(alice);
        assertTrue(success, "Calling the `maxMint` function reverts.");
    }

    /// @notice `maxMint` assumes that the user has infinite assets, i.e. MUST NOT rely on balanceOf of asset.
    /// @dev Initialize Alice and Bob different asset balances and check if calling `maxMint` on them returns the same value.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxMint` does not assume that the user has infinite assets, i.e. relies on balanceOf of asset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: maxMint.    
    /// @custom:ercx-categories assets, mint, balance
    /// @custom:ercx-concerned-function maxMint
    function testMaxMintNotRelyBalanceOfAssets(uint256 aliceAssets, uint256 bobAssets)
    initializeAssetsTwoUsers(aliceAssets, bobAssets) 
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        uint256 bobAssetBalance = asset.balanceOf(bob);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(bobAssetBalance > 0);
        vm.assume(aliceAssetBalance != bobAssetBalance);
        (bool callForAlice, uint256 maxMintAlice) = tryCallerCallMaxMintReceiver(bob, alice);
        (bool callForBob, uint256 maxMintBob) = tryCallerCallMaxMintReceiver(alice, bob);
        conditionalSkip(!callForAlice || !callForBob, "Inconclusive test: Failed to call `maxMint`.");
        assertEq(maxMintAlice, maxMintBob, "`maxMint(alice) != maxMint(bob)` even though both balances of assets differ.");
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
    function testMaxMintNotHigherThanActualMax(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares) 
    public virtual {
        // Pass the test if cut4626.maxMint(bob) == type(uint256).max 
        if (cut4626.maxMint(bob) != MAX_UINT256) {
            uint256 aliceAssetBalance = asset.balanceOf(alice);
            vm.assume(shares > 0);
            vm.assume(aliceAssetBalance > 0);
            uint256 previewedAssets = cut4626.previewMint(shares);
            vm.assume(previewedAssets > 0);
            vm.assume(previewedAssets <= aliceAssetBalance);
            // Pass the test if maxMint == 0
            if (cut4626.maxMint(bob) > 0) {
                vm.assume(shares <= cut4626.maxMint(bob));    
                // 1. Alice mints an amount of shares <= maxMintBob to Bob
                (bool callMint, ) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
                // 2. Check that the mint call succeeded
                assertTrue(callMint, "Alice cannot mint a number of shares that is lesser than `maxMint(bob)` for Bob.");
            }
            else {
                emit log("`maxMint(account) == 0`, and thus, the test passes by default.");
            }
        }
        else {
            emit log("`maxMint(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default.");
        }
    }


    /****************************
    *
    * `previewMint` function mandatory checks
    *
    ****************************/

    /// @notice `previewMint` returns as close to and no fewer than the exact amount of assets (up to `delta`-approximation) that would be deposited in a mint call in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `previewMint` does not return as close to and no fewer than the exact amount of assets (up to `delta`-approximation) that would be deposited in a mint call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: mint, approve.
    /// @custom:ercx-categories assets, mint
    /// @custom:ercx-concerned-function previewMint
    function testPreviewMintSameOrMoreThanMint(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(shares > 0);
        // 1. Find out cut4626.previewMint(shares)
        uint256 previewedAssets = cut4626.previewMint(shares);
        vm.assume(previewedAssets > 0);
        vm.assume(previewedAssets <= aliceAssetBalance);
        // 2. Find out the mintedAssets output value from `mint(shares, bob)` call
        (bool callMint, uint256 mintedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed and mintedAssets == 0
        conditionalSkip(!callMint && mintedAssets == 0, "Inconclusive test: Alice cannot mint shares for Bob.");
        // 3. Compare the values found in step 1 and 2
        assertApproxGeAbs(previewedAssets, mintedAssets, delta, "`previewMint(shares) < mint(shares)` (up to `delta`-approximation)");
    }


    /****************************
    *
    * `mint` function mandatory checks
    *
    ****************************/

    /// @notice Calling `mint` emits the Deposit event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `mint` does not emits the Deposit event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: mint, approve.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function mint
    function testMintEmitDepositEvent(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(shares > 0);
        uint256 assets = cut4626.previewMint(shares);
        vm.assume(assets > 0);
        vm.assume(assets <= aliceAssetBalance);
        // 1. Alice must approve vault sufficient allowance of assets
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), aliceAssetBalance);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve assets for vault.");
        // 3. This event emission check can only be done if mint call in step 2 succeeds
        vm.expectEmit(true, true, false, false);
        emit Deposit(alice, bob, assets, shares);
        // 2. Alice tries to call `mint(shares, bob)`
        (bool callMint, ) = tryCallerMintSharesToReceiver(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint positive amount of shares to Bob.");
        assertTrue(callMint, "Alice cannot mint shares for Bob.");
    }

    /// @notice `mint` supports EIP-20 `approve` / `transferFrom` on `asset` as a mint flow, i.e.,
    /// the caller must first approve the vault enough assets' allowance before he/she can make a mint call, where 
    /// the vault will do a `transferFrom` the caller to itself some assets in exchange for shares to be minted for the caller.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `mint` does not support EIP-20 `approve` / `transferFrom` on `asset` as a mint flow.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories mint, assets
    /// @custom:ercx-concerned-function mint
    function testMintSupportsEIP20ApproveTransferFromAssets(uint256 aliceAssets, uint256 shares)
	initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
	public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(shares > 0);
        uint256 previewMintAssets = cut4626.previewMint(shares);
        vm.assume(previewMintAssets > 0);
        vm.assume(previewMintAssets <= aliceAssetBalance);
        // 1. Alice approves enough assets allowance to the vault
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), aliceAssetBalance);
        // 2. Check that approve call succeeded
        assertTrue(callApprove, "Alice cannot approve vault assets.");
        // 3. Alice calls `mint(shares, bob)`
        (bool callMint, ) = tryCallerMintSharesToReceiver(alice, shares, bob);
        // 4. Check that the mint call succeeded
        assertTrue(callMint, "Alice cannot mint shares to Bob even though she has provided enough assets' allowance to the vault.");
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
    function testMintFailsIfInsufficientAssetsAllowanceToVault(uint256 aliceAssets, uint256 shares, uint256 approvedAssets)
	initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
	public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(shares > 0);
        uint256 previewMintAssets = cut4626.previewMint(shares);
        vm.assume(previewMintAssets > 0);
        vm.assume(previewMintAssets <= aliceAssetBalance);
        vm.assume(approvedAssets < previewMintAssets);
        // 1. Alice approves enough assets allowance to the vault
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), approvedAssets);
        // Skip test if approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve vault assets.");
        // 2. Alice calls `mint(shares, bob)`
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiver(alice, shares, bob);
        if (callMint) {
            // 3a. Check that the depositedAssets <= approvedAssets if the mint call succeeded
            assertLe(depositedAssets, approvedAssets, "Alice can mint shares to Bob even though she has not provided enough assets' allowance to the vault.");
        }
        else {
            // 3b. Check that the mint call failed otherwise
            assertFalse(callMint, "Alice can mint shares to Bob even though she has not provided enough assets' allowance to the vault.");
        }
	}


    /****************************
    *
    * `maxRedeem` function mandatory checks
    *
    ****************************/

    /// @notice `maxRedeem` MUST NOT return a value higher than the actual maximum that would be accepted,
    /// i.e., a `redeem` call can be called on any amount that is lesser than or equal to `maxRedeem(owner)`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `maxRedeem` returns a value higher than the actual maximum that would be accepted,
    /// i.e., a `redeem` call cannot be called on an amount that is lesser than or equal to `maxRedeem(owner)`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function maxRedeem
    function testMaxRedeemNotHigherThanActualMax(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares) 
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // Do the property test only if maxRedeem > 0
        if (cut4626.maxRedeem(alice) > 0) {
            vm.assume(shares <= cut4626.maxRedeem(alice));    
            // 1. Alice tries calling `redeem(shares, bob, alice)` (i.e., from her own shares) where `shares <= cut4626.maxRedeem(alice)`
            (bool callRedeem, ) = tryOwnerRedeemSharesToReceiverWithChecks(alice, shares, bob);
            // 2. Check that the redeem call succeeded
            assertTrue(callRedeem, "Alice cannot redeem an amount of shares that is lesser than `maxRedeem(alice)` for Bob.");
        }
    }

    /// @notice Calling `maxRedeem` MUST NOT revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `maxRedeem` reverts.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function maxRedeem
    function testMaxRedeemDoesNotRevert()
    public virtual {
        (bool success, ) = tryCallMaxRedeemOwner(alice);
        assertTrue(success, "Calling the `maxRedeem` function reverts.");
    }


    /****************************
    *
    * `previewRedeem` function mandatory checks
    *
    ****************************/

    /// @notice Calling `previewRedeem` returns as close to and no more than the exact amount of assets (up to `delta`-approximation) that would be withdrawn in a redeem call in the same transaction.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewRedeem` returns more than the exact amount of assets (up to `delta`-approximation) that would be withdrawn in a redeem call in the same transaction
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: redeem.
    /// @custom:ercx-categories redeem, assets
    /// @custom:ercx-concerned-function previewRedeem
    function testPreviewRedeemSameOrLessThanRedeem(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        // 1. Find out cut4626.previewRedeem(shares)
        uint256 previewedAssets = cut4626.previewRedeem(shares);
        vm.assume(previewedAssets > 0);
        // 2. Find out the redeemedAssets output value from `redeem(shares, carol, alice)` call
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, shares, carol);
        // Skip the test if the redeem call failed and redeemedAssets == 0
        conditionalSkip(!callRedeem && redeemedAssets == 0, "Inconclusive test: Alice cannot redeem shares for Carol.");
        // 3. Compare the values found in step 1 and 2
        assertApproxLeAbs(previewedAssets, redeemedAssets, delta, "`previewRedeem(shares) > redeem(shares)` (up to `delta`-approximation)");
    }   


    /****************************
    *
    * `redeem` function mandatory checks
    *
    ****************************/

    /// @notice Calling `redeem` emits the Withdraw event.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `redeem` does not emit Withdraw event.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: redeem.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function redeem
    function testRedeemEmitWithdrawEvent(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 2. This event emission check can only be done if withdraw call in step 2 succeeds 
        vm.expectEmit(true, true, true, true);
        emit Withdraw(alice, carol, alice, assets, shares);
        // 1. Alice tries to call `redeem(shares, carol, alice)`
        // note: owner self-redeeming does not need approval of allowance
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwner(alice, shares, carol, alice);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem positive amount of shares to Carol.");
        assertTrue(callRedeem, "Alice cannot redeem shares for carol.");
    }

    /// @notice `redeem` supports a redeem flow where the shares are burned from owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `redeem` may not support a redeem flow where the shares are burned from owner (up to `delta`-approximation), who is the msg.sender as well, directly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemSupportsBurnSharesFromOwnerWhereOwnerIsMsgSender(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
    public virtual {
        uint256 totalSupplyBefore = cut4626.totalSupply();
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // 1. Alice (the `owner` of the `shares`) tries to call `redeem(shares, carol, alice)` without approval of allowance
        (bool callRedeem, ) = tryOwnerRedeemSharesToReceiverWithChecks(alice, shares, carol);
        // 2a. Check that the redeem call succeeded
        assertTrue(callRedeem, "Alice cannot redeem shares for Carol.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 aliceSharesAfter = cut4626.balanceOf(alice);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, shares, delta, "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation).");
        // 2c. Check that the right amount of shares is burnt from Alice shares' balance
        assertGt(aliceShares, aliceSharesAfter, "Alice's balance of shares does not decrease as expected.");
        assertApproxEqAbs(aliceShares - aliceSharesAfter, shares, delta, "Alice's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation).");
    }

    /// @notice `redeem` supports a redeem flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `redeem` supports a redeem flow where the shares are burned from owner directly (up to `delta`-approximation) and that the msg.sender has EIP-20 approval over the shares of owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem, shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemSupportsBurnSharesFromOwnerWhereOwnerApprovesMsgSender(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
    public virtual {
        uint256 totalSupplyBefore = cut4626.totalSupply();
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // 1. Bob (non-`owner` of the `shares`) tries to call `redeem(shares, carol, alice)` with apporval of allowance
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(bob, shares, carol, alice);
        // 2a. Check that the redeem call succeeded
        assertTrue(callRedeem, "Bob cannot redeem Alice's shares for Carol even though Alice has approved Bob enough allowance.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        uint256 aliceSharesAfter = cut4626.balanceOf(alice);
        // 2b. Check that the right amount of shares is burnt from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of the vault does not decrease as expected.");
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, shares, delta, "The total supply of the vault does not decrease by the burned amount as expected (up to `delta`-approximation).");
        // 2c. Check that the right amount of shares is burnt from Alice shares' balance
        assertGt(aliceShares, aliceSharesAfter, "Alice's balance of shares does not decrease as expected.");
        assertApproxEqAbs(aliceShares - aliceSharesAfter, shares, delta, "Alice's balance of shares does not decrease by the burned amount as expected (up to `delta`-approximation).");
    }


    /****************************
    *****************************
    *
    * RECOMMENDED checks.
    *
    *****************************
    ****************************/

    /****************************
    *
    * `withdraw` function recommended checks
    *
    ****************************/   

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
    function testWithdrawSenderCanSpendBelowSharesAllowance(uint256 assets, uint256 aliceShares)
	initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
	public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        uint256 shares = cut4626.previewWithdraw(assets);
        // restrict `shares` to ensures `assets` is acceptable
        vm.assume(shares <= aliceShares);
        // 1. Alice approves enough shares allowance to Bob
        (bool callApprove, ) = tryCallerApproveApproveeShares(alice, bob, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve shares for Bob.");
        // 2. Bob tries to call `withdraw(assets, carol, alice)`
        (bool callWithdraw, ) = tryCallerWithdrawAssetsToReceiverFromOwner(bob, assets, carol, alice);
        // 3. Check that the withdraw call succeeded
        assertTrue(callWithdraw, "Bob cannot withdraw assets from Alice's account for Carol even though he has enough allowance from Alice.");
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
    function testWithdrawSenderCannotSpendAboveSharesAllowance(uint256 assets, uint256 approvedShares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);  
        uint256 previewWithdrawalAmount = cut4626.previewWithdraw(assets);
        vm.assume(previewWithdrawalAmount < aliceShares);
        vm.assume(approvedShares < previewWithdrawalAmount);
        vm.assume(approvedShares < aliceShares);
        // 1. Alice approves insufficient shares allowance to Bob
        (bool callApprove, ) = tryCallerApproveApproveeShares(alice, bob, approvedShares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve shares for Bob.");
        // 2. Bob tries to call `withdraw(assets, carol, alice)`
        (bool callWithdraw, ) = tryCallerWithdrawAssetsToReceiverFromOwner(bob, assets, carol, alice);
        // 3. Check that the withdraw call failed
        assertFalse(callWithdraw, "Bob can withdraw assets from Alice's account for Carol even though he does not have enough allowance from Alice.");
    }
    
    /****************************
    *
    * `redeem` function recommended checks
    *
    ****************************/
    
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
	function testRedeemSenderCanSpendBelowSharesAllowance(uint256 shares, uint256 aliceShares)
	initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
	public virtual {
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 1. Alice approves enough shares allowance to Bob
        (bool callApprove, ) = tryCallerApproveApproveeShares(alice, bob, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve shares for Bob.");
        // 2. Bob tries to call `redeem(shares, carol, alice)`
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwner(bob, shares, carol, alice);
        // 3. Check that the redeem call succeeded
        assertTrue(callRedeem, "Bob cannot redeem shares from Alice's account for Carol even though he has enough allowance from Alice.");
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
    function testRedeemSenderCannotSpendAboveSharesAllowance(uint256 shares, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        vm.assume(shares <= aliceShares);
        uint256 assets = cut4626.previewRedeem(shares);
        vm.assume(assets > 0);
        // 1. Alice approves insufficient shares allowance to Bob
        (bool callApprove, ) = tryCallerApproveApproveeShares(alice, bob, shares);
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve shares for Bob.");
        // 2. Bob tries to call `redeem(shares + 1, carol, alice)`
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwner(bob, shares + 1, carol, alice);
        // 3. Check that the redeem call failed
        assertFalse(callRedeem, "Bob can redeem shares from Alice's account for Carol even though he does not have enough allowance from Alice.");
    }

    /****************************
    *
    * vault.decimals() check
    *
    ****************************/

    /// @notice The `vault.decimals()` SHOULD be greater than or equal to `asset.decimals()`.
    /// @dev Source: Last paragraph of https://eips.ethereum.org/EIPS/eip-4626#security-considerations
	/// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `vault.decimals()` is lesser than `asset.decimals()`.    
    /// @custom:ercx-categories eip20
    /// @custom:ercx-concerned-function decimals
    function testVaultDecimalsGeAssetDecimals()
    public virtual {
        (bool vaultSuccess, uint8 vaultDecimals) = tryCallVaultDecimals();
        (bool assetSuccess, uint8 assetDecimals) = tryCallAssetDecimals();
        // Skip the test if the vault.decimal call failed
        conditionalSkip(!vaultSuccess, "Inconclusive test: vault is unable to call `decimals()`");
        // Skip the test if the asset.decimal call failed
        conditionalSkip(!assetSuccess, "Inconclusive test: asset is unable to call `decimals()`");
        assertGe(vaultDecimals, assetDecimals, "The `vault.decimals()` is lesser than `asset.decimals()`.");
    }


}