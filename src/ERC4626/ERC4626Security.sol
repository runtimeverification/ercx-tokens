// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC4626Abstract.sol";

/// @notice Abstract contract that consists of the security properties, including desirable properties for the sane functioning of the token and properties
/// of add-on functions commonly created and used by ERC4626 developers.
abstract contract ERC4626Security is ERC4626Abstract {

    /****************************
    *
    * Dealing tokens to dummy users checks
    *
    *****************************/

    /// @notice It is possible to deal the intended amount of assets to dummy users for interacting with the contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback There is an issue when dealing the intended amount of assets to dummy users for interacting with the contract.
    /// This could be due to issues with 
    /// (a) calling of the `transfer` function from the asset token by the top asset holder, or 
    /// (b) the presence of fees from the asset's `transfer` function.
    /// @custom:ercx-categories assets
    function testDealIntendedAssetsToDummyUsers(uint256 aliceAssetsBalance, uint256 bobAssetsBalance) public virtual {
        vm.assume(aliceAssetsBalance <= MAX_UINT256 - bobAssetsBalance);
        vm.assume(asset.totalSupply() <= MAX_UINT256 - aliceAssetsBalance - bobAssetsBalance);
        // Give aliceAssetsBalance tokens to Alice
        (bool dealAlice, string memory reasonAlice) = _dealERC20Token(assetAddress, alice, aliceAssetsBalance);
        assertTrue(dealAlice, reasonAlice);
        // Give bobAssetsBalance tokens to Bob
        (bool dealBob, string memory reasonBob) = _dealERC20Token(assetAddress, bob, bobAssetsBalance);
        assertTrue(dealBob, reasonBob);
        // Check that the asset balances of Alice and Bob are correct
        assertEq(asset.balanceOf(alice), aliceAssetsBalance, "Failure to deal the intended number of assets to Alice.");
        assertEq(asset.balanceOf(bob), bobAssetsBalance, "Failure to deal the intended number of assets to Bob.");
    }

    /// @notice Is is possible to deal the intended amount of shares to dummy users for interacting with the contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback There is an issue when dealing the intended amount of shares to dummy users for interacting with the contract.
    /// This could be due to issues with 
    /// (a) calling of the `transfer` function from the asset token by the top asset holder, or 
    /// (b) calling of the `mint` function from the vault token, or 
    /// (c) the presence of fees in the asset's `transfer` function or the vault's `mint` function.
    /// @custom:ercx-categories shares
    function testDealIntendedSharesToDummyUsers(uint256 aliceSharesBalance, uint256 bobSharesBalance) public virtual {
        vm.assume(aliceSharesBalance <= MAX_UINT256 - bobSharesBalance);
        vm.assume(cut4626.totalSupply() <= MAX_UINT256 - aliceSharesBalance - bobSharesBalance);
        // Exchange some of Alice's assets for shares 
        if (aliceSharesBalance != 0) {
            // shares overflow restriction on aliceSharesBalance
            if (cut4626.totalSupply() > 0) { 
                vm.assume(aliceSharesBalance < MAX_UINT256 / (cut4626.totalAssets() + 1)); 
            }
            // Make sure Alice has enough assets to burn
            uint256 aliceAssets = cut4626.previewMint(aliceSharesBalance);
            // Give Alice enough assets to exchange for shares
            (bool dealAssetsAlice, ) = _dealERC20Token(assetAddress, alice, aliceAssets);
            assertTrue(dealAssetsAlice, "Failure to deal assets to Alice before minting shares.");
            // Alice self-mints shares
            if (dealAssetsAlice) {
                (bool dealSharesAlice, ) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, aliceSharesBalance, alice); 
                assertTrue(dealSharesAlice, "Failure to mint shares even though Alice has enough assets.");
            }
        }
        // Exchange some of Bob's assets for shares 
        if (bobSharesBalance != 0) {
            // shares overflow restriction on bobSharesBalance
            if (cut4626.totalSupply() > 0) { 
                vm.assume(bobSharesBalance < MAX_UINT256 / (cut4626.totalAssets() + 1)); 
            }
            // Make sure Bob has enough assets to burn
            uint256 bobAssets = cut4626.previewMint(bobSharesBalance);
            // Give Bob enough assets to exchange for shares
            (bool dealAssetsBob, ) = _dealERC20Token(assetAddress, bob, bobAssets);
            assertTrue(dealAssetsBob, "Failure to deal assets to Bob before minting shares.");
            // Bob self-mints shares
            if (dealAssetsBob) {
                (bool dealSharesBob, ) = tryCallerMintSharesToReceiverWithChecksAndApproval(bob, bobSharesBalance, bob); 
                assertTrue(dealSharesBob, "Failure to mint shares even though Bob has enough assets.");
            }
        }
        // Check that the share balances of Alice and Bob are correct
        assertEq(cut4626.balanceOf(alice), aliceSharesBalance, "Failure to deal shares to Alice.");
        assertEq(cut4626.balanceOf(bob), bobSharesBalance, "Failure to deal shares to Bob.");        
    }


    /*******************************************/
    /*******************************************/
    /* Tests related to desirable properties. */
    /*******************************************/
    /*******************************************/

    /****************************
    *
    * convertTo{Assets,Shares} round trip checks.
    *
    *****************************/

    /// @notice `convertToAssets(convertToShares(assets)) <= assets` (up to `delta`-approximation)
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `convertToAssets(convertToShares(assets)) > assets` (up to `delta`-approximation)
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets, convertToShares
    function testConvertToAssetsSharesDesirable(uint256 assets)
    assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(assets > 0);
        uint256 shares = cut4626.convertToShares(assets);
        assertApproxLeAbs(cut4626.convertToAssets(shares), assets, delta, "`convertToAssets(convertToShares(assets)) > assets` (up to `delta`-approximation)");
    }

    /// @notice `convertToShares(convertToAssets(shares)) <= shares` (up to `delta`-approximation)
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `convertToShares(convertToAssets(shares)) > shares` (up to `delta`-approximation)
    /// @custom:ercx-categories assets, shares
    /// @custom:ercx-concerned-function convertToAssets, convertToShares
    function testConvertToSharesAssetsDesirable(uint256 shares)
    sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        uint256 assets = cut4626.convertToAssets(shares);
        assertApproxLeAbs(cut4626.convertToShares(assets), shares, delta, "`convertToShares(convertToAssets(shares)) > shares` (up to `delta`-approximation)");
    }


    /****************************
    *
    * Zero amount checks.
    *
    *****************************/

    /// @notice Calling `convertToShares` of zero amount returns zero, i.e., `convertToShares(0) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToShares` of zero amount returns a value greater than zero, i.e., `convertToShares(0) > 0`.
    /// @custom:ercx-categories assets, shares, zero amount
    /// @custom:ercx-concerned-function convertToShares
    function testConvertToSharesZeroAmountReturnsZero()
    public virtual {
        assertEq(cut4626.convertToShares(0), 0, "`convertToShares(0) > 0`");
    }

    /// @notice Calling `convertToAssets` of zero amount returns zero, i.e., `convertToAssets(0) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `convertToAssets` of zero amount returns a value greater than zero, i.e., `convertToAssets(0) > 0`.
    /// @custom:ercx-categories assets, shares, zero amount
    /// @custom:ercx-concerned-function convertToAssets
    function testConvertToAssetsZeroAmountReturnsZero()
    public virtual {
        assertEq(cut4626.convertToAssets(0), 0, "`convertToAssets(0) > 0`");
    }

    /// @notice Calling `previewDeposit` of zero amount returns zero, i.e., `previewDeposit(0) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewDeposit` of zero amount returns a value greater than zero, i.e., `previewDeposit(0) > 0`.
    /// @custom:ercx-categories deposit, zero amount
    /// @custom:ercx-concerned-function previewDeposit
    function testPreviewDepositZeroAmountReturnsZero()
    public virtual {
        assertEq(cut4626.previewDeposit(0), 0, "`previewDeposit(0) > 0`");
    }

    /// @notice Calling `previewMint` of positive amount returns a value greater than zero, i.e., `previewMint(shares) > 0` where `shares > 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewMint` of positive amount returns zero, i.e., `previewMint(shares) == 0` where `shares > 0`.
    /// @custom:ercx-categories mint, zero amount
    /// @custom:ercx-concerned-function previewMint
    function testPreviewMintPositiveAmountReturnsGtZero(uint256 shares)
    sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        assertGt(cut4626.previewMint(shares), 0, "`previewMint(shares) == 0` for some `shares > 0`");
    }

    /// @notice Calling `previewRedeem` of zero amount returns zero, i.e., `previewRedeem(0) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewRedeem` of zero amount returns a value greater than zero, i.e., `previewRedeem(0) > 0`.
    /// @custom:ercx-categories redeem, zero amount
    /// @custom:ercx-concerned-function previewRedeem
    function testPreviewRedeemZeroAmountReturnsZero()
    public virtual {
        assertEq(cut4626.previewRedeem(0), 0, "`previewRedeem(0) > 0`");
    }

    /// @notice Calling `previewWithdraw` of positive amount returns a value greater than zero, i.e., `previewWithdraw(assets) > 0` where `assets > 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `previewWithdraw` of positive amount returns zero, i.e., `previewWithdraw(assets) == 0` where `assets > 0`.
    /// @custom:ercx-categories mint, zero amount
    /// @custom:ercx-concerned-function previewWithdraw
    function testPreviewWithdrawPositiveAmountReturnsGtZero(uint256 assets)
    assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(assets > 0);
        assertGt(cut4626.previewWithdraw(assets), 0, "previewWithdraw(assets) == 0` for some `assets > 0`");
    }

    /// @notice Calling `deposit` of zero amount to self returns zero, i.e., `deposit(0, msg.sender) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `deposit` of zero amount to self returns a value greater than zero, i.e., `deposit(0, msg.sender) > 0`.
    /// @custom:ercx-categories deposit, zero amount
    /// @custom:ercx-concerned-function deposit
    function testDepositZeroAmountReturnsZero()
    public virtual {
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, 0, alice);
        if (callDeposit) {
            assertEq(mintedShares, 0, "`deposit(0, msg.sender) > 0`");
        }
        else {
            emit log("The `deposit` function cannot be called on zero amount.");
        }
    }

    /// @notice Calling `mint` of positive amount to self returns a value greater than zero, i.e., `mint(shares, msg.sender) > 0` where `shares > 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `mint` of positive amount to self returns zero, i.e., `mint(shares, msg.sender) == 0` where `shares > 0`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: mint.    
    /// @custom:ercx-categories mint, zero amount
    /// @custom:ercx-concerned-function mint
    function testMintPositiveAmountReturnsGtZero(uint256 aliceAssets, uint256 shares)
    initializeAssetsTwoUsers(aliceAssets, 0)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, alice);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint positive amount of shares for herself.");
        assertGt(depositedAssets, 0, "`mint(shares, msg.sender) == 0` for some `shares > 0`");
    }

    /// @notice Calling `redeem` of zero amount from self to self returns zero, i.e., `redeem(0, msg.sender, msg.sender) == 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `redeem` of zero amount from self to self returns a value greater than zero, i.e., `redeem(0, msg.sender, msg.sender) > 0`.
    /// @custom:ercx-categories redeem, zero amount
    /// @custom:ercx-concerned-function redeem
    function testRedeemZeroAmountReturnsZero()
    public virtual {
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, 0, alice);
        if (callRedeem) {
            assertEq(redeemedAssets, 0, "`redeem(0, msg.sender, msg.sender) > 0`");
        }
        else {
            emit log("The `redeem` function cannot be called on zero amount.");
        }
    }

    /// @notice Calling `withdraw` of positive amount from self to self returns a value greater than zero, i.e., `withdraw(assets, msg.sender, msg.sender) > 0` where `assets > 0`.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling `withdraw` of positive amount from self to self returns zero, i.e., `withdraw(assets, msg.sender, msg.sender) == 0` where `assets > 0`.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: withdraw.    
    /// @custom:ercx-categories withdraw, zero amount
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawPositiveAmountReturnsGtZero(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(assets > 0);
        (bool callWithdraw, uint256 burnedShares) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, alice);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Alice cannot withdraw positive amount of assets to herself.");
        assertGt(burnedShares, 0, "`withdraw(assets, msg.sender, msg.sender) == 0` for some `assets > 0`");
    }


    /****************************
    *
    * Independence of caller checks.
    *
    *****************************/

    /// @notice The return value of a `previewDeposit` call is independent of the caller's address and assets' balance. 
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The return value of a `previewDeposit` call depends on the caller's address and assets' balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories deposit
    /// @custom:ercx-concerned-function previewDeposit
    function testPreviewDepositIndependentOfCaller(uint256 assets, uint256 aliceAssets, uint256 bobAssets) 
    initializeAssetsTwoUsers(aliceAssets, bobAssets) assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(asset.balanceOf(alice) != asset.balanceOf(bob));
        (bool callAlice, uint256 aliceReturnValue) = tryCallerCallPreviewDepositAssets(alice, assets);
        (bool callBob, uint256 bobReturnValue) = tryCallerCallPreviewDepositAssets(bob, assets);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `previewDeposit`");
        assertEq(aliceReturnValue, bobReturnValue, "`previewDeposit(assets)` called by Alice != `previewDeposit(assets)` called by Bob");
    }

    /// @notice The return value of a `previewMint` call is independent of the caller's address and assets' balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The return value of a `previewMint` call depends on the caller's address and assets' balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function previewMint
    function testPreviewMintIndependentOfCaller(uint256 shares, uint256 aliceAssets, uint256 bobAssets) 
    initializeAssetsTwoUsers(aliceAssets, bobAssets) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) != asset.balanceOf(bob));
        (bool callAlice, uint256 aliceReturnValue) = tryCallerCallPreviewMintShares(alice, shares);
        (bool callBob, uint256 bobReturnValue) = tryCallerCallPreviewMintShares(bob, shares);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `previewMint`");
        assertEq(aliceReturnValue, bobReturnValue, "`previewMint(shares)` called by Alice != `previewMint(shares)` called by Bob");
    }

    /// @notice The return value of a `previewRedeem` call is independent of the caller's address and shares' balance. 
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The return value of a `previewRedeem` call depends on the caller's address and shares' balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories redeem
    /// @custom:ercx-concerned-function previewRedeem
    function testPreviewRedeemIndependentOfCaller(uint256 shares, uint256 aliceShares, uint256 bobShares) 
    initializeSharesTwoUsers(aliceShares, bobShares) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(aliceShares != bobShares);
        (bool callAlice, uint256 aliceReturnValue) = tryCallerCallPreviewRedeemShares(alice, shares);
        (bool callBob, uint256 bobReturnValue) = tryCallerCallPreviewRedeemShares(bob,shares);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `previewRedeem`");        
        assertEq(aliceReturnValue, bobReturnValue, "`previewRedeem(shares)` called by Alice != `previewRedeem(shares)` called by Bob");
    }

    /// @notice The return value of a `previewWithdraw` call is independent of the caller's address and shares' balance. 
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The return value of a `previewWithdraw` call depends on the caller's address and shares' balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories withdraw
    /// @custom:ercx-concerned-function previewWithdraw
    function testPreviewWithdrawIndependentOfCaller(uint256 assets, uint256 aliceShares, uint256 bobShares) 
    initializeSharesTwoUsers(aliceShares, bobShares) assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(aliceShares != bobShares);
        (bool callAlice, uint256 aliceReturnValue) = tryCallerCallPreviewWithdrawAssets(alice, assets);
        (bool callBob, uint256 bobReturnValue) = tryCallerCallPreviewWithdrawAssets(bob, assets);
        conditionalSkip(!callAlice || !callBob, "Inconclusive test: Unable to call `previewWithdraw`");
        assertEq(aliceReturnValue, bobReturnValue, "`previewWithdraw(assets)` called by Alice != `previewWithdraw(assets)` called by Bob");
    }


    /****************************
    *
    * Calling of deposit() checks.
    *
    *****************************/

    /// @notice The shares' balance of `receiver` increases by the amount of shares output by a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' balance of `receiver` does not increase by the amount of shares output by a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories shares, assets, deposit, balance
    /// @custom:ercx-concerned-function deposit
    function testDepositIncreaseReceiverSharesAsExpected(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        uint256 bobSharesBefore = cut4626.balanceOf(bob);
        // 1. Alice deposits assets to Bob
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        uint256 bobSharesAfter = cut4626.balanceOf(bob);
        // 2. Check that the right amount of shares is minted for Bob 
        assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
        assertApproxEqAbs(bobSharesAfter - bobSharesBefore, mintedShares, delta, "The shares' balance of Bob does not increase by the correct amount (up to `delta`-approximation) after a successful `deposit` call.");
    }

    /// @notice The total supply of shares increases by the amount of shares output by a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total supply of shares does not increase by the amount of shares output by a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories shares, assets, deposit, total shares
    /// @custom:ercx-concerned-function deposit
    function testDepositIncreaseTotalSharesAsExpected(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        // 1. Alice deposits assets to Bob
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        // 2. Check that the right amount of shares is minted to the total supply of shares
        assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
        assertApproxEqAbs(totalSupplyAfter - totalSupplyBefore, mintedShares, delta, "The total supply of shares does not increase by the correct amount (up to `delta`-approximation) after a successful `deposit` call.");
    }

    /// @notice The assets' balance of the caller decreases by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' balance of the caller does not decrease by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories assets, deposit, balance
    /// @custom:ercx-concerned-function deposit
    function testDepositDecreaseCallerAssetsAsExpected(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        uint256 aliceAssetsBefore = asset.balanceOf(alice);
        // 1. Alice deposits assets to Bob
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        uint256 aliceAssetsAfter = asset.balanceOf(alice);
        // 2. Check that the right amount of assets is burned for Alice 
        assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
        assertApproxEqAbs(aliceAssetsBefore - aliceAssetsAfter, aliceAssetBalance, delta, "The assets' balance of Alice does not decrease by the correct amount (up to `delta`-approximation) after a successful `deposit` call.");
    }

    /// @notice The total assets increases by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total assets does not increase by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories assets, deposit, total assets
    /// @custom:ercx-concerned-function deposit
    function testDepositIncreaseTotalAssetsAsExpected(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        uint256 totalAssetsBefore = cut4626.totalAssets();
        // 1. Alice deposits assets to Bob
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        uint256 totalAssetsAfter = cut4626.totalAssets();
        // 2. Check that the right amount of assets is transferred to the total assets
        assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
        assertApproxEqAbs(totalAssetsAfter - totalAssetsBefore, aliceAssetBalance, delta, "The total assets of the vault does not increase by the correct amount (up to `delta`-approximation) after a successful `deposit` call.");    
    }

    /// @notice The assets' allowance of caller to vault decreases by the amount of `assets` deposited 
    /// (from some initial allowance is greater than or equal to assets) after a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' allowance of caller to vault does not decrease by the amount of `assets` deposited 
    /// (from some initial allowance is greater than or equal to assets) after a successful `deposit(assets, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories assets, deposit, allowance
    /// @custom:ercx-concerned-function deposit
    function testDepositDecreaseAllowanceCallerVaultAsExpected(uint256 aliceAssets, uint256 assets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(assets > 0);
        vm.assume(cut4626.previewDeposit(assets) > 0);
        // 1. Alice deposits assets to Bob
        (bool callDeposit, ) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, assets, bob);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to Bob.");
        uint256 aliceAllowanceToVaultAfter = asset.allowance(alice, address(cut4626));
        // 2. Check that Alice assets' allowance for the vault decreases by the right amount
        assertGt(aliceAssetBalance, aliceAllowanceToVaultAfter, "The assets' allowance of Alice to the vault does not decrease as expected.");
        assertApproxEqAbs(aliceAssetBalance - aliceAllowanceToVaultAfter, assets, delta, "The assets' allowance of Alice to the vault does not decrease by the correct amount (up to `delta`-approximation) after a successful `deposit` call.");
    }


    /****************************
    *
    * Calling of deposit()-* checks.
    *
    *****************************/

    /// @notice It is not possible to make a free profit through depositing followed by withdrawing, i.e., 
    /// `deposit(assets, caller) <= withdraw(assets, caller, caller)` (up to `delta`-approximation) where deposit is called before withdraw.
    /// In layman's terms, it means initial shares minted from depositing is less than or equal to shares burned from withdrawing for same amount of assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through depositing followed by withdrawing, i.e., 
    /// `deposit(assets, caller) > withdraw(assets, caller, caller)` (up to `delta`-approximation) where deposit is called before withdraw.
    /// In layman's terms, it means initial shares minted from depositing > shares burned from withdrawing for same amount of assets.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories assets, deposit, withdraw
    /// @custom:ercx-concerned-function deposit, withdraw
    function testDepositWithdrawDesirable(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        // 1. Alice self-deposits assets
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, alice);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to herself.");
        // To prevent assets overflow for withdraw
        uint256 totalSupply = cut4626.totalSupply();
        if (totalSupply > 0) { 
            vm.assume(aliceAssetBalance < MAX_UINT256 / totalSupply); 
        }
        // 1. Alice self-withdraws assets (if possible)
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwner(alice, aliceAssetBalance, alice, alice);
        if (callWithdraw) {
            // 2. Check that the mintedShares from deposit call is less than or equal to burnedShares from withdraw call
            assertApproxLeAbs(mintedShares, burnedShares, delta, "`deposit(assets, caller) > withdraw(assets, caller, caller)` (up to `delta`-approximation)");
        }
        else {
            emit log("The `withdraw` function cannot be called after the `deposit` function call, and thus, the test passes by default.");
        }
    }

    /// @notice It is not possible to make a free profit through depositing followed by redeeming, i.e., 
    /// `redeem(deposit(assets, caller), caller, caller) <= assets` (up to `delta`-approximation). In layman's terms, it means 
    /// assets redeemed is less than or equal to initial assets deposited.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through depositing followed by redeeming, i.e., 
    /// `redeem(deposit(assets, caller), caller, caller) > assets` (up to `delta`-approximation). In layman's terms, it means 
    /// assets redeemed > initial assets deposited.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, deposit.
    /// @custom:ercx-categories redeem, deposit, assets
    /// @custom:ercx-concerned-function deposit, redeem
    function testDepositRedeemDesirable(uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(aliceAssets)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(cut4626.previewDeposit(aliceAssetBalance) > 0);
        // 1. Alice self-deposits assets
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, aliceAssetBalance, alice);
        // Skip the test if the deposit call failed
        conditionalSkip(!callDeposit, "Inconclusive test: Alice cannot deposit positive amount of assets to herself.");
        // 2. Alice self-redeems the mintedShares from the deposit call
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, mintedShares, alice);
        if (callRedeem) {
            // 3. Check that redeemedAssets from the redeem call is less than or equal to assets for the deposit call
            assertApproxLeAbs(redeemedAssets, aliceAssetBalance, delta, "`redeem(deposit(assets, caller), caller, caller) > assets` (up to `delta`-approximation)");
        }
        else {
            emit log("The `redeem` function cannot be called after the `deposit` function call, and thus, the test passes by default.");
        }
    }


    /****************************
    *
    * Calling of withdraw() checks.
    *
    *****************************/

    /// @notice The shares' balance of `owner` decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' balance of `owner` does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, withdraw.
    /// @custom:ercx-categories shares, assets, withdraw, balance
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawDecreaseOwnerSharesAsExpected(uint256 assets, uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        uint256 bobSharesBefore = cut4626.balanceOf(bob);
        // 1. Alice withdraws assets from Bob to herself with approval of allowance
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(alice, assets, alice, bob);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Bob cannot withdraw assets from Alice to himself even though he has enough allowance.");
        uint256 bobSharesAfter = cut4626.balanceOf(bob);
        // 2. Check that the right amount of shares is burned from Bob 
        assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of Bob does not decrease as expected.");
        assertApproxEqAbs(bobSharesBefore - bobSharesAfter, burnedShares, delta, "The shares' balance of Bob does not decrease by the correct amount (up to `delta`-approximation) after a successful `withdraw` call.");
    }

    /// @notice The total supply of shares decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total supply of shares does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, withdraw.
    /// @custom:ercx-categories shares, assets, withdraw, total shares
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawDecreaseTotalSharesAsExpected(uint256 assets, uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        // 1. Alice withdraws assets from Bob to herself with approval of allowance
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(alice, assets, alice, bob);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Bob cannot withdraw assets from Alice to himself even though he has enough allowance.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        // 2. Check that the right amount of shares is burned from the total supply of shares 
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, burnedShares, delta, "The total supply of shares does not decrease by the correct amount (up to `delta`-approximation) after a successful `withdraw` call.");
    }

    /// @notice The assets' balance of the `receiver` increases by the amount of `assets` withdrawn after a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' balance of the `receiver` does not increase by the amount of `assets` withdrawn after a successful `withdraw(assets, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, withdraw.
    /// @custom:ercx-categories assets, withdraw, balance
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawIncreaseReceiverAssetsAsExpected(uint256 assets, uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        uint256 aliceAssetsBefore = asset.balanceOf(alice);
        // 1. Alice withdraws assets from Bob to herself with approval of allowance
        (bool callWithdraw, ) = tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(alice, assets, alice, bob);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Bob cannot withdraw assets from Alice to himself even though he has enough allowance.");
        uint256 aliceAssetsAfter = asset.balanceOf(alice);
        // 2. Check that the right amount of assets is minted for Alice 
        assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
        assertApproxEqAbs(aliceAssetsAfter - aliceAssetsBefore, assets, delta, "The assets' balance of Alice does not increase by the correct amount (up to `delta`-approximation) after a successful `withdraw` call.");
    }

    /// @notice The shares' allowance of owner to caller decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call if caller != owner (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' allowance of owner to caller does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call if caller != owner (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, withdraw.
    /// @custom:ercx-categories shares, assets, withdraw, allowance
    /// @custom:ercx-concerned-function withdraw
    function testWithdrawDecreaseAllowanceOwnerCallerAsExpected(uint256 assets, uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // 1. Alice withdraws assets from Bob to herself with approval of allowance
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwnerWithChecksAndApproval(alice, assets, alice, bob);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Bob cannot withdraw assets from Alice to himself even though he has enough allowance.");
        uint256 bobAllowanceToAliceAfter = cut4626.allowance(bob, alice);
        // 2. Check that Bob allowance for Alice has decreased by the right amount
        assertGt(bobShares, bobAllowanceToAliceAfter, "The shares' allowance of Bob to Alice does not decrease as expected.");
        assertApproxEqAbs(bobShares - bobAllowanceToAliceAfter, burnedShares, delta, "The shares' allowance of Bob to Alice does not decrease by the correct amount (up to `delta`-approximation) after a successful `withdraw` call.");
    }


    /****************************
    *
    * Calling of withdraw()-* checks.
    *
    *****************************/

    /// @notice It is not possible to make a free profit through withdrawing followed by depositing, i.e., 
    /// `withdraw(assets, caller, caller) >= deposit(assets, caller)` (up to `delta`-approximation) where withdraw is called before deposit.
    /// In layman's terms, it means initial shares burned from withdrawing is greater than or equal to shares minted from depositing for same amount 
    /// of assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through withdrawing followed by depositing, i.e., 
    /// `withdraw(assets, caller, caller) < deposit(assets, caller)` (up to `delta`-approximation) where withdraw is called before deposit.
    /// In layman's terms, it means initial shares burned from withdrawing is lesser than shares minted from depositing for same amount 
    /// of assets.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: withdraw, approve.
    /// @custom:ercx-categories assets, withdraw.
    /// @custom:ercx-concerned-function withdraw, deposit
    function testWithdrawDepositDesirable(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets)
    public virtual {
        vm.assume(assets > 0);
        vm.assume(aliceShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // 1. Alice self-withdraws assets
        (bool callWithdraw, uint256 burnedShares) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, alice);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Alice cannot withdraw assets to herself.");
        // To prevent minting of 0 share in selfDeposit(assets)
        vm.assume(cut4626.previewDeposit(assets) > 0);
        // ----------------------------------------------------
        // 2. Alice self-deposits assets
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, assets, alice);
        if (callDeposit) {
            // 3. Check that the burnedShares from the withdraw call is greater than or equal to mintedShares from the deposit call
            assertApproxGeAbs(burnedShares, mintedShares, delta, "`withdraw(assets, caller, caller) < deposit(assets, caller)` (up to `delta`-approximation)");
        }
        else {
            emit log("The `deposit` function cannot be called after the `withdraw` function call, and thus, the test passes by default.");
        }
    }

    /// @notice It is not possible to make a free profit through withdrawing followed by minting, i.e., 
    /// `mint(withdraw(assets, caller, caller), caller) >= assets` (up to `delta`-approximation). In layman's terms, it means 
    /// shares minted is greater than or equal to initial shares burned from withdrawing.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through withdrawing followed by minting, i.e., 
    /// `mint(withdraw(assets, caller, caller), caller) < assets` (up to `delta`-approximation). In layman's terms, it means 
    /// shares minted is lesser than initial shares burned from withdrawing.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: withdraw.
    /// @custom:ercx-categories assets, withdraw, mint
    /// @custom:ercx-concerned-function mint, withdraw
    function testWithdrawMintDesirable(uint256 assets, uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) 
    public virtual {
        vm.assume(assets > 0);
        vm.assume(aliceShares > 0);
        vm.assume(cut4626.previewWithdraw(assets) > 0);
        // 1. Alice self-withdraws assets
        (bool callWithdraw, uint256 burnedShares) = tryOwnerWithdrawAssetsToReceiverWithChecks(alice, assets, alice);
        // Skip the test if the withdraw call failed
        conditionalSkip(!callWithdraw, "Inconclusive test: Alice cannot withdraw assets to herself.");
        // To prevent burnedShares overflow 
        if (cut4626.totalSupply() > 0) { 
            vm.assume(burnedShares < MAX_UINT256 / (cut4626.totalAssets() + 1)); 
        }
        // 2. Alice self-mints shares (if possible)
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), asset.balanceOf(alice));
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve vault assets.");
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiver(alice, burnedShares, alice);
        if (callMint) {
            // 3. Check that the deposited assets return from minting is greater than or equal to initial assets deposited 
            assertApproxGeAbs(depositedAssets, assets, delta, "`mint(withdraw(assets, caller, caller), caller) < assets` (up to `delta`-approximation)");
        }
        else {
            emit log("The `mint` function cannot be called after the `withdraw` function call, and thus, the test passes by default.");
        }
    }


    /****************************
    *
    * Calling of mint() checks.
    *
    *****************************/

    /// @notice The shares' balance of `receiver` increases by the amount of shares minted by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' balance of `receiver` does not increase by the amount of shares minted by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories shares, mint, balance
    /// @custom:ercx-concerned-function mint
    function testMintIncreaseReceiverSharesAsExpected(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        uint256 bobSharesBefore = cut4626.balanceOf(bob);
        // 1. Alice mints shares to bob
        (bool callMint, ) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for Bob.");
        uint256 bobSharesAfter = cut4626.balanceOf(bob);
        // 2. Check that the right amount of shares is minted for Bob
        assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
        assertApproxEqAbs(bobSharesAfter - bobSharesBefore, shares, delta, "The shares' balance of Bob does not increase by the correct amount (up to `delta`-approximation) after a successful `mint` call.");
    }

    /// @notice The total supply of shares increases by the amount of shares minted by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total supply of shares does not increase by the amount of shares minted by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories shares, mint, total shares
    /// @custom:ercx-concerned-function mint
    function testMintIncreaseTotalSharesAsExpected(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        // 1. Alice mints shares to bob
        (bool callMint, ) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for Bob.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        // 2. Check that the right amount of shares is minted to the total supply of shares
        assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
        assertApproxEqAbs(totalSupplyAfter - totalSupplyBefore, shares, delta, "The total supply of shares does not increase by the correct amount (up to `delta`-approximation) after a successful `mint` call.");
    }

    /// @notice The assets' balance of the caller decreases by the amount of assets output by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' balance of the caller does not decrease by the amount of assets output by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories assets, shares, mint, balance
    /// @custom:ercx-concerned-function mint
    function testMintDecreaseCallerAssetsAsExpected(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        uint256 aliceAssetsBefore = asset.balanceOf(alice);
        // 1. Alice mints shares to bob
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for Bob.");
        uint256 aliceAssetsAfter = asset.balanceOf(alice);
        // 2. Check that the right amount of assets is burned from Alice
        assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
        assertApproxEqAbs(aliceAssetsBefore - aliceAssetsAfter, depositedAssets, delta, "The assets' balance of Alice does not decrease by the correct amount (up to `delta`-approximation) after a successful `mint` call.");
    }

    /// @notice The total assets increases by the amount of assets output by a successful `mint(shares, output)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total assets does not increase by the amount of assets output by a successful `mint(shares, output)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories assets, shares, mint, total assets
    /// @custom:ercx-concerned-function mint
    function testMintIncreaseTotalAssetsAsExpected(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        uint256 totalAssetsBefore = cut4626.totalAssets();
        // 1. Alice mints shares to bob
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for Bob.");
        uint256 totalAssetsAfter = cut4626.totalAssets();
        // 2. Check that the right amount of assets is minted to the total assets
        assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
        assertApproxEqAbs(totalAssetsAfter - totalAssetsBefore, depositedAssets, delta, "The total assets of the vault does not increase by the correct amount (up to `delta`-approximation) after a successful `mint` call.");        
    }

    /// @notice The assets' allowance of caller to vault decreases by the amount of assets output by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' allowance of caller to vault does not decrease by the amount of assets output by a successful `mint(shares, receiver)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories assets, shares, mint, allowance
    /// @custom:ercx-concerned-function mint
    function testMintDecreaseAllowanceCallerVaultAsExpected(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        uint256 aliceAssetBalance = asset.balanceOf(alice);
        vm.assume(aliceAssetBalance > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        // 1. Alice mints shares to bob
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, bob);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for Bob.");
        uint256 aliceAllowanceToVault = asset.allowance(alice, address(cut4626));
        // 2. Check that Alice assets' allowance for the vault decreases by the right amount
        assertGt(aliceAssetBalance, aliceAllowanceToVault, "The assets' allowance of Alice to the vault does not decrease as expected.");
        assertApproxEqAbs(aliceAssetBalance - aliceAllowanceToVault, depositedAssets, delta, "The assets' allowance of Alice to the vault does not decrease by the correct amount (up to `delta`-approximation) after a successful `mint` call.");
    }


    /****************************
    *
    * Calling of mint()-* checks.
    *
    *****************************/

    /// @notice It is not possible to make a free profit through minting followed by withdrawing, i.e., 
    /// `withdraw(mint(shares, caller), caller, caller) >= shares` (up to `delta`-approximation). In layman's terms, it means 
    /// shares burned from withdrawing is greater than or equal to initial shares minted.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through minting followed by withdrawing, i.e., 
    /// `withdraw(mint(shares, caller), caller, caller) < shares` (up to `delta`-approximation). In layman's terms, it means 
    /// shares burned from withdrawing is lesser than initial shares minted.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: mint, approve.
    /// @custom:ercx-categories shares, mint, withdraw
    /// @custom:ercx-concerned-function mint, withdraw
    function testMintWithdrawDesirable(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        // 1. Alice self-mints shares
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, alice);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for herself.");
        // To prevent depositedAssets overflow for withdraw call
        uint256 totalSupply = cut4626.totalSupply();
        if (totalSupply > 0) { 
            vm.assume(depositedAssets < MAX_UINT256 / totalSupply); 
        }
        // 2. Alice self-withdraws assets (if possible)
        (bool callWithdraw, uint256 burnedShares) = tryCallerWithdrawAssetsToReceiverFromOwner(alice, depositedAssets, alice, alice);
        if (callWithdraw) {
            // 3. Check that the burnedShares from the withdraw call is greater than or equal to initial shares from the mint call
            assertApproxGeAbs(burnedShares, shares, delta, "`withdraw(mint(shares, caller), caller, caller) < shares` (up to `delta`-approximation)");
        }
        else {
            emit log("The `withdraw` function cannot be called after the `mint` function call, and thus, the test passes by default.");
        }
    }

    /// @notice It is not possible to make a free profit through minting followed by redeeming, i.e., 
    /// `mint(shares, caller) >= redeem(shares, caller, caller)` (up to `delta`-approximation) where mint is called before redeem. 
    /// In layman's terms, it means initial assets lost by caller from minting is greater than or equal to assets gained by caller from redeeming 
    /// for same amount of shares.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through minting followed by redeeming, i.e., 
    /// `mint(shares, caller) < redeem(shares, caller, caller)` (up to `delta`-approximation) where mint is called before redeem. 
    /// In layman's terms, it means initial assets lost by caller from minting is lesser than assets gained by caller from redeeming 
    /// for same amount of shares.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, mint.
    /// @custom:ercx-categories shares, mint, redeem
    /// @custom:ercx-concerned-function mint, redeem
    function testMintRedeemDesirable(uint256 shares, uint256 aliceAssets)
    initializeAssetsTwoUsers(aliceAssets, 0) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(asset.balanceOf(alice) > 0);
        vm.assume(shares > 0);
        vm.assume(cut4626.previewMint(shares) > 0);
        // 1. Alice self-mints shares
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiverWithChecksAndApproval(alice, shares, alice);
        // Skip the test if the mint call failed
        conditionalSkip(!callMint, "Inconclusive test: Alice cannot mint shares for herself.");
        // 2. Alice self-redeems shares
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, shares, alice);
        if (callRedeem) {
            // 3. Check that the depositedAssets return from the mint call is greater than or equal to the redeemedAssets from the redeem call
            assertApproxGeAbs(depositedAssets, redeemedAssets, delta, "`mint(shares, caller) < redeem(shares, caller, caller)` (up to `delta`-approximation)");
        }
        else {
            emit log("The `redeem` function cannot be called after the `mint` function call, and thus, the test passes by default.");
        }
    }


    /****************************
    *
    * Calling of redeem() checks.
    *
    *****************************/

    /// @notice The shares' balance of the `owner` decreases by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' balance of the `owner` does not decrease by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, redeem.
    /// @custom:ercx-categories shares, redeem, balance
    /// @custom:ercx-concerned-function redeem
    function testRedeemDecreaseOwnerSharesAsExpected(uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewRedeem(bobShares) > 0);
        uint256 bobSharesBefore = cut4626.balanceOf(bob);
        // 1. Alice redeems shares from Bob with allowance approval
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(alice, bobShares, alice, bob);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        uint256 bobSharesAfter = cut4626.balanceOf(bob);
        // 2. Check that the right amount of shares is burned from Bob
        assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of the Bob does not decrease as expected.");
        assertApproxEqAbs(bobSharesBefore - bobSharesAfter, bobShares, delta, "The shares' balance of Bob does not decrease by the correct amount (up to `delta`-approximation) after a successful `redeem` call.");
    }

    /// @notice The total supply of shares decreases by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The total supply of shares does not decrease by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, redeem.    
    /// @custom:ercx-categories shares, redeem, total shares
    /// @custom:ercx-concerned-function redeem
    function testRedeemDecreaseTotalSharesAsExpected(uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewRedeem(bobShares) > 0);
        uint256 totalSupplyBefore = cut4626.totalSupply();
        // 1. Alice redeems shares from Bob with allowance approval
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(alice, bobShares, alice, bob);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        uint256 totalSupplyAfter = cut4626.totalSupply();
        // 2. Check that the right amount of shares is burned from the total supply of shares
        assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
        assertApproxEqAbs(totalSupplyBefore - totalSupplyAfter, bobShares, delta, "The total supply of shares does not decrease by the correct amount (up to `delta`-approximation) after a successful `redeem` call.");
    }

    /// @notice The assets' balance of the `receiver` increases by the amount of assets output by a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The assets' balance of the `receiver` does not increase by the amount of assets output by a successful `redeem(shares, receiver, owner)` call (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, redeem.
    /// @custom:ercx-categories shares, assets, redeem, balance
    /// @custom:ercx-concerned-function redeem
    function testRedeemIncreaseReceiverAssetsAsExpected(uint256 bobShares)
    initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(bobShares)
    public virtual {
        vm.assume(bobShares > 0);
        vm.assume(cut4626.previewRedeem(bobShares) > 0);
        uint256 aliceAssetsBefore = asset.balanceOf(alice);
        // 1. Alice redeems shares from Bob with allowance approval
        (bool callRedeem, uint256 redeemedAssets) = tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(alice, bobShares, alice, bob);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        uint256 aliceAssetsAfter = asset.balanceOf(alice);
        // 2. Check that the right amount of assets is minted for Alice
        assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
        assertApproxEqAbs(aliceAssetsAfter - aliceAssetsBefore, redeemedAssets, delta, "The assets' balance of Alice does not increase by the correct amount (up to `delta`-approximation) after a successful `redeem` call.");
    }

    /// @notice The shares' allowance of owner to caller decreases  by the amount of `shares` redeemed 
    /// (from some initial allowance is greater than or equal to shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner (up to `delta`-approximation).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The shares' allowance of owner to caller does not decrease by the amount of `shares` redeemed 
    /// (from some initial allowance is greater than or equal to shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner (up to `delta`-approximation).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: approve, redeem.
    /// @custom:ercx-categories shares, redeem, allowance
    /// @custom:ercx-concerned-function redeem
    function testRedeemDecreaseAllowanceOwnerCallerAsExpected(uint256 bobShares, uint256 shares)
    initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares)
    public virtual {
        vm.assume(shares > 0);
        vm.assume(shares <= bobShares);
        vm.assume(cut4626.previewRedeem(shares) > 0);
        // 1. Alice redeems shares from Bob with allowance approval
        (bool callRedeem, ) = tryCallerRedeemSharesToReceiverFromOwnerWithChecksAndApproval(alice, shares, alice, bob);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        uint256 bobAllowanceToAlice = cut4626.allowance(bob, alice);
        // 2. Check that Bob allowance for Alice has decreased by the right amount
        assertGt(bobShares, bobAllowanceToAlice, "The shares' allowance of Bob to Alice does not decrease as expected.");
        assertApproxEqAbs(bobShares - bobAllowanceToAlice, shares, delta, "The allowance from Bob to Alice does not decrease by the correct amount (up to `delta`-approximation) after a successful `redeem` call.");
    }


    /****************************
    *
    * Calling of redeem()-* checks.
    *
    *****************************/

    /// @notice It is not possible to make a free profit through redeeming followed by depositing, i.e., 
    /// `deposit(redeem(shares, caller, caller), caller) <= shares` (up to `delta`-approximation). In layman's terms, it means 
    /// initial shares redeemed is less than or equal to shares minted from depositing.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through redeeming followed by depositing, i.e., 
    /// `deposit(redeem(shares, caller, caller), caller) > shares` (up to `delta`-approximation). In layman's terms, it means 
    /// initial shares redeemed > shares minted from depositing.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: redeem, approve.
    /// @custom:ercx-categories redeem, deposit, shares
    /// @custom:ercx-concerned-function deposit, redeem
    function testRedeemDepositDesirable(uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(cut4626.previewRedeem(aliceShares) > 0);
        // 1. Alice self-redeems shares
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, aliceShares, alice);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        vm.assume(cut4626.previewDeposit(redeemedAssets) > 0); // To prevent minting of zero shares
        // 2. Alice self-deposits redeemedAssets
        (bool callDeposit, uint256 mintedShares) = tryCallerDepositAssetsToReceiverWithChecksAndApproval(alice, redeemedAssets, alice);
        if (callDeposit) {
            assertApproxLeAbs(mintedShares, aliceShares, delta, "`deposit(redeem(shares, caller, caller), caller) > shares` (up to `delta`-approximation)");
        }
        else {
            emit log("The `deposit` function cannot be called after the `redeem` function call, and thus, the test passes by default.");
        }
    }

    /// @notice It is not possible to make a free profit through redeeming followed by minting, i.e., 
    /// `redeem(shares, caller, caller) <= mint(shares, caller)` (up to `delta`-approximation) where redeem is called before mint.
    /// In layman's terms, it means initial assets gained by caller from redeem is less than or equal to assets lost by caller 
    /// from minting for same amount of shares.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It is possible to make a free profit through redeeming followed by minting, i.e., 
    /// `redeem(shares, caller, caller) > mint(shares, caller)` (up to `delta`-approximation) where redeem is called before mint.
    /// In layman's terms, it means initial assets gained by caller from redeem > assets lost by caller 
    /// from minting for same amount of shares.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract 
    /// OR calling the following functions: redeem.
    /// @custom:ercx-categories shares, mint, redeem
    /// @custom:ercx-concerned-function mint, redeem
    function testRedeemMintDesirable(uint256 aliceShares)
    initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(aliceShares)
    public virtual {
        vm.assume(aliceShares > 0);
        vm.assume(cut4626.previewRedeem(aliceShares) > 0);
        // 1. Alice self-redeems shares
        (bool callRedeem, uint256 redeemedAssets) = tryOwnerRedeemSharesToReceiverWithChecks(alice, aliceShares, alice);
        // Skip the test if the redeem call failed
        conditionalSkip(!callRedeem, "Inconclusive test: Alice cannot redeem shares for herself.");
        // To prevent shares overflow for mint
        if (cut4626.totalSupply() > 0) { 
            vm.assume(aliceShares < MAX_UINT256 / (cut4626.totalAssets() + 1)); 
        }
        vm.assume(cut4626.previewDeposit(redeemedAssets) > 0); // To prevent minting of zero shares
        // 2. Alice self-mints shares
        (bool callApprove, ) = tryCallerApproveApproveeAssets(alice, address(cut4626), asset.balanceOf(alice));
        // Skip the test if the approve call failed
        conditionalSkip(!callApprove, "Inconclusive test: Alice cannot approve vault assets.");
        (bool callMint, uint256 depositedAssets) = tryCallerMintSharesToReceiver(alice, aliceShares, alice);
        if (callMint) {
            // 3. Check that the redeemedAssets from the redeem call is less than or equal to the depositedAssets from the mint call
            assertApproxLeAbs(redeemedAssets, depositedAssets, delta, "`redeem(shares, caller, caller) > mint(shares, caller)` (up to `delta`-approximation)");
        }
        else {
            emit log("The `mint` function cannot be called after the `redeem` function call, and thus, the test passes by default.");
        }
    }

}