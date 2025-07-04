// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC20Abstract.sol";

/// @notice Abstract contract that consists of testing functions with test for properties
/// that are neither desirable nor undesirable but instead implementation choices.
contract ERC20Features is ERC20Abstract {
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
     * decreaseAllowance feature checks
     *
     *
     */

    /// @notice A successful `decreaseAllowance` call of a positive amount DECREASES the allowance by MORE than the said amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `decreaseAllowance` call of a positive amount DOES NOT DECREASE the allowance by MORE than the said amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceGtExpected(uint256 substractedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(substractedValue > 0);
        vm.assume(substractedValue < allowance);
        vm.assume(allowance < MAX_UINT256 - substractedValue);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceDecreaseAllowance(bob, substractedValue));
        assertGt(allowance - substractedValue, cut.allowance(alice, bob));
    }

    /// @notice A successful `decreaseAllowance` call of a positive amount DECREASES the allowance by LESS than the said amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `decreaseAllowance` call of a positive amount DOES NOT DECREASE the allowance by LESS than the said amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceLtExpected(uint256 substractedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(substractedValue > 0);
        vm.assume(substractedValue < allowance);
        vm.assume(allowance < MAX_UINT256 - substractedValue);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceDecreaseAllowance(bob, substractedValue));
        assertLt(allowance - substractedValue, cut.allowance(alice, bob));
    }

    /// @notice A `decreaseAllowance` call DOES NOT REVERT if there's not enough allowance to decrease
    /// and TURNS the allowance to zero since the current allowance is smaller than the amount to decrease.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback A `decreaseAllowance` call REVERTS if there's not enough allowance to decrease
    /// or DOES NOT TURN the allowance to zero even though the current allowance is smaller than the amount to decrease.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceBehaviorInexact(
        uint256 prevAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2
    ) external initializeAllowanceOneUser(prevAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(prevAllowance < decreaseAmount);
        // Alice decreases more allowance from Bob to what he has
        assertSuccess(_tryAliceDecreaseAllowance(bob, decreaseAmount));
        // Bob should have zero allowance
        assertEq(cut.allowance(alice, bob), 0);
    }

    /**
     *
     *
     * increaseAllowance feature checks
     *
     *
     */

    /// @notice A successful `increaseAllowance` call of a positive amount INCREASES the allowance by MORE than the said amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `increaseAllowance` call of a positive amount DOES NOT INCREASE the allowance by MORE than the said amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function increaseAllowance
    function testIncreaseAllowanceGtExpected(uint256 addedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(addedValue > 0);
        vm.assume(allowance > addedValue);
        vm.assume(allowance < MAX_UINT256 - addedValue);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceIncreaseAllowance(bob, addedValue));
        assertGt(cut.allowance(alice, bob), allowance + addedValue);
    }

    /// @notice A successful `increaseAllowance` call of a positive amount INCREASES the allowance by LESS than the said amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `increaseAllowance` call of a positive amount DOES NOT INCREASE the allowance by LESS than the said amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function increaseAllowance
    function testIncreaseAllowanceLtExpected(uint256 addedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(addedValue > 0);
        vm.assume(allowance > addedValue);
        vm.assume(allowance < MAX_UINT256 - addedValue);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceIncreaseAllowance(bob, addedValue));
        assertLt(cut.allowance(alice, bob), allowance + addedValue);
    }

    /**
     *
     *
     * transferFrom feature checks
     *
     *
     */

    /// @notice A successful `transferFrom` call of a positive amount DECREASES the allowance of the tokenSender by MORE than the transferred amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `transferFrom` call of a positive amount DOES NOT DECREASE the allowance of the tokenSender by MORE than the transferred amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, allowance
    /// @custom:ercx-concerned-function transferFrom
    function testTransferFromDecreaseAllowanceGtExpected(uint256 amount, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        vm.assume(allowance >= amount);
        vm.assume(allowance < MAX_UINT256);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryBobTransferFrom(alice, carol, amount));
        assertGt(allowance - amount, cut.allowance(alice, bob));
    }

    /// @notice A successful `transferFrom` call of a positive amount DECREASES the allowance of the tokenSender by LESS than the transferred amount.
    /// @custom:ercx-expected fail
    /// @custom:ercx-feedback A successful `transferFrom` call of a positive amount DOES NOT DECREASE the allowance of the tokenSender by LESS than the transferred amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, allowance
    /// @custom:ercx-concerned-function transferFrom
    function testTransferFromDecreaseAllowanceLtExpected(uint256 amount, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        vm.assume(allowance >= amount);
        vm.assume(allowance < MAX_UINT256);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryBobTransferFrom(alice, carol, amount));
        assertLt(allowance - amount, cut.allowance(alice, bob));
    }

    /**
     *
     *
     * approve function categorization: default vs recommended
     *
     *
     */

    /// @notice Consecutive calls of `approve` function of positive-to-positive amounts CAN be called.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback Consecutive calls of `approve` function of positive-to-positive amounts CAN be called.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve
    function testOverwriteApprovePositiveToPositive(uint256 approveAmount1, uint256 approveAmount2) external {
        // to make sure the allowance of Alice for bob is reset to 0
        if (cut.allowance(alice, bob) != 0) {
            assertSuccess(_tryAliceApprove(bob, 0));
        }
        vm.assume(approveAmount1 > 0);
        vm.assume(approveAmount2 > 0);
        // first call of approve function of positive amount
        assertSuccess(_tryAliceApprove(bob, approveAmount1));
        // second call of approve function of another positive amount
        assertSuccess(_tryAliceApprove(bob, approveAmount2));
    }

    /**
     *
     *
     * Infinite approval.
     *
     *
     */

    /// @notice The token REVERTS if one set the approval to MAX_UINT256.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The token DOES NOT REVERT if approval is set to MAX_UINT256.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve
    function testRevertsOnInfiniteApproval(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertFail(_tryAliceApprove(bob, MAX_UINT256));
    }

    /// @notice The token HAS infinite approval property. That is, if the approval is set to
    /// MAX_UINT256 and a `transfer` is called, the allowance does not decrease by the transferred amount.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The token MAY NOT HAVE the infinite approval property. That is,
    /// if the approval is set to MAX_UINT256 and a `transfer` is called, the allowance
    /// may decrease by the transferred amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with EITHER dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories approval, transferFrom, allowance
    /// @custom:ercx-concerned-function approve
    function testInfiniteApprovalConstant(uint256 transferAmount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(transferAmount < cut.balanceOf(alice));
        CallResult memory callResultApprove = _tryAliceApprove(bob, MAX_UINT256);
        bool successApprove = callResultApprove.success && cut.allowance(alice, bob) == MAX_UINT256;
        // Skip the test if the approve call fails
        conditionalSkip(!successApprove, "Inconclusive test: Alice cannot set the approval for Bob to MAX_UINT256");
        CallResult memory callResultTransfer = _tryBobTransferFrom(alice, carol, transferAmount);
        bool transferSuccess = callResultTransfer.success;
        // Skip the test if the transferFrom call fails
        conditionalSkip(!transferSuccess, "Inconclusive test: Bob cannot call `transferFrom` from Alice to Carol.");
        assertEq(cut.allowance(alice, bob), MAX_UINT256);
    }

    /// @notice The token REVERTS if a tokenApprover approves a tokenApprovee more than its balance.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The token DOES NOT REVERT if a tokenApprover approves a tokenApprovee more than its balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval, balance
    /// @custom:ercx-concerned-function approve
    function testRevertsIfApprovalGreaterThanBalance(uint256 approveAmount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(approveAmount > cut.balanceOf(alice));
        assertFail(_tryAliceApprove(bob, approveAmount));
    }

    /// @notice The token DOES NOT have infinite approval property. That is, if the approval
    /// is set to MAX_UINT256 and a `transfer` is called, the allowance is decreased by the transferred amount.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The token MAY support infinite approval. That is, if the approval
    /// is set to MAX_UINT256 and a `transfer` is called, the allowance may not decrease
    /// by the transferred amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with EITHER dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories approval, transferFrom, allowance
    /// @custom:ercx-concerned-function approve
    function testInfiniteApprovalNotConstant(uint256 transferAmount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(transferAmount < cut.balanceOf(alice));
        CallResult memory callResultApprove = _tryAliceApprove(bob, MAX_UINT256);
        bool successApprove = callResultApprove.success;
        // Skip the test if the approve call fails
        conditionalSkip(!successApprove, "Inconclusive test: Alice cannot set the approval for Bob to MAX_UINT256");
        assertEq(cut.allowance(alice, bob), MAX_UINT256);
        CallResult memory callResultTransfer = _tryBobTransferFrom(alice, carol, transferAmount);
        bool transferSuccess = callResultTransfer.success;
        // Skip the test if the transferFrom call fails
        conditionalSkip(!transferSuccess, "Inconclusive test: Bob cannot call `transferFrom` from Alice to Carol.");
        assertEq(cut.allowance(alice, bob), MAX_UINT256 - transferAmount);
    }

    /**
     *
     *
     * Approval with balance verify
     *
     *
     */

    /// @notice The token ALLOWS tokenApprover to call `approve` of an amount higher than her balance.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The token DOES NOT ALLOW tokenApprover to call `approve` of an amount higher than her balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval, transferFrom, allowance
    /// @custom:ercx-note from awesome buggy A19
    /// @custom:ercx-concerned-function approve
    function testCanApproveMoreThanBalance(uint256 balanceAlice, uint256 approvedAmount)
        external
        initializeStateTwoUsers(balanceAlice, 0)
    {
        vm.assume(approvedAmount > cut.balanceOf(alice)); //Note that approveAmount is necessary > 0
        assertSuccess(_tryAliceApprove(bob, approvedAmount));
    }

    /// @notice Given the token DOES NOT ALLOW tokenApprover to call `approve` of an amount higher than her balance.
    /// The tokenApprover MUST maintain at least the said amount in her balance before she can make a `transfer` call
    /// to an account other than the tokenApprovee.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback The tokenApprover DOES NOT need to maintain at least the said amount in her balance before she
    /// can make a `transfer` call to an account other than the tokenApprovee.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with EITHER dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transfer OR the token ALLOWS tokenApprover to call `approve` of an amount higher than her balance.
    /// @custom:ercx-categories approval, transferFrom, allowance
    /// @custom:ercx-concerned-function approve
    /// @custom:ercx-note inspired from awesome buggy A19
    function testMaintainsApprovalLowerThanBalance(
        uint256 balanceAlice,
        uint256 approvedAmountGreater,
        uint256 approvedAmountLower
    ) external initializeStateTwoUsers(balanceAlice, 0) {
        uint256 aliceBalance = cut.balanceOf(alice);
        vm.assume(approvedAmountLower < MAX_UINT256);
        vm.assume(approvedAmountGreater > aliceBalance); //Note that approveAmountGreater is necessary > 0
        vm.assume(approvedAmountLower + 1 < aliceBalance); //Note that approveAmountLower is necessary > 0
        CallResult memory callResultApproval1 = _tryAliceApprove(bob, approvedAmountGreater);
        // Skip the test if it is possible to approve more than one's balance
        conditionalSkip(
            callResultApproval1.success, "Inconclusive test: It is possible to approve more than one's balance."
        );
        // Transfer some token
        CallResult memory callResultApproval2 = _tryAliceApprove(bob, approvedAmountLower); // This should succeed.
        // Skip the test if the above approve call fails
        conditionalSkip(
            !callResultApproval2.success,
            "Inconclusive test: Alice was not able to approve Bob for a higher nor a lower amount."
        );
        // Make Alice's balance lower than approval
        uint256 amountToTransfer = aliceBalance - approvedAmountLower + 1;
        CallResult memory callResultTransfer = _tryAliceTransfer(carol, amountToTransfer);
        // Skip the test if the transfer call fails
        conditionalSkip(!callResultTransfer.success, "Inconclusive test: Alice's transfer failed.");
        // Check if the contract adjusted the alllowance.
        if (cut.allowance(alice, bob) == approvedAmountLower) {
            emit log("Allowance of Alice to Bob was not adjusted.");
            assertTrue(false);
        } else {
            emit log("Contract adjusted allowance.");
        }
    }
}
