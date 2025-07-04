// // SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.6.2 <0.9.0;

// import "../ERC4626Abstract.sol";

// /// @notice Abstract contract that consists of testing functions with test for properties
// /// that are neither desirable nor undesirable but instead implementation choices.
// abstract contract ERC4626Features is ERC4626Abstract {

//     /****************************
//     *
//     * Calling of convertToAssets() checks
//     *
//     *****************************/

//     /// @notice The contract follows the integer overflow limit used by Solmate ERC4626 implementation for `convertToAssets`,
//     /// i.e., calling `convertToAssets(shares)` reverts due to integer overflow when `shares > type(uint256).max / vault.totalAssets()`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The contract does not follow the integer overflow limit used by Solmate ERC4626 implementation for `convertToAssets`,
//     /// i.e., there exists some `shares > type(uint256).max / vault.totalAssets()` where `convertToAssets(shares)` does not revert due to integer overflow.
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets
//     function testConvertToAssetsIntOverflowLimitFollowsSolmate() public {
//         uint256 totalSupply = cut4626.totalSupply();
//         uint256 totalAssets = cut4626.totalAssets();
//         if (totalSupply > 0) {
//             // restrict `shares` to force overflow
//             uint256 shares = MAX_UINT256 / totalAssets + 1;
//             bytes memory data = abi.encodeWithSelector(cut4626.convertToAssets.selector, shares);
//             (bool success, ) = address(cut4626).call(data);
//             assertFalse(success, "Calling `convertToAssets` may not revert when there is an integer overflow caused by an unreasonably large input.");
//         }
//     }

//     /// @notice `convertToAssets(convertToShares(assets)) == assets`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToAssets(convertToShares(assets)) != assets`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToAssetsSharesIdentity(uint256 assets)
//     assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         uint256 shares = cut4626.convertToShares(assets);
//         assertEq(cut4626.convertToAssets(shares), assets, "`convertToAssets(convertToShares(assets)) != assets`");
//     }

//     /// @notice `convertToAssets(convertToShares(assets)) < assets`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToAssets(convertToShares(assets)) >= assets`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToAssetsSharesLtInitialAssets(uint256 assets)
//     assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         uint256 shares = cut4626.convertToShares(assets);
//         assertLt(cut4626.convertToAssets(shares), assets, "`convertToAssets(convertToShares(assets)) >= assets`");
//     }

//     /// @notice `convertToAssets(convertToShares(assets)) > assets`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToAssets(convertToShares(assets)) <= assets`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToAssetsSharesGtInitialAssets(uint256 assets)
//     assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         uint256 shares = cut4626.convertToShares(assets);
//         assertGt(cut4626.convertToAssets(shares), assets, "`convertToAssets(convertToShares(assets)) <= assets`");
//     }

//     /****************************
//     *
//     * Calling of convertToShares() checks
//     *
//     *****************************/

//     /// @notice The contract follows the integer overflow limit used by Solmate ERC4626 implementation for `convertToShares`,
//     /// i.e., calling `convertToShares(assets)` reverts due to integer overflow when `assets > type(uint256).max / vault.totalSupply()`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The contract does not follow the integer overflow limit used by Solmate ERC4626 implementation for `convertToShares`,
//     /// i.e., there exists some `assets > type(uint256).max / vault.totalSupply()` where `convertToShares(assets)` does not revert due to integer overflow.
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToShares
//     function testConvertToSharesIntOverflowLimitFollowsSolmate() public {
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             // restrict `assets` to force overflow
//             uint256 assets = MAX_UINT256 / totalSupply + 1;
//             bytes memory data = abi.encodeWithSelector(cut4626.convertToShares.selector, assets);
//             (bool success, ) = address(cut4626).call(data);
//             assertFalse(success, "Calling `convertToShares` may not revert when there is an integer overflow caused by an unreasonably large input.");
//         }
//     }

//     /// @notice `convertToShares(convertToAssets(shares)) == shares`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToShares(convertToAssets(shares)) != shares`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToSharesAssetsIdentity(uint256 shares)
//     sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         uint256 assets = cut4626.convertToAssets(shares);
//         assertEq(cut4626.convertToShares(assets), shares, "`convertToShares(convertToAssets(shares)) != shares`");
//     }

//     /// @notice `convertToShares(convertToAssets(shares)) < shares`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToShares(convertToAssets(shares)) >= shares`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToSharesAssetsLtInitialShares(uint256 shares)
//     sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         uint256 assets = cut4626.convertToAssets(shares);
//         assertLt(cut4626.convertToShares(assets), shares, "`convertToShares(convertToAssets(shares)) >= shares`");
//     }

//     /// @notice `convertToShares(convertToAssets(shares)) > shares`
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `convertToShares(convertToAssets(shares)) <= shares`
//     /// @custom:ercx-categories assets, shares
//     /// @custom:ercx-concerned-function convertToAssets, convertToShares
//     function testConvertToSharesAssetsGtInitialShares(uint256 shares)
//     sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         uint256 assets = cut4626.convertToAssets(shares);
//         assertGt(cut4626.convertToShares(assets), shares, "`convertToShares(convertToAssets(shares)) <= shares`");
//     }

//     /****************************
//     *
//     * Calling of deposit() checks.
//     *
//     *****************************/

//     /// @notice Calling `deposit` reverts when the amount of assets to deposit is greater than `maxDeposit(tokenReceiver)`.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback Calling `deposit` does not revert on some amount of assets that is greater than `maxDeposit(tokenReceiver)`.
//     /// @custom:ercx-categories assets, deposit
//     /// @custom:ercx-concerned-function deposit
//     function testDepositRevertsWhenAssetsGtMaxDeposit(uint256 assets, uint256 aliceAssets, uint256 bobShares) public
//     initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) assetsOverflowRestriction(assets) {
//         uint256 maxDepositBob = cut4626.maxDeposit(bob);
//         if (maxDepositBob != MAX_UINT256) {
//             vm.assume(assets > maxDepositBob);
//             vm.assume(assets <= aliceAssets);
//             (bool callApprove, ) = tryCustomerAssetApprove(alice, address(cut4626), assets);
//             if (callApprove) {
//                 vm.startPrank(alice);
//                 (bool callDeposit, ) = tryDeposit(assets, bob);
//                 vm.stopPrank();
//                 assertFalse(callDeposit, "Alice can deposit an amount of assets that is greater than `maxDeposit(bob)` for Bob.");
//             }
//             else {
//                 emit log("Alice cannot approve assets for vault.");
//             }
//         }
//         else {
//             emit log("`maxDeposit(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default.");
//         }
//     }

//     /// @notice Calling `maxDeposit` returns the maximum amount of assets deposit would allow to be deposited for receiver.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback Calling `maxDeposit` does not return the maximum amount of assets deposit would allow to be deposited for receiver.
//     /// @custom:ercx-categories assets, deposit
//     /// @custom:ercx-concerned-function maxDeposit
//     function testMaxDepositReturnMaxAssetsDeposit(uint256 assets, uint256 aliceAssets, uint256 bobShares) public
//     initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) {
//         uint256 maxDepositBob = cut4626.maxDeposit(bob);
//         vm.assume(assets <= maxDepositBob);
//         vm.assume(assets <= aliceAssets);
//         (bool callApprove, ) = tryCustomerAssetApprove(alice, address(cut4626), maxDepositBob);
//         if (callApprove) {
//             vm.startPrank(alice);
//             (bool callDeposit, ) = tryDeposit(assets, bob);
//             vm.stopPrank();
//             assertTrue(callDeposit, "Alice cannot deposit a number of assets that is lesser than `maxDeposit(bob)` for Bob.");
//         }
//         else {
//             emit log("Alice cannot approve assets for the vault.");
//         }
//     }

//     /// @notice Calling `maxDeposit MUST return 2 ** 256 - 1
//     /// if there is no limit on the maximum amount of assets that may be deposited.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback Calling `maxDeposit` does not return 2 ** 256 - 1, i.e., there might be a limit set for `maxDeposit`.
//     /// @custom:ercx-categories deposit
//     /// @custom:ercx-concerned-function maxDeposit
//     function testMaxDepositReturnMaxUint256IfNoLimit() public {
//         assertEq(cut4626.maxDeposit(alice), MAX_UINT256, "Calling `maxDeposit` does not return 2 ** 256 - 1.");
//     }

//     /// @notice The shares' balance of `receiver` increases by the amount of shares output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' balance of `receiver` does not increase by the amount of shares output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories shares, assets, deposit, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseReceiverSharesEqExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 mintedShares = depositAToB(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertEq(bobSharesAfter - bobSharesBefore, mintedShares, "The shares' balance of Bob does not increase by the correct amount after a successful `deposit` call.");
//     }

//     /// @notice The shares' balance of `receiver` increases by a number of shares lesser than what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `receiver` increases by a number of shares greater than or equal to what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, shares, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseReceiverSharesLtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 mintedShares = depositAToB(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertLt(bobSharesAfter - bobSharesBefore, mintedShares, "The shares' balance of Bob increases by a number of shares greater than or equal to what was expected.");
//     }

//     /// @notice The shares' balance of `receiver` increases by a number of shares greater than what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `receiver` increases by a number of shares lesser than or equal to what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, shares, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseReceiverSharesGtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 mintedShares = depositAToB(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertGt(bobSharesAfter - bobSharesBefore, mintedShares, "The shares' balance of Bob increases by a number of shares lesser than or equal to what was expected.");
//     }

//     /// @notice The total supply of shares increases by the amount of shares output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total supply of shares does not increase by the amount of shares output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories shares, assets, deposit, total shares
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalSharesEqExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 mintedShares = depositAToB(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertEq(totalSupplyAfter - totalSupplyBefore, mintedShares, "The total supply of shares does not increase by the correct amount after a successful `deposit` call.");
//     }

//     /// @notice The total supply of shares increases by a number of shares lesser than what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares increases by a number of shares greater than or equal to what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, shares, total shares
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalSharesLtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 mintedShares = depositAToB(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertLt(totalSupplyAfter - totalSupplyBefore, mintedShares, "The total supply of shares increases by a number of shares greater than or equal to what was expected.");
//     }

//     /// @notice The total supply of shares increases by a number of shares greater than what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares increases by a number of shares lesser than or equal to what was output by a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, shares, total shares
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalSharesGtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 mintedShares = depositAToB(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertGt(totalSupplyAfter - totalSupplyBefore, mintedShares, "The total supply of shares increases by a number of shares lesser than or equal to what was expected.");
//     }

//     /// @notice The assets' balance of the caller decreases by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' balance of the caller does not decrease by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseCallerAssetsEqExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         depositAToB(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertEq(aliceAssetsBefore - aliceAssetsAfter, assets, "The assets' balance of Alice does not decrease by the correct amount after a successful `deposit` call.");
//     }

//     /// @notice The assets' balance of the caller decreases by a number of `assets` lesser than what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the caller decreases by a number of `assets` greater than or equal to what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseCallerAssetsLtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         depositAToB(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertLt(aliceAssetsBefore - aliceAssetsAfter, assets, "The assets' balance of Alice decreases by a number of shares greater than or equal to what was expected.");
//     }

//     /// @notice The assets' balance of the caller decreases by a number of `assets` greater than what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the caller decreases by a number of `assets` lesser than or equal to what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, balance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseCallerAssetsGtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         depositAToB(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertGt(aliceAssetsBefore - aliceAssetsAfter, assets, "The assets' balance of Alice increases by a number of shares lesser than or equal to what was expected.");
//     }

//     /// @notice The total assets increases by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total assets does not increase by the amount of `assets` deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, total assets
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalAssetsEqExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         depositAToB(assets);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertEq(totalAssetsAfter - totalAssetsBefore, assets, "The total assets of the vault does not increase by the correct amount after a successful `deposit` call.");
//     }

//     /// @notice The total assets increases by a number of `assets` lesser than what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total assets increases by a number of `assets` greater than or equal to what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, total assets
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalAssetsLtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         depositAToB(assets);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertLt(totalAssetsAfter - totalAssetsBefore, assets, "The total assets of the vault increases by a number of shares greater than or equal to what was expected.");
//     }

//     /// @notice The total assets increases by a number of `assets` greater than what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total assets increases by a number of `assets` lesser than or equal to what was deposited via a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, total assets
//     /// @custom:ercx-concerned-function deposit
//     function testDepositIncreaseTotalAssetsGtExpected(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         depositAToB(assets);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertGt(totalAssetsAfter - totalAssetsBefore, assets, "The total assets of the vault increases by a number of shares lesser than or equal to what was expected.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by the amount of `assets` deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' allowance of caller to vault does not decrease by the amount of `assets` deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, allowance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseAllowanceCallerVaultEqExpected(uint256 aliceAssets, uint256 assets)
//     initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         depositAToB(assets);
//         uint256 aliceAllowanceToVaultAfter = asset.allowance(alice, address(cut4626));
//         assertGt(aliceAssets, aliceAllowanceToVaultAfter, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertEq(aliceAssets - aliceAllowanceToVaultAfter, assets, "The assets' allowance of Alice to the vault does not decrease by the correct amount after a successful `deposit` call.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by a number of `assets` lesser than what was deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' allowance of caller to vault decreases by a number of `assets` greater than or equal to what was deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, allowance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseAllowanceCallerVaultLtExpected(uint256 aliceAssets, uint256 assets)
//     initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         depositAToB(assets);
//         uint256 aliceAllowanceToVaultAfter = asset.allowance(alice, address(cut4626));
//         assertGt(aliceAssets, aliceAllowanceToVaultAfter, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertLt(aliceAssets - aliceAllowanceToVaultAfter, assets, "The assets' allowance of Alice to the vault decreases by a number of shares greater than or equal to what was expected.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by a number of `assets` greater than what was deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' allowance of caller to vault decreases by a number of `assets` lesser than or equal to what was deposited
//     /// (from some initial allowance >= assets) after a successful `deposit(assets, receiver)` call.
//     /// @custom:ercx-categories assets, deposit, allowance
//     /// @custom:ercx-concerned-function deposit
//     function testDepositDecreaseAllowanceCallerVaultGtExpected(uint256 aliceAssets, uint256 assets)
//     initializeAssetsTwoUsers(aliceAssets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         depositAToB(assets);
//         uint256 aliceAllowanceToVaultAfter = asset.allowance(alice, address(cut4626));
//         assertGt(aliceAssets, aliceAllowanceToVaultAfter, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertGt(aliceAssets - aliceAllowanceToVaultAfter, assets, "The assets' allowance of Alice to the vault decreases by a number of shares lesser than or equal to what was expected.");
//     }

//     /****************************
//     *
//     * Calling of deposit()-* checks.
//     *
//     *****************************/

//     /// @notice `deposit(assets, caller) == withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing == shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(assets, caller) != withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing != shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-categories assets, deposit, shares, withdraw
//     /// @custom:ercx-concerned-function deposit, withdraw
//     function testDepositWithdrawEq(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         // case where Alice has not enough mintedShares to withdraw assets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(assets < MAX_UINT256 / totalSupply);
//         }
//         if (mintedShares < cut4626.previewWithdraw(assets)) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(assets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertEq(mintedShares, burnedShares, "`deposit(assets, caller) != withdraw(assets, caller, caller)`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(assets);
//             assertEq(mintedShares, burnedShares, "`deposit(assets, caller) != withdraw(assets, caller, caller)`");
//         }
//     }

//     /// @notice `deposit(assets, caller) < withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing < shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(assets, caller) >= withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing >= shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-categories assets, deposit, shares, withdraw
//     /// @custom:ercx-concerned-function deposit, withdraw
//     function testDepositWithdrawLt(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         // case where Alice has not enough mintedShares to withdraw assets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(assets < MAX_UINT256 / totalSupply);
//         }
//         if (mintedShares < cut4626.previewWithdraw(assets)) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(assets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertLt(mintedShares, burnedShares, "`deposit(assets, caller) >= withdraw(assets, caller, caller)`");
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(assets);
//             assertLt(mintedShares, burnedShares, "`deposit(assets, caller) >= withdraw(assets, caller, caller)`");
//         }
//     }

//     /// @notice `deposit(assets, caller) > withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing > shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(assets, caller) <= withdraw(assets, caller, caller)` where deposit is called before withdraw.
//     /// In layman terms, it means initial shares minted from depositing <= shares burnt from withdrawing for same amount of assets.
//     /// @custom:ercx-categories assets, deposit, shares, withdraw
//     /// @custom:ercx-concerned-function deposit, withdraw
//     function testDepositWithdrawGt(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         // case where Alice has not enough mintedShares to withdraw assets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(assets < MAX_UINT256 / totalSupply);
//         }
//         if (mintedShares < cut4626.previewWithdraw(assets)) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(assets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertGt(mintedShares, burnedShares, "`deposit(assets, caller) <= withdraw(assets, caller, caller)`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(assets);
//             assertGt(mintedShares, burnedShares, "`deposit(assets, caller) <= withdraw(assets, caller, caller)`");
//         }
//     }

//     /// @notice `redeem(deposit(assets, caller), caller, caller) == assets`. In layman terms, it means
//     /// assets redeemed == initial assets deposited.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(deposit(assets, caller), caller, caller) != assets`. In layman terms, it means
//     /// assets redeemed != initial assets deposited.
//     /// @custom:ercx-categories assets, deposit, redeem
//     /// @custom:ercx-concerned-function deposit, redeem
//     function testDepositRedeemIdentity(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         uint256 redeemedAssets = selfRedeem(mintedShares);
//         assertEq(redeemedAssets, assets, "`redeem(deposit(assets, caller), caller, caller) != assets`");
//     }

//     /// @notice `redeem(deposit(assets, caller), caller, caller) < assets`. In layman terms, it means
//     /// assets redeemed < initial assets deposited.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(deposit(assets, caller), caller, caller) >= assets`. In layman terms, it means
//     /// assets redeemed >= initial assets deposited.
//     /// @custom:ercx-categories assets, deposit, redeem
//     /// @custom:ercx-concerned-function deposit, redeem
//     function testDepositRedeemLtInitialAssets(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         uint256 redeemedAssets = selfRedeem(mintedShares);
//         assertLt(redeemedAssets, assets, "`redeem(deposit(assets, caller), caller, caller) >= assets`");
//     }

//     /// @notice `redeem(deposit(assets, caller), caller, caller) > assets`. In layman terms, it means
//     /// assets redeemed > initial assets deposited.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(deposit(assets, caller), caller, caller) <= assets`. In layman terms, it means
//     /// assets redeemed <= initial assets deposited.
//     /// @custom:ercx-categories assets, deposit, redeem
//     /// @custom:ercx-concerned-function deposit, redeem
//     function testDepositRedeemGtInitialAssets(uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         uint256 mintedShares = selfDeposit(assets);
//         uint256 redeemedAssets = selfRedeem(mintedShares);
//         assertGt(redeemedAssets, assets, "`redeem(deposit(assets, caller), caller, caller) <= assets`");
//     }

//     /****************************
//     *
//     * Calling of withdraw() checks.
//     *
//     *****************************/

//     /// @notice `maxWithdraw(account) == convertToAssets(vault.balanceOf(account))` (referenced from Solmate and OZ implementation)
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `maxWithdraw(account) != convertToAssets(vault.balanceOf(account))`
//     /// @custom:ercx-categories withdraw
//     /// @custom:ercx-concerned-function maxWithdraw
//     function testMaxWithdrawEqConvertToAssetsOfBalanceOfShares(uint256 aliceShares)
//     public initializeSharesTwoUsers(aliceShares, 0) {
//         uint256 balanceOfShares = cut4626.balanceOf(alice);
//         // prevent `balanceOfShares` from integer overflow
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(balanceOfShares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         assertEq(cut4626.maxWithdraw(alice), cut4626.convertToAssets(cut4626.balanceOf(alice)), "`maxWithdraw(account) != convertToAssets(vault.balanceOf(account))`");
//     }

//     /// @notice Calling `withdraw` reverts when the amount of assets to withdraw is greater than `maxWithdraw(tokenOwner)`.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback Calling `withdraw` does not revert on some amount of assets that is greater than `maxWithdraw(tokenOwner)`.
//     /// @custom:ercx-categories assets, withdraw
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawRevertsWhenAssetsGtMaxWithdraw(uint256 assets, uint256 aliceShares)
//     public initializeSharesTwoUsers(aliceShares, 0) assetsOverflowRestriction(assets) sharesOverflowRestriction(aliceShares) {
//         vm.assume(aliceShares > 0);
//         vm.assume(assets > 0);
//         uint256 maxWithdrawAlice = cut4626.maxWithdraw(alice);
//         vm.assume(assets > maxWithdrawAlice);
//         vm.startPrank(alice);
//         (bool callWithdraw, ) = tryWithdraw(assets, bob, alice);
//         assertFalse(callWithdraw, "Alice can withdraw an amount of assets that is greater than `maxWithdraw(alice)` for Bob.");
//         vm.stopPrank();
//     }

//     /// @notice The shares' balance of `owner` decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' balance of `owner` does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories shares, assets, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseOwnerSharesEqExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of Bob does not decrease as expected.");
//         assertEq(bobSharesBefore - bobSharesAfter, burnedShares, "The shares' balance of Bob does not decrease by the correct amount after a successful `withdraw` call.");
//     }

//     /// @notice The shares' balance of `owner` decreases by a number of shares lesser than what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `owner` decreases by a number of shares greater than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseOwnerSharesLtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of Bob does not decrease as expected.");
//         assertLt(bobSharesBefore - bobSharesAfter, burnedShares, "The shares' balance of Bob decreases by a number of shares greater than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The shares' balance of `owner` decreases by a number of shares greater than what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `owner` decreases by a number of shares lesser than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseOwnerSharesGtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of Bob does not decrease as expected.");
//         assertGt(bobSharesBefore - bobSharesAfter, burnedShares, "The shares' balance of Bob decreases by a number of shares lesser than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The total supply of shares decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total supply of shares does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories shares, assets, withdraw, total shares
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseTotalSharesEqExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertEq(totalSupplyBefore - totalSupplyAfter, burnedShares, "The total supply of shares does not decrease by the correct amount after a successful `withdraw` call.");
//     }

//     /// @notice The total supply of shares decreases by a number of shares lesser than what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares decreases by a number of shares greater than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, withdraw, total shares
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseTotalSharesLtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertLt(totalSupplyBefore - totalSupplyAfter, burnedShares,"The total supply of shares decreases by a number of shares greater than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The total supply of shares decreases by a number of shares greater than what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares decreases by a number of shares lesser than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, withdraw, total shares
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseTotalSharesGtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertGt(totalSupplyBefore - totalSupplyAfter, burnedShares, "The total supply of shares decreases by a number of shares lesser than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by the amount of `assets` withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' balance of the `receiver` does not increase by the amount of `assets` withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawIncreaseReceiverAssetsEqExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         withdrawBToA(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertEq(aliceAssetsAfter - aliceAssetsBefore, assets, "The assets' balance of Alice does not increase by the correct amount after a successful `withdraw` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by a number of `assets` lesser than what was withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the `receiver` increases by a number of `assets` greater than or equal to what was withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawIncreaseReceiverAssetsLtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         withdrawBToA(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertLt(aliceAssetsAfter - aliceAssetsBefore, assets, "The assets' balance of Alice increases by a number of assets greater than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by a number of `assets` greater than what was withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the `receiver` increases by a number of `assets` lesser than or equal to what was withdrawn after a successful `withdraw(assets, receiver, owner)` call.
//     /// @custom:ercx-categories assets, withdraw, balance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawIncreaseReceiverAssetsGtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         withdrawBToA(assets);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertGt(aliceAssetsAfter - aliceAssetsBefore, assets, "The assets' balance of Alice increases by a number of assets lesser than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' allowance of owner to caller does not decrease by the amount of shares output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories shares, assets, withdraw, allowance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseAllowanceOwnerCallerEqExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobAllowanceToAliceAfter = cut4626.allowance(bob, alice);
//         assertGt(shares, bobAllowanceToAliceAfter, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertEq(shares - bobAllowanceToAliceAfter, burnedShares, "The shares' allowance of Bob to Alice does not decrease by the correct amount after a successful `withdraw` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases by a number of shares lesser than what was output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' allowance of owner to caller decreases by a number of shares greater than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories assets, shares, withdraw, allowance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseAllowanceOwnerCallerLtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobAllowanceToAliceAfter = cut4626.allowance(bob, alice);
//         assertGt(shares, bobAllowanceToAliceAfter, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertLt(shares - bobAllowanceToAliceAfter, burnedShares, "The shares' allowance of Bob to Alice decreases by a number of shares greater than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases by a number of shares greater than what was output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' allowance of owner to caller decreases by a number of shares lesser than or equal to what was output by a successful `withdraw(assets, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories assets, shares, withdraw, allowance
//     /// @custom:ercx-concerned-function withdraw
//     function testWithdrawDecreaseAllowanceOwnerCallerGtExpected(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(0, shares) assetsOverflowRestriction(assets) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = withdrawBToA(assets);
//         uint256 bobAllowanceToAliceAfter = cut4626.allowance(bob, alice);
//         assertGt(shares, bobAllowanceToAliceAfter, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertGt(shares - bobAllowanceToAliceAfter, burnedShares, "The shares' allowance of Bob to Alice decreases by a number of shares lesser than or equal to what was expected after a successful `withdraw` call.");
//     }

//     /****************************
//     *
//     * Calling of withdraw()-* checks.
//     *
//     *****************************/

//     /// @notice `withdraw(assets, caller, caller) == deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing == shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(assets, caller, caller) != deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing != shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-categories assets, shares, withdraw, deposit
//     /// @custom:ercx-concerned-function withdraw, deposit
//     function testWithdrawDepositEq(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // To prevent minting of 0 share in selfDeposit(assets)
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         // ----------------------------------------------------
//         uint256 mintedShares = selfDeposit(assets);
//         assertEq(burnedShares, mintedShares, "`withdraw(assets, caller, caller) != deposit(assets, caller)`");
//     }

//     /// @notice `withdraw(assets, caller, caller) < deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing < shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(assets, caller, caller) >= deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing >= shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-categories assets, shares, withdraw, deposit
//     /// @custom:ercx-concerned-function withdraw, deposit
//     function testWithdrawDepositLt(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // To prevent minting of 0 share in selfDeposit(assets)
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         // ----------------------------------------------------
//         uint256 mintedShares = selfDeposit(assets);
//         assertLt(burnedShares, mintedShares, "`withdraw(assets, caller, caller) >= deposit(assets, caller)`");
//     }

//     /// @notice `withdraw(assets, caller, caller) > deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing > shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(assets, caller, caller) <= deposit(assets, caller)` where withdraw is called before deposit.
//     /// In layman terms, it means initial shares burnt from withdrawing <= shares minted from depositing for same amount
//     /// of assets.
//     /// @custom:ercx-categories assets, shares, withdraw, deposit
//     /// @custom:ercx-concerned-function withdraw, deposit
//     function testWithdrawDepositGt(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // To prevent minting of 0 share in selfDeposit(assets)
//         vm.assume(cut4626.previewDeposit(assets) > 0);
//         // ----------------------------------------------------
//         uint256 mintedShares = selfDeposit(assets);
//         assertGt(burnedShares, mintedShares, "`withdraw(assets, caller, caller) <= deposit(assets, caller)`");
//     }

//     /// @notice `mint(withdraw(assets, caller, caller), caller) == assets`. In layman terms, it means
//     /// shares minted == initial shares burnt from withdrawing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(withdraw(assets, caller, caller), caller) != assets`. In layman terms, it means
//     /// shares minted != initial shares burnt from withdrawing.
//     /// @custom:ercx-categories assets, withdraw, mint
//     /// @custom:ercx-concerned-function withdraw, mint
//     function testWithdrawMintIdentity(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // case where Alice has not enough assets to mint burnedShares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(burnedShares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (cut4626.previewMint(burnedShares) > assets) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(burnedShares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertEq(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) != assets`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(burnedShares);
//             assertEq(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) != assets`");
//         }
//     }

//     /// @notice `mint(withdraw(assets, caller, caller), caller) < assets`. In layman terms, it means
//     /// shares minted < initial shares burnt from withdrawing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(withdraw(assets, caller, caller), caller) >= assets`. In layman terms, it means
//     /// shares minted >= initial shares burnt from withdrawing.
//     /// @custom:ercx-categories assets, withdraw, mint
//     /// @custom:ercx-concerned-function withdraw, mint
//     function testWithdrawMintLt(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // case where Alice has not enough assets to mint burnedShares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(burnedShares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (cut4626.previewMint(burnedShares) > assets) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(burnedShares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertLt(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) >= assets`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(burnedShares);
//             assertLt(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) >= assets`");
//         }
//     }

//     /// @notice `mint(withdraw(assets, caller, caller), caller) > assets`. In layman terms, it means
//     /// shares minted > initial shares burnt from withdrawing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(withdraw(assets, caller, caller), caller) <= assets`. In layman terms, it means
//     /// shares minted <= initial shares burnt from withdrawing.
//     /// @custom:ercx-categories assets, withdraw, mint
//     /// @custom:ercx-concerned-function withdraw, mint
//     function testWithdrawMintGt(uint256 assets, uint256 shares)
//     initializeSharesTwoUsers(shares, 0) assetsOverflowRestriction(assets)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewWithdraw(assets) > 0);
//         uint256 burnedShares = selfWithdraw(assets);
//         // case where Alice has not enough assets to mint burnedShares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(burnedShares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (cut4626.previewMint(burnedShares) > assets) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(burnedShares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertGt(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) <= assets`");
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(burnedShares);
//             assertGt(depositedAssets, assets, "`mint(withdraw(assets, caller, caller), caller) <= assets`");
//         }
//     }

//     /****************************
//     *
//     * Calling of mint() checks.
//     *
//     *****************************/

//     /// @notice Calling `mint` reverts when the amount of shares mint to mint is greater than `maxMint(tokenReceiver)`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback Calling `mint` does not revert on some amount of shares that is greater than `maxMint(tokenReceiver)`.
//     /// @custom:ercx-categories shares, mint
//     /// @custom:ercx-concerned-function mint
//     function testMintRevertsWhenSharesGtMaxMint(uint256 shares, uint256 aliceAssets, uint256 bobShares) public
//     initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares) {
//         uint256 maxMintBob = cut4626.maxMint(bob);
//         if (maxMintBob != MAX_UINT256) {
//             vm.assume(shares > maxMintBob);
//             uint256 previewedAssets = cut4626.previewMint(shares);
//             vm.assume(previewedAssets >= 1);
//             vm.assume(previewedAssets <= aliceAssets);
//             (bool callApprove, ) = tryCustomerAssetApprove(alice, address(cut4626), aliceAssets);
//             if (callApprove) {
//                 vm.startPrank(alice);
//                 (bool callMint, ) = tryMint(shares, bob);
//                 vm.stopPrank();
//                 assertFalse(callMint, "Alice can mint an amount of shares that is greater than `maxMint(bob)` for Bob.");
//             }
//             else {
//                 emit log("Alice cannot approve assets for vault.");
//             }
//         }
//         else {
//             emit log("`maxMint(account)` is set to `type(uint256).max` for any `account`, and thus, the test passes by default.");
//         }
//     }

//     /// @notice Calling `maxMint` MUST return the maximum amount of shares mint would allow to be deposited for receiver.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback Calling `maxMint` does not return the maximum amount of shares mint would allow to be deposited for receiver.
//     /// @custom:ercx-categories shares, mint
//     /// @custom:ercx-concerned-function maxMint
//     function testMaxMintReturnMaxSharesMint(uint256 shares, uint256 aliceAssets, uint256 bobShares) public
//     initializeAssetsTwoUsers(aliceAssets, 0) initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares) {
//         uint256 maxMintBob = cut4626.maxMint(bob);
//         vm.assume(shares <= maxMintBob);
//         uint256 previewedAssets = cut4626.previewMint(shares);
//         vm.assume(previewedAssets >= 1);
//         vm.assume(previewedAssets <= aliceAssets);
//         (bool callApprove, ) = tryCustomerAssetApprove(alice, address(cut4626), aliceAssets);
//         if (callApprove) {
//             vm.startPrank(alice);
//             (bool callMint, ) = tryMint(shares, bob);
//             vm.stopPrank();
//             assertTrue(callMint, "Alice cannot mint a number of shares that is lesser than `maxMint(bob)` for Bob.");
//         }
//         else {
//             emit log("Alice cannot approve assets for the vault.");
//         }
//     }

//     /// @notice Calling `maxMint` returns 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback Calling `maxMint` does not return 2 ** 256 - 1, i.e., there might be a limit set for `maxMint`.
//     /// @custom:ercx-categories mint
//     /// @custom:ercx-concerned-function maxMint
//     function testMaxMintReturnMaxUint256IfNoLimit()
//     public {
//        assertEq(cut4626.maxMint(alice), MAX_UINT256, "Calling `maxMint` does not return 2 ** 256 - 1.");
//     }

//     /// @notice The shares' balance of `receiver` increases by the amount of shares minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' balance of `receiver` does not increase by the amount of shares minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseReceiverSharesEqExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         mintAToB(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertEq(bobSharesAfter - bobSharesBefore, shares, "The shares' balance of Bob does not increase by the correct amount after a successful `mint` call.");
//     }

//     /// @notice The shares' balance of `receiver` increases by a number of shares lesser than what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `receiver` increases by a number of shares greater than or equal to what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseReceiverSharesLtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         mintAToB(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertLt(bobSharesAfter - bobSharesBefore, shares, "The shares' balance of Bob increases by a number of shares greater than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The shares' balance of `receiver` increases by a number of shares greater than what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of `receiver` increases by a number of shares lesser than or equal to what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseReceiverSharesGtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         mintAToB(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesAfter, bobSharesBefore, "The shares' balance of Bob does not increase as expected.");
//         assertGt(bobSharesAfter - bobSharesBefore, shares, "The shares' balance of Bob increases by a number of shares lesser than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The total supply of shares increases by the amount of shares minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total supply of shares does not increase by the amount of shares minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, total shares
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalSharesEqExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         mintAToB(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertEq(totalSupplyAfter - totalSupplyBefore, shares, "The total supply of shares does not increase by the correct amount after a successful `mint` call.");
//     }

//     /// @notice The total supply of shares increases by a number of shares lesser than what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares increases by a number of shares greater than or equal to what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, total shares
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalSharesLtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         mintAToB(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertLt(totalSupplyAfter - totalSupplyBefore, shares, "The total supply of shares increases by a number of shares greater than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The total supply of shares increases by a number of shares greater than what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares increases by a number of shares lesser than or equal to what was minted by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories shares, mint, total shares
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalSharesGtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         mintAToB(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyAfter, totalSupplyBefore, "The total supply of shares does not increase as expected.");
//         assertGt(totalSupplyAfter - totalSupplyBefore, shares, "The total supply of shares increases by a number of shares lesser than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The assets' balance of the caller decreases by the amount of assets output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' balance of the caller does not decrease by the amount of assets output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseCallerAssetsEqExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertEq(aliceAssetsBefore - aliceAssetsAfter, depositedAssets, "The assets' balance of Alice does not decrease by the correct amount after a successful `mint` call.");
//     }

//     /// @notice The assets' balance of the caller decreases by a number of assets lesser than what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the caller decreases by a number of assets greater than or equal to what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseCallerAssetsLtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertLt(aliceAssetsBefore - aliceAssetsAfter, depositedAssets, "The assets' balance of Alice decreases by a number of assets greater than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The assets' balance of the caller decreases by a number of assets greater than what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the caller decreases by a number of assets lesser than or equal to what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, balance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseCallerAssetsGtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsBefore, aliceAssetsAfter, "The assets' balance of Alice does not decrease as expected.");
//         assertGt(aliceAssetsBefore - aliceAssetsAfter, depositedAssets, "The assets' balance of Alice decreases by a number of assets lesser than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The total assets increases by the amount of assets output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total assets does not increase by the amount of assets output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-categories assets, shares, mint, total assets
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalAssetsEqExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertEq(totalAssetsAfter - totalAssetsBefore, depositedAssets, "The total assets of the vault does not decrease by the correct amount after a successful `mint` call.");
//     }

//     /// @notice The total assets increases by a number of assets lesser than what was output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total assets increases by a number of assets greater than or equal to what was output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-categories assets, shares, mint, total assets
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalAssetsLtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertLt(totalAssetsAfter - totalAssetsBefore, depositedAssets, "The total assets of the vault increases by a number of assets greater than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The total assets increases by a number of assets greater than what was output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total assets increases by a number of assets lesser than or equal to what was output by a successful `mint(shares, output)` call.
//     /// @custom:ercx-categories assets, shares, mint, total assets
//     /// @custom:ercx-concerned-function mint
//     function testMintIncreaseTotalAssetsGtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 totalAssetsBefore = cut4626.totalAssets();
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 totalAssetsAfter = cut4626.totalAssets();
//         assertGt(totalAssetsAfter, totalAssetsBefore, "The total assets of the vault does not increase as expected.");
//         assertGt(totalAssetsAfter - totalAssetsBefore, depositedAssets, "The total assets of the vault increases by a number of assets lesser than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by the amount of assets output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' allowance of caller to vault does not decrease by the amount of assets output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, allowance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseAllowanceCallerVaultEqExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAllowanceToVault = asset.allowance(alice, address(cut4626));
//         assertGt(assets, aliceAllowanceToVault, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertEq(assets - aliceAllowanceToVault, depositedAssets, "The assets' allowance of Alice to the vault does not decrease by the correct amount after a successful `mint` call.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by a number of assets lesser than what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' allowance of caller to vault decreases by a number of assets greater than or equal to what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, allowance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseAllowanceCallerVaultLtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAllowanceToVault = asset.allowance(alice, address(cut4626));
//         assertGt(assets, aliceAllowanceToVault, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertLt(assets - aliceAllowanceToVault, depositedAssets, "The assets' allowance of Alice to the vault decreases by a number of assets greater than or equal to what was expected after a successful `mint` call.");
//     }

//     /// @notice The assets' allowance of caller to vault decreases by a number of assets greater than what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' allowance of caller to vault decreases by a number of assets lesser than or equal to what was output by a successful `mint(shares, receiver)` call.
//     /// @custom:ercx-categories assets, shares, mint, allowance
//     /// @custom:ercx-concerned-function mint
//     function testMintDecreaseAllowanceCallerVaultGtExpected(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = mintAToB(shares);
//         uint256 aliceAllowanceToVault = asset.allowance(alice, address(cut4626));
//         assertGt(assets, aliceAllowanceToVault, "The assets' allowance of Alice to the vault does not decrease as expected.");
//         assertGt(assets - aliceAllowanceToVault, depositedAssets, "The assets' allowance of Alice to the vault decreases by a number of assets lesser than or equal to what was expected after a successful `mint` call.");
//     }

//     /****************************
//     *
//     * Calling of mint()-* checks.
//     *
//     *****************************/

//     /// @notice `withdraw(mint(shares, caller), caller, caller) == shares`. In layman terms, it means
//     /// shares burnt from withdrawing == initial shares minted.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(mint(shares, caller), caller, caller) != shares`. In layman terms, it means
//     /// shares burnt from withdrawing != initial shares minted.
//     /// @custom:ercx-categories shares, mint, withdraw
//     /// @custom:ercx-concerned-function mint, withdraw
//     function testMintWithdrawIdentity(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         // case where Alice has not enough shares to withdraw depositedAssets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(depositedAssets < MAX_UINT256 / totalSupply);
//         }
//         if (cut4626.previewWithdraw(depositedAssets) > shares) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(depositedAssets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertEq(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) != shares`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(depositedAssets);
//             assertEq(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) != shares`");
//         }
//     }

//     /// @notice `withdraw(mint(shares, caller), caller, caller) < shares`. In layman terms, it means
//     /// shares burnt from withdrawing < initial shares minted.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(mint(shares, caller), caller, caller) >= shares`. In layman terms, it means
//     /// shares burnt from withdrawing >= initial shares minted.
//     /// @custom:ercx-categories shares, mint, withdraw
//     /// @custom:ercx-concerned-function mint, withdraw
//     function testMintWithdrawLtInitialShares(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         // case where Alice has not enough shares to withdraw depositedAssets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(depositedAssets < MAX_UINT256 / totalSupply);
//         }
//         if (cut4626.previewWithdraw(depositedAssets) > shares) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(depositedAssets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertLt(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) >= shares`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(depositedAssets);
//             assertLt(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) >= shares`");
//         }
//     }

//     /// @notice `withdraw(mint(shares, caller), caller, caller) > shares`. In layman terms, it means
//     /// shares burnt from withdrawing > initial shares minted.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `withdraw(mint(shares, caller), caller, caller) <= shares`. In layman terms, it means
//     /// shares burnt from withdrawing <= initial shares minted.
//     /// @custom:ercx-categories shares, mint, withdraw
//     /// @custom:ercx-concerned-function mint, withdraw
//     function testMintWithdrawGtInitialShares(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         // case where Alice has not enough shares to withdraw depositedAssets
//         uint256 totalSupply = cut4626.totalSupply();
//         if (totalSupply > 0) {
//             vm.assume(depositedAssets < MAX_UINT256 / totalSupply);
//         }
//         if (cut4626.previewWithdraw(depositedAssets) > shares) {
//             vm.startPrank(alice);
//             (bool callWithdraw, uint256 burnedShares) = tryWithdraw(depositedAssets, alice, alice);
//             vm.stopPrank();
//             if (callWithdraw) {
//                 assertGt(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) <= shares`");
//             }
//         }
//         else {
//             uint256 burnedShares = selfWithdraw(depositedAssets);
//             assertGt(burnedShares, shares, "`withdraw(mint(shares, caller), caller, caller) <= shares`");
//         }
//     }

//     /// @notice `mint(shares, caller) == redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting == assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(shares, caller) != redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting != assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-categories assets, shares, mint, redeem
//     /// @custom:ercx-concerned-function mint, redeem
//     function testMintRedeemEq(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         uint256 redeemedAssets = selfRedeem(shares);
//         assertEq(depositedAssets, redeemedAssets, "`mint(shares, caller) != redeem(shares, caller, caller)`");
//     }

//     /// @notice `mint(shares, caller) < redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting < assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(shares, caller) >= redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting >= assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-categories assets, shares, mint, redeem
//     /// @custom:ercx-concerned-function mint, redeem
//     function testMintRedeemLt(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         uint256 redeemedAssets = selfRedeem(shares);
//         assertLt(depositedAssets, redeemedAssets, "`mint(shares, caller) >= redeem(shares, caller, caller)`");
//     }

//     /// @notice `mint(shares, caller) > redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting > assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `mint(shares, caller) <= redeem(shares, caller, caller)` where mint is called before redeem.
//     /// In layman terms, it means initial assets lost by caller from minting <= assets gained by caller from redeeming
//     /// for same amount of shares.
//     /// @custom:ercx-categories assets, shares, mint, redeem
//     /// @custom:ercx-concerned-function mint, redeem
//     function testMintRedeemGt(uint256 shares, uint256 assets)
//     initializeAssetsTwoUsers(assets, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(assets > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewMint(shares) > 0);
//         uint256 depositedAssets = selfMint(shares);
//         uint256 redeemedAssets = selfRedeem(shares);
//         assertGt(depositedAssets, redeemedAssets, "`mint(shares, caller) <= redeem(shares, caller, caller)`");
//     }

//     /****************************
//     *
//     * Calling of redeem() checks.
//     *
//     *****************************/

//     /// @notice `maxRedeem(account) == vault.balanceOf(account)` (referenced from Solmate and OZ implementation)
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `maxRedeem(account) != vault.balanceOf(account)`
//     /// @custom:ercx-categories redeem
//     /// @custom:ercx-concerned-function maxRedeem
//     function testMaxRedeemEqBalanceOfShares(uint256 aliceShares)
//     public initializeSharesTwoUsers(aliceShares, 0) {
//        assertEq(cut4626.maxRedeem(alice), cut4626.balanceOf(alice), "`maxRedeem(account) != vault.balanceOf(account)`");
//     }

//     /// @notice Calling `redeem` reverts when the amount of shares to redeem is greater than `maxRedeem(tokenOwner)`.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback Calling `redeem` does not revert on some amount of shares that is greater than `maxRedeem(tokenOwner)`.
//     /// @custom:ercx-categories redeem, shares
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemRevertsWhenSharesGtMaxRedeem(uint256 shares, uint256 aliceShares)
//     public initializeSharesTwoUsers(aliceShares, 0) sharesOverflowRestriction(shares) {
//         vm.assume(aliceShares > 0);
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) >= 1);
//         uint256 maxRedeemAlice = cut4626.maxRedeem(alice);
//         vm.assume(shares > maxRedeemAlice);
//         vm.startPrank(alice);
//         (bool callWithdraw, ) = tryRedeem(shares, bob, alice);
//         vm.stopPrank();
//         assertFalse(callWithdraw, "Alice can redeem an amount of shares that is greater than `maxRedeem(alice)` for Bob.");
//     }

//     /// @notice The shares' balance of the `owner` decreases by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' balance of the `owner` does not decrease by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseOwnerSharesEqExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         redeemBToA(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of the Bob does not decrease as expected.");
//         assertEq(bobSharesBefore - bobSharesAfter, shares, "The shares' balance of Bob does not decrease by the correct amount after a successful `redeem` call.");
//     }

//     /// @notice The shares' balance of the `owner` decreases by a number of `shares` lesser than what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of the `owner` decreases by a number of `shares` greater than or equal to what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseOwnerSharesLtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         redeemBToA(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of the Bob does not decrease as expected.");
//         assertLt(bobSharesBefore - bobSharesAfter, shares, "The shares' balance of the Bob decreases by a number of shares greater than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The shares' balance of the `owner` decreases by a number of `shares` greater than what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' balance of the `owner` decreases by a number of `shares` lesser than or equal to what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseOwnerSharesGtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 bobSharesBefore = cut4626.balanceOf(bob);
//         redeemBToA(shares);
//         uint256 bobSharesAfter = cut4626.balanceOf(bob);
//         assertGt(bobSharesBefore, bobSharesAfter, "The shares' balance of the Bob does not decrease as expected.");
//         assertGt(bobSharesBefore - bobSharesAfter, shares, "The shares' balance of the Bob decreases by a number of shares lesser than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The total supply of shares decreases by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The total supply of shares does not decrease by the amount of `shares` redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, total shares
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseTotalSharesEqExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         redeemBToA(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertEq(totalSupplyBefore - totalSupplyAfter, shares, "The total supply of shares does not decrease by the correct amount after a successful `redeem` call.");
//     }

//     /// @notice The total supply of shares decreases by a number of `shares` lesser than what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares decreases by a number of `shares` greater than or equal to what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, total shares
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseTotalSharesLtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         redeemBToA(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertLt(totalSupplyBefore - totalSupplyAfter, shares, "The total supply of shares decreases by a number of shares greater than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The total supply of shares decreases by a number of `shares` greater than what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The total supply of shares decreases by a number of `shares` lesser than or equal to what was redeemed after a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, redeem, total shares
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseTotalSharesGtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 totalSupplyBefore = cut4626.totalSupply();
//         redeemBToA(shares);
//         uint256 totalSupplyAfter = cut4626.totalSupply();
//         assertGt(totalSupplyBefore, totalSupplyAfter, "The total supply of shares does not decrease as expected.");
//         assertGt(totalSupplyBefore - totalSupplyAfter, shares, "The total supply of shares decreases by a number of shares lesser than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by the amount of assets output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The assets' balance of the `receiver` does not increase by the amount of assets output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories shares, assets, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemIncreaseReceiverAssetsEqExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 redeemedAssets = redeemBToA(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertEq(aliceAssetsAfter - aliceAssetsBefore, redeemedAssets, "The assets' balance of Alice does not increase by the correct amount after a successful `redeem` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by a number of assets lesser than what was output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the `receiver` increases by a number of assets greater than or equal to what was output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemIncreaseReceiverAssetsLtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 redeemedAssets = redeemBToA(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertLt(aliceAssetsAfter - aliceAssetsBefore, redeemedAssets, "The assets' balance of Alice increases by a number of assets greater than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The assets' balance of the `receiver` increases by a number of assets greater than what was output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The assets' balance of the `receiver` increases by a number of assets lesser than or equal to what was output by a successful `redeem(shares, receiver, owner)` call.
//     /// @custom:ercx-categories assets, shares, redeem, balance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemIncreaseReceiverAssetsGtExpected(uint256 shares)
//     initializeSharesTwoUsers(0, shares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 aliceAssetsBefore = asset.balanceOf(alice);
//         uint256 redeemedAssets = redeemBToA(shares);
//         uint256 aliceAssetsAfter = asset.balanceOf(alice);
//         assertGt(aliceAssetsAfter, aliceAssetsBefore, "The assets' balance of Alice does not increase as expected.");
//         assertGt(aliceAssetsAfter - aliceAssetsBefore, redeemedAssets, "The assets' balance of Alice increases by a number of assets lesser than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases  by the amount of `shares` redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected pass
//     /// @custom:ercx-feedback The shares' allowance of owner to caller does not decrease by the amount of `shares` redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories shares, redeem, allowance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseAllowanceOwnerCallerEqExpected(uint256 bobShares, uint256 shares)
//     initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         redeemBToA(shares);
//         uint256 bobAllowanceToAlice = cut4626.allowance(bob, alice);
//         assertGt(bobShares, bobAllowanceToAlice, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertEq(bobShares - bobAllowanceToAlice, shares, "The allowance from Bob to Alice does not decrease by the correct amount after a successful `redeem` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases by a number of `shares` lesser than what was redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' allowance of owner to caller decreases by a number of `shares` greater than or equal to what was redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories shares, redeem, allowance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseAllowanceOwnerCallerLtExpected(uint256 bobShares, uint256 shares)
//     initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         redeemBToA(shares);
//         uint256 bobAllowanceToAlice = cut4626.allowance(bob, alice);
//         assertGt(bobShares, bobAllowanceToAlice, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertLt(bobShares - bobAllowanceToAlice, shares, "The shares' allowance of Bob to Alice decreases by a number of shares greater than or equal to what was expected after a successful `redeem` call.");
//     }

//     /// @notice The shares' allowance of owner to caller decreases by a number of `shares` greater than what was redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The shares' allowance of owner to caller decreases by a number of `shares` lesser than or equal to what was redeemed
//     /// (from some initial allowance >= shares) after a successful `redeem(shares, receiver, owner)` call if caller != owner.
//     /// @custom:ercx-categories shares, redeem, allowance
//     /// @custom:ercx-concerned-function redeem
//     function testRedeemDecreaseAllowanceOwnerCallerGtExpected(uint256 bobShares, uint256 shares)
//     initializeSharesTwoUsers(0, bobShares) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         redeemBToA(shares);
//         uint256 bobAllowanceToAlice = cut4626.allowance(bob, alice);
//         assertGt(bobShares, bobAllowanceToAlice, "The shares' allowance of Bob to Alice does not decrease as expected.");
//         assertGt(bobShares - bobAllowanceToAlice, shares, "The shares' allowance of Bob to Alice decreases by a number of shares lesser than or equal to what was expected after a successful `redeem` call.");
//     }

//     /****************************
//     *
//     * Calling of redeem()-* checks.
//     *
//     *****************************/

//     /// @notice `deposit(redeem(shares, caller, caller), caller) == shares`. In layman terms, it means
//     /// initial shares redeemed == shares minted from depositing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(redeem(shares, caller, caller), caller) != shares`. In layman terms, it means
//     /// initial shares redeemed != shares minted from depositing.
//     /// @custom:ercx-categories shares, redeem, deposit
//     /// @custom:ercx-concerned-function redeem, deposit
//     function testRedeemDepositIdentity(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         vm.assume(cut4626.previewDeposit(redeemedAssets) > 0); // to prevent minting of zero shares
//         uint256 mintedShares = selfDeposit(redeemedAssets);
//         assertEq(mintedShares, shares, "`deposit(redeem(shares, caller, caller), caller) != shares`");
//     }

//     /// @notice `deposit(redeem(shares, caller, caller), caller) < shares`. In layman terms, it means
//     /// initial shares redeemed < shares minted from depositing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(redeem(shares, caller, caller), caller) >= shares`. In layman terms, it means
//     /// initial shares redeemed >= shares minted from depositing.
//     /// @custom:ercx-categories shares, redeem, deposit
//     /// @custom:ercx-concerned-function redeem, deposit
//     function testRedeemDepositLtInitialShares(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         vm.assume(cut4626.previewDeposit(redeemedAssets) > 0); // to prevent minting of zero shares
//         uint256 mintedShares = selfDeposit(redeemedAssets);
//         assertLt(mintedShares, shares, "`deposit(redeem(shares, caller, caller), caller) >= shares`");
//     }

//     /// @notice `deposit(redeem(shares, caller, caller), caller) > shares`. In layman terms, it means
//     /// initial shares redeemed > shares minted from depositing.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `deposit(redeem(shares, caller, caller), caller) <= shares`. In layman terms, it means
//     /// initial shares redeemed <= shares minted from depositing.
//     /// @custom:ercx-categories shares, redeem, deposit
//     /// @custom:ercx-concerned-function redeem, deposit
//     function testRedeemDepositGtInitialShares(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         vm.assume(cut4626.previewDeposit(redeemedAssets) > 0); // to prevent minting of zero shares
//         uint256 mintedShares = selfDeposit(redeemedAssets);
//         assertGt(mintedShares, shares, "`deposit(redeem(shares, caller, caller), caller) <= shares`");
//     }

//     /// @notice `redeem(shares, caller, caller) == mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem == assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(shares, caller, caller) != mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem != assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-categories assets, shares, redeem, mint
//     /// @custom:ercx-concerned-function redeem, mint
//     function testRedeemMintEq(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         // case where Alice has not enough redeemedAssets to mint shares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(shares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (redeemedAssets < cut4626.previewMint(shares)) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(shares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertEq(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) != mint(shares, caller)`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(shares);
//             assertEq(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) != mint(shares, caller)`");
//         }
//     }

//     /// @notice `redeem(shares, caller, caller) < mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem < assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(shares, caller, caller) >= mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem >= assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-categories assets, shares, redeem, mint
//     /// @custom:ercx-concerned-function redeem, mint
//     function testRedeemMintLt(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         // case where Alice has not enough redeemedAssets to mint shares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(shares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (redeemedAssets < cut4626.previewMint(shares)) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(shares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertLt(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) >= mint(shares, caller)`");
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(shares);
//             assertLt(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) >= mint(shares, caller)`");
//         }
//     }

//     /// @notice `redeem(shares, caller, caller) > mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem > assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback `redeem(shares, caller, caller) <= mint(shares, caller)` where redeem is called before mint.
//     /// In layman terms, it means initial assets gained by caller from redeem <= assets lost by caller
//     /// from minting for same amount of shares.
//     /// @custom:ercx-categories assets, shares, redeem, mint
//     /// @custom:ercx-concerned-function redeem, mint
//     function testRedeemMintGt(uint256 shares)
//     initializeSharesTwoUsers(shares, 0) sharesOverflowRestriction(shares)
//     public {
//         vm.assume(shares > 0);
//         vm.assume(cut4626.previewRedeem(shares) > 0);
//         uint256 redeemedAssets = selfRedeem(shares);
//         // case where Alice has not enough redeemedAssets to mint shares
//         if (cut4626.totalSupply() > 0) {
//             vm.assume(shares < MAX_UINT256 / (cut4626.totalAssets() + 1));
//         }
//         if (redeemedAssets < cut4626.previewMint(shares)) {
//             vm.startPrank(alice);
//             (bool callMint, uint256 depositedAssets) = tryMint(shares, alice);
//             vm.stopPrank();
//             if (callMint) {
//                 assertGt(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) <= mint(shares, caller)`");
//             }
//             else {
//                 assertTrue(false);
//             }
//         }
//         else {
//             uint256 depositedAssets = selfMint(shares);
//             assertGt(redeemedAssets, depositedAssets, "`redeem(shares, caller, caller) <= mint(shares, caller)`");
//         }
//     }

//     /****************************
//     *
//     * Vault transferrable checks.
//     *
//     *****************************/

//     /// @notice The token vault is non-transferrable, it MAY revert on calls to `transfer`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The token vault is transferrable via `transfer`.
//     /// @custom:ercx-categories eip20
//     function testSharesIsNotTransferAble(uint256 shares)
//     initializeSharesTwoUsers(shares, 0)
//     public {
//         vm.assume(shares > 0);
//         tryCustomerShareTransfer(alice, bob, shares);
//         assertEq(cut4626.balanceOf(alice), shares, "The token vault is transferrable via `transfer`.");
//     }

//     /// @notice The token vault is non-transferrable, it MAY revert on calls to `transferFrom`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback The token vault is transferrable via `transferFrom`.
//     /// @custom:ercx-categories eip20
//     function testSharesIsNotTransferFromAble(uint256 shares)
//     initializeSharesTwoUsers(shares, 0)
//     public {
//         vm.assume(shares > 0);
//         (bool callApprove, ) = tryCustomerShareApprove(alice, bob, shares);
//         assertTrue(callApprove);
//         tryCustomerShareTransferFrom(bob, alice, carol, shares);
//         assertEq(cut4626.balanceOf(alice), shares, "The token vault is transferrable via `transferFrom`.");
//     }

//     /****************************
//     *
//     * Discrepancy checks between convertTo* and preview*
//     *
//     ****************************/

//     /// @notice There is no discrepancy between `convertToShares` and `previewDeposit`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback There is discrepancy between `convertToShares` and `previewDeposit`.
//     /// @custom:ercx-categories shares, assets, deposit
//     /// @custom:ercx-concerned-function previewDeposit
//     function testNoDiscrepancyConvertToSharesAndPreviewDeposit(uint256 assets) external
//     assetsOverflowRestriction(assets) {
//         vm.assume(assets > 0);
//         uint256 ctsShares = cut4626.convertToShares(assets);
//         uint256 pdShares = cut4626.previewDeposit(assets);
//         assertEq(ctsShares, pdShares, "`convertToShares(assets) != previewDeposit(assets)`");
//     }

//     /// @notice There is no discrepancy between `convertToAssets` and `previewMint`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback There is discrepancy between `convertToAssets` and `previewMint`.
//     /// @custom:ercx-categories shares, assets, mint
//     /// @custom:ercx-concerned-function previewMint
//     function testNoDiscrepancyConvertToAssetsAndPreviewMint(uint256 shares) external
//     sharesOverflowRestriction(shares) {
//         vm.assume(shares > 0);
//         uint256 ctaShares = cut4626.convertToAssets(shares);
//         uint256 pmShares = cut4626.previewMint(shares);
//         assertEq(ctaShares, pmShares, "`convertToAssets(shares) != previewMint(shares)`");
//     }

//     /// @notice There is no discrepancy between `convertToShares` and `previewWithdraw`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback There is discrepancy between `convertToShares` and `previewWithdraw`.
//     /// @custom:ercx-categories shares, assets, withdraw
//     /// @custom:ercx-concerned-function previewWithdraw
//     function testNoDiscrepancyConvertToSharesAndPreviewWithdraw(uint256 assets) external
//     assetsOverflowRestriction(assets) {
//         vm.assume(assets > 0);
//         uint256 ctsShares = cut4626.convertToShares(assets);
//         uint256 pwShares = cut4626.previewWithdraw(assets);
//         assertEq(ctsShares, pwShares, "`convertToShares(assets) != previewWithdraw(assets)`");
//     }

//     /// @notice There is no discrepancy between `convertToAssets` and `previewRedeem`.
//     /// @custom:ercx-expected optional
//     /// @custom:ercx-feedback There is discrepancy between `convertToAssets` and `previewRedeem`.
//     /// @custom:ercx-categories shares, assets, redeem
//     /// @custom:ercx-concerned-function previewRedeem
//     function testNoDiscrepancyConvertToAssetsAndPreviewRedeem(uint256 shares) external
//     sharesOverflowRestriction(shares) {
//         vm.assume(shares > 0);
//         uint256 ctaShares = cut4626.convertToAssets(shares);
//         uint256 prShares = cut4626.previewRedeem(shares);
//         assertEq(ctaShares, prShares, "`convertToAssets(shares) != previewRedeem(shares)`");
//     }

//     /****************************
//     *
//     * `totalAssets` and `totalSupply` functions feature checks
//     *
//     ****************************/

// 	/// @notice `vault.totalAssets() < asset.balanceOf(vault)`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalAssets() >= asset.balanceOf(vault)`
//     /// @custom:ercx-categories assets, total assets
//     /// @custom:ercx-concerned-function totalAssets
//     function testTotalAssetsLtVaultAssetsBalance()
// 	external {
// 		uint256 totalAssets = cut4626.totalAssets();
// 		uint256 balance = asset.balanceOf(address(cut4626));
//         assertLt(totalAssets, balance, "`vault.totalAssets() >= asset.balanceOf(vault)`");
// 	}

// 	/// @notice `vault.totalAssets() > asset.balanceOf(vault)`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalAssets() <= asset.balanceOf(vault)`
//     /// @custom:ercx-categories assets, total assets
//     /// @custom:ercx-concerned-function totalAssets
//     function testTotalAssetsGtVaultAssetsBalance()
// 	external {
// 		uint256 totalAssets = cut4626.totalAssets();
// 		uint256 balance = asset.balanceOf(address(cut4626));
//         assertGt(totalAssets, balance, "`vault.totalAssets() <= asset.balanceOf(vault)`");
// 	}

// 	/// @notice `vault.totalAssets() > 0`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalAssets() == 0`
//     /// @custom:ercx-categories total assets
//     /// @custom:ercx-concerned-function totalAssets
//     function testTotalAssetsGtZero()
// 	external {
// 		uint256 totalAssets = cut4626.totalAssets();
//         assertGt(totalAssets, 0, "`vault.totalAssets() == 0`");
// 	}

// 	/// @notice `vault.totalSupply() > 0`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalSupply() == 0`
//     /// @custom:ercx-categories total supply
//     /// @custom:ercx-concerned-function totalSupply
//     function testTotalSupplyGtZero()
// 	external {
// 		uint256 totalSupply = cut4626.totalSupply();
//         assertGt(totalSupply, 0, "`vault.totalSupply() == 0`");
// 	}

// 	/// @notice `vault.totalAssets() < vault.totalSupply()`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalAssets() >= vault.totalSupply()`
//     /// @custom:ercx-categories total assets, total supply
//     /// @custom:ercx-concerned-function totalAssets, totalSupply
//     function testTotalAssetsLtTotalSupply()
// 	external {
// 		uint256 totalAssets = cut4626.totalAssets();
//         uint256 totalSupply = cut4626.totalSupply();
//         assertLt(totalAssets, totalSupply, "`vault.totalAssets() >= vault.totalSupply()`");
// 	}

// 	/// @notice `vault.totalAssets() > vault.totalSupply()`
//     /// @custom:ercx-expected optional
// 	/// @custom:ercx-feedback `vault.totalAssets() <= vault.totalSupply()`
//     /// @custom:ercx-categories total assets, total supply
//     /// @custom:ercx-concerned-function totalAssets, totalSupply
//     function testTotalAssetsGtTotalSupply()
// 	external {
// 		uint256 totalAssets = cut4626.totalAssets();
//         uint256 totalSupply = cut4626.totalSupply();
//         assertGt(totalAssets, totalSupply, "`vault.totalAssets() <= vault.totalSupply()`");
// 	}

// }
