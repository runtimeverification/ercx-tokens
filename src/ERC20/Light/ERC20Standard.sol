// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC20Abstract.sol";

/// @notice Abstract contract that consists of testing functions which test for properties from the standard
/// stated in the official EIP20 specification.
abstract contract ERC20Standard is ERC20Abstract {
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
     *
     * MANDATORY checks.
     *
     *
     *
     */

    /**
     *
     *
     * transfer() mandatory checks.
     *
     *
     */

    /// @notice A successful `transfer` call of zero amount to another account MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to another account is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToOthersPossible(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(_tryAliceTransfer(bob, 0), "Alice failed to transfer zero amount to Bob.");
    }

    /// @notice A successful `transfer` call of zero amount to another account MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to another account does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, event
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToOthersEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 0);
        _tryAliceTransfer(bob, 0);
    }

    /// @notice A successful `transfer` call of zero amount to self MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to self is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToSelfPossible(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(_tryAliceTransfer(alice, 0), "Alice failed to transfer zero amount to herself.");
    }

    /// @notice A successful `transfer` call of zero amount to self MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to self does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, event
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToSelfEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, alice, 0);
        _tryAliceTransfer(alice, 0);
    }

    /// @notice A successful `transfer` call of positive amount MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of positive amount does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, event
    /// @custom:ercx-concerned-function transfer
    function testPositiveTransferEventEmission(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, amount);
        _tryAliceTransfer(bob, amount);
    }

    /**
     *
     *
     * transferFrom() mandatory checks.
     *
     *
     */

    /// @notice A successful `transferFrom` of zero amount by any user other than the tokenSender, from and to different accounts, MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to different accounts,  does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, carol, 0);
        _tryBobTransferFrom(alice, carol, 0);
    }

    /// @notice A successful `transferFrom` of zero amount by any user other than the tokenSender, from and to the same address, MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherToSameAccountEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, alice, 0);
        _tryBobTransferFrom(alice, alice, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself to herself MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfToSelfEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, alice, 0);
        _tryAliceTransferFrom(alice, alice, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself to someone MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfToSomeoneEmitsEvent(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, carol, 0);
        _tryAliceTransferFrom(alice, carol, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender MUST be possible, from and to the same account.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to the same account, is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherFromAndToSameAccountPossible(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(
            _tryBobTransferFrom(alice, alice, 0),
            "Bob failed to transferFrom zero amount from Alice's account to Alice."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender MUST be possible, from and to different accounts.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to different accounts, is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherPossibleFromAndToDifferentAccounts(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(
            _tryBobTransferFrom(alice, carol, 0),
            "Bob failed to transferFrom zero amount from Alice's account to Carol."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender to the tokenSender MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender to the tokenSender is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherToSelfPossible(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(
            _tryBobTransferFrom(alice, alice, 0),
            "Bob failed to transferFrom zero amount from Alice's account to herself."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfPossible(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertSuccess(
            _tryAliceTransferFrom(alice, carol, 0),
            "Alice failed to transferFrom zero amount from her account to Carol."
        );
    }

    /// @notice A successful `transferFrom` call of positive amount MUST emit Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of positive amount does NOT emit Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, event
    /// @custom:ercx-concerned-function transferFrom
    function testPositiveTransferFromEventEmission(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        CallResult memory callResultApprove = _tryAliceApprove(bob, amount);
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice failed to approve Bob.");
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, carol, amount);
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, carol, amount);
        conditionalSkip(!callResultTransferFrom.success, "Inconclusive test: Alice failed to call transferFrom.");
    }

    /**
     *
     *
     * approve() mandatory checks.
     *
     *
     */

    /// @notice A successful `approve` call of zero amount MUST emit the `Approval` event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `approve` call of zero amount does NOT emit the `Approval` event correctly.
    /// @custom:ercx-categories approval, event, zero amount
    /// @custom:ercx-concerned-function approve, Approval
    function testZeroApprovalEventEmission() external {
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, 0);
        _tryCustomerApprove(alice, bob, 0);
    }

    /// @notice A successful `approve` call of positive amount MUST emit the `Approval` event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `approve` call of positive amount does NOT emit the `Approval` event correctly.
    /// @custom:ercx-categories approval, event
    /// @custom:ercx-concerned-function approve, Approval
    function testPositiveApprovalEventEmission(uint256 amount) external {
        vm.assume(amount > 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, amount);
        _tryCustomerApprove(alice, bob, amount);
    }

    /// @notice After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, zero amount MUST be transferable
    /// by tokenApprovee via a `transferFrom` call, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, zero amount is NOT transferable
    /// by tokenApprovee via a `transferFrom` call, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories approval, zero amount, transferFrom, balance
    /// @custom:ercx-concerned-function approve, transferFrom
    function testPositiveApproveAllowsZeroTransferFrom(uint256 approveAmount, uint256 balance1, uint256 balance2)
        external
    {
        internalTestPositiveApproveAllowsTransferFrom(approveAmount, 0, balance1, balance2);
    }

    /// @notice After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, any positive amount up to the said amount MUST be transferable
    /// by tokenApprovee via a `transferFrom` call, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, any positive amount up to the said amount is NOT transferable
    /// by tokenApprovee via a `transferFrom` call, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories approval, transferFrom, balance
    /// @custom:ercx-concerned-function approve, transferFrom
    function testPositiveApproveAllowsPositiveTransferFrom(
        uint256 approveAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) external {
        vm.assume(transferAmount > 0);
        internalTestPositiveApproveAllowsTransferFrom(approveAmount, transferAmount, balance1, balance2);
    }

    /// @notice Internal property test: After a tokenApprover approves a tokenApprovee some positive amount, any amount up to
    /// the said amount MUST be transferable by tokenApprovee, provided a sufficient balance of tokenApprover.
    function internalTestPositiveApproveAllowsTransferFrom(
        uint256 approveAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) internal initializeStateTwoUsers(balance1, balance2) {
        vm.assume(approveAmount > 0);
        vm.assume(transferAmount <= approveAmount);
        vm.assume(cut.balanceOf(alice) >= transferAmount);
        CallResult memory callApprove = _tryAliceApprove(bob, approveAmount);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice failed to approve Bob.");
        assertSuccess(
            _tryBobTransferFrom(alice, bob, transferAmount), "Bob failed to transferFrom from Alice to his account."
        );
    }

    /**
     *
     *
     * allowance() mandatory checks.
     *
     *
     */

    /// @notice Zero approved amount MUST be reflected in the allowance correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Zero approved amount is NOT reflected in the allowance correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: approve.
    /// @custom:ercx-categories approval, allowance, zero amount
    /// @custom:ercx-concerned-function approve
    function testZeroApproveLeadsToAllowance() external {
        _internalTestApproveLeadsToAllowance(0);
    }

    /// @notice Positive approved amount MUST be reflected in the allowance correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Positive approved amount is NOT reflected in the allowance correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: approve.
    /// @custom:ercx-categories approval, allowance
    /// @custom:ercx-concerned-function approve
    function testPositiveApproveLeadsToAllowance(uint256 amount) external {
        vm.assume(amount > 0);
        _internalTestApproveLeadsToAllowance(amount);
    }

    /// @notice Internal property test: An arbitrary approved `amount` MUST be reflected in the allowance.
    function _internalTestApproveLeadsToAllowance(uint256 amount) internal {
        CallResult memory callApprove = _tryAliceApprove(bob, amount);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice failed to approve Bob.");
        assertEq(
            cut.allowance(alice, bob),
            amount,
            "The value of allowance(alice, bob) does not equate the value approved by Alice to Bob."
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
     * transfer() recommended checks.
     *
     *
     */

    /// @notice A tokenSender (which is also the `msg.sender`) SHOULD NOT be able to call `transfer` of an amount more than his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A tokenSender (which is also the `msg.sender`) CAN call `transfer` of an amount more than his balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transfer
    function testCannotTransferMoreThanBalance(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > cut.balanceOf(alice));
        assertFail(_tryAliceTransfer(bob, amount), "Alice could transfer more than her balance to Bob");
    }

    /**
     *
     *
     * transferFrom() recommended checks.
     *
     *
     */

    /// @notice A tokenReceiver SHOULD NOT be able to call `transferFrom` of any positive amount from a tokenSender if the tokenSender did not approve the tokenReceiver previously.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A tokenReceiver CAN be able to call `transferFrom` of a positive amount from an tokenSender even though the tokenSender did not approve the tokenReceiver previously.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, approval
    /// @custom:ercx-concerned-function transferFrom
    function testNoApprovalCannotTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        uint256 aliceBalance = cut.balanceOf(alice);
        vm.assume(aliceBalance >= amount);
        assertFail(
            _tryBobTransferFrom(alice, bob, amount), "Bob was able to transferFrom Alice while he was not approved."
        );
    }

    /// @notice A `msg.sender` SHOULD NOT be able to call `transferFrom` of any positive amount from his/her own acount to any tokenReceiver if the `msg.sender` did not approve him/herself prior to the call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `msg.sender` CAN call `transferFrom` of a positive amount from his/her own acount to any tokenReceiver even though the `msg.sender` did not approve him/herself prior to the call.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, approval
    /// @custom:ercx-concerned-function transferFrom
    function testNoSelfApprovalCannotSelfTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        uint256 aliceBalance = cut.balanceOf(alice);
        vm.assume(aliceBalance >= amount);
        assertFail(
            _tryAliceTransferFrom(alice, bob, amount),
            "Alice was able to transferFrom self while she was not approved by herself."
        );
    }

    /// @notice A tokenReceiver SHOULD NOT be able to call `transferFrom` of an amount more than her allowance from the tokenSender even if the tokenSender's balance is more than or equal to the said amount.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback  A tokenReceiver CAN call `transferFrom` of an amount more than her allowance from the tokenSender.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, allowance, balance
    /// @custom:ercx-concerned-function transferFrom
    function testCannotTransferFromMoreThanAllowanceLowerThanBalance(
        uint256 approveAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) external initializeStateTwoUsers(balance1, balance2) {
        vm.assume(transferAmount > 0);
        vm.assume(approveAmount > 0);
        vm.assume(approveAmount < transferAmount);
        uint256 aliceBalance = cut.balanceOf(alice);
        vm.assume(transferAmount <= aliceBalance);

        CallResult memory callResultApprove = _tryAliceApprove(bob, approveAmount);
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice failed to approve Bob.");
        assertFail(
            _tryBobTransferFrom(alice, bob, transferAmount),
            "Bob was able to transferFrom Alice more than the allowance given by Alice."
        );
    }

    /// @notice A tokenReceiver SHOULD NOT be able to call `transferFrom` of an amount more than the tokenSender's balance even if the tokenReceiver's allowance from the tokenSender is less than the said amount.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A tokenReceiver CAN call `transferFrom` of an amount more than the tokenSender's balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, allowance, balance
    /// @custom:ercx-concerned-function transferFrom
    function testCannotTransferFromMoreThanBalanceButLowerThanAllowance(
        uint256 approveAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) external initializeStateTwoUsers(balance1, balance2) {
        vm.assume(transferAmount > cut.balanceOf(alice));
        vm.assume(transferAmount < approveAmount);
        CallResult memory callResultApprove = _tryAliceApprove(bob, approveAmount);
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice failed to approve Bob.");
        assertFail(
            _tryBobTransferFrom(alice, carol, transferAmount),
            "Bob was able to transferFrom Alice more than Alice's balance."
        );
    }
}
