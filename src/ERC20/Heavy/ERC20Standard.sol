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
     * balanceOf() mandatory checks.
     *
     *
     */

    /// @notice A successful `balanceOf(account)` call MUST return balance of `account` correctly after two dummy users' balances are initialized.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf(account)` call does NOT return balance of `account` correctly after two dummy users' balances are initialized.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testUserBalanceInitialized(address user, uint256 balance)
        external
        initializeStateOneUserGeneralAddress(user, balance)
        isNotZeroAddress(user)
    {
        assertEq(
            cut.balanceOf(user),
            balance,
            "The value of balanceOf(user) does not equate the amount of tokens given to him."
        );
    }

    /**
     *
     *
     * transfer() mandatory checks.
     *
     *
     */

    /// @notice A successful `transfer` call of zero amount to another account MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to another account is NOT be possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToOthersPossible(address tokenSender, uint256 balance, address tokenReceiver)
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        isNotZeroAddress(tokenReceiver)
        unique2Addresses(tokenSender, tokenReceiver)
    {
        assertSuccess(
            _tryCustomerTransfer(tokenSender, tokenReceiver, 0),
            "A user failed to transfer zero amount to another user."
        );
    }

    /// @notice A successful `transfer` call of zero amount to another account MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to another account does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, event
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToOthersEmitsEvent(address tokenSender, uint256 balance, address tokenReceiver)
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        isNotZeroAddress(tokenReceiver)
        unique2Addresses(tokenSender, tokenReceiver)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSender, tokenReceiver, 0);
        _tryCustomerTransfer(tokenSender, tokenReceiver, 0);
    }

    /// @notice A successful `transfer` call of zero amount to self MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to self is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToSelfPossible(address user, uint256 balance)
        external
        initializeStateOneUserGeneralAddress(user, balance)
    {
        assertSuccess(_tryCustomerTransfer(user, user, 0), "User failed to transfer zero amount to self.");
    }

    /// @notice A successful `transfer` call of zero amount to self MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of zero amount to self does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, event
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToSelfEmitsEvent(address user, uint256 balance)
        external
        initializeStateOneUserGeneralAddress(user, balance)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(user, user, 0);
        _tryCustomerTransfer(user, user, 0);
    }

    /// @notice A successful `transfer` call of positive amount MUST emit the Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transfer` call of positive amount does NOT emit the Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, event
    /// @custom:ercx-concerned-function transfer
    function testPositiveTransferEventEmission(
        uint256 amount,
        address tokenSender,
        uint256 balanceSender,
        address tokenReceiver,
        uint256 balanceReceiver
    ) external initializeStateTwoUsersGeneralAddresses(tokenSender, balanceSender, tokenReceiver, balanceReceiver) {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(tokenSender));
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSender, tokenReceiver, amount);
        _tryCustomerTransfer(tokenSender, tokenReceiver, amount);
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
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to different accounts, does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherEmitsEvent(
        address transferInitiator,
        address tokenSender,
        uint256 balance,
        address tokenReceiver
    )
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        unique3Addresses(transferInitiator, tokenSender, tokenReceiver)
        isNotZeroAddress(transferInitiator)
        isNotZeroAddress(tokenReceiver)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSender, tokenReceiver, 0);
        _tryCustomerTransferFrom(transferInitiator, tokenSender, tokenReceiver, 0);
    }

    /// @notice A successful `transferFrom` of zero amount by any user other than the tokenSender, from and to the same address, MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherToSameAccountEmitsEvent(
        address transferInitiator,
        address tokenSenderReceiver,
        uint256 balance
    )
        external
        initializeStateOneUserGeneralAddress(tokenSenderReceiver, balance)
        unique2Addresses(transferInitiator, tokenSenderReceiver)
        isNotZeroAddress(transferInitiator)
        isNotZeroAddress(tokenSenderReceiver)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSenderReceiver, tokenSenderReceiver, 0);
        _tryCustomerTransferFrom(transferInitiator, tokenSenderReceiver, tokenSenderReceiver, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself to herself MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfToSelfEmitsEvent(address tokenSenderReceiver, uint256 balance)
        external
        initializeStateOneUserGeneralAddress(tokenSenderReceiver, balance)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSenderReceiver, tokenSenderReceiver, 0);
        _tryCustomerTransferFrom(tokenSenderReceiver, tokenSenderReceiver, tokenSenderReceiver, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself to someone MUST emit a Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself does NOT emit a Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount, event
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfToSomeoneEmitsEvent(address tokenSender, uint256 balance, address tokenReceiver)
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        unique2Addresses(tokenSender, tokenReceiver)
        isNotZeroAddress(tokenReceiver)
    {
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSender, tokenReceiver, 0);
        _tryCustomerTransferFrom(tokenSender, tokenSender, tokenReceiver, 0);
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender MUST be possible, from and to the same account.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to the same account, is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherFromAndToSameAccountPossible(
        address transferInitiator,
        address tokenSenderReceiver,
        uint256 balance
    )
        external
        initializeStateOneUserGeneralAddress(tokenSenderReceiver, balance)
        unique2Addresses(transferInitiator, tokenSenderReceiver)
        isNotZeroAddress(transferInitiator)
        isNotZeroAddress(tokenSenderReceiver)
    {
        assertSuccess(
            _tryCustomerTransferFrom(transferInitiator, tokenSenderReceiver, tokenSenderReceiver, 0),
            "A user failed to transferFrom zero amount from an account to the same account."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender MUST be possible, from and to different accounts.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender, from and to different accounts, is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherPossibleFromAndToDifferentAccounts(
        address transferInitiator,
        address tokenSender,
        uint256 balance,
        address tokenReceiver
    )
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        unique3Addresses(transferInitiator, tokenSender, tokenReceiver)
        isNotZeroAddress(transferInitiator)
        isNotZeroAddress(tokenReceiver)
    {
        assertSuccess(
            _tryCustomerTransferFrom(transferInitiator, tokenSender, tokenReceiver, 0),
            "A user failed to transferFrom zero amount from an account to another account."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by any user other than the tokenSender to the tokenSender MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by any user other than the tokenSender to the tokenSender is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromByOtherToSelfPossible(address user, uint256 balance, address transferInitiator)
        external
        initializeStateOneUserGeneralAddress(user, balance)
        isNotZeroAddress(transferInitiator)
        unique2Addresses(transferInitiator, user)
    {
        assertSuccess(
            _tryCustomerTransferFrom(transferInitiator, user, user, 0),
            "A user failed to transferFrom zero amount from some other account to this other account."
        );
    }

    /// @notice A successful `transferFrom` call of zero amount by the tokenSender herself MUST be possible.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of zero amount by the tokenSender herself is NOT possible.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromBySelfPossible(address tokenSender, uint256 balance, address tokenReceiver)
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        isNotZeroAddress(tokenReceiver)
    {
        assertSuccess(
            _tryCustomerTransferFrom(tokenSender, tokenSender, tokenReceiver, 0),
            "A user failed to transferFrom zero amount from her account to another user."
        );
    }

    /// @notice A successful `transferFrom` call of positive amount MUST emit Transfer event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` call of positive amount does NOT emit Transfer event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, event
    /// @custom:ercx-concerned-function transferFrom
    function testPositiveTransferFromEventEmission(
        uint256 amount,
        address tokenSender,
        uint256 balance,
        address transferInitiator,
        address tokenReceiver
    )
        external
        initializeStateOneUserGeneralAddress(tokenSender, balance)
        isNotZeroAddress(transferInitiator)
        isNotZeroAddress(tokenReceiver)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= balance);
        CallResult memory callResultApprove = _tryCustomerApprove(tokenSender, transferInitiator, amount);
        conditionalSkip(
            !callResultApprove.success, "Inconclusive test: tokenSender failed to approve transferInitiator."
        );
        vm.expectEmit(true, true, true, true);
        emit Transfer(tokenSender, tokenReceiver, amount);
        CallResult memory callResultTransferFrom =
            _tryCustomerTransferFrom(transferInitiator, tokenSender, tokenReceiver, amount);
        conditionalSkip(
            !callResultTransferFrom.success,
            "Inconclusive test: transferInitiator failed to call `transferFrom` from tokenSender to tokenReceiver."
        );
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
    function testZeroApprovalEventEmission(address tokenApprover, address tokenApprovee)
        external
        isNotZeroAddress(tokenApprover)
        isNotZeroAddress(tokenApprovee)
    {
        vm.expectEmit(true, true, true, true);
        emit Approval(tokenApprover, tokenApprovee, 0);
        _tryCustomerApprove(tokenApprover, tokenApprovee, 0);
    }

    /// @notice A successful `approve` call of positive amount MUST emit the `Approval` event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `approve` call of positive amount does NOT emit the `Approval` event correctly.
    /// @custom:ercx-categories approval, event
    /// @custom:ercx-concerned-function approve, Approval
    function testPositiveApprovalEventEmission(address tokenApprover, address tokenApprovee, uint256 amount)
        external
        isNotZeroAddress(tokenApprover)
        isNotZeroAddress(tokenApprovee)
    {
        vm.assume(amount > 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(tokenApprover, tokenApprovee, amount);
        _tryCustomerApprove(tokenApprover, tokenApprovee, amount);
    }

    /// @notice After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, zero amount MUST be transferable
    /// by tokenApprovee via a `transferFrom` call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover approves a tokenApprovee some positive amount via an `approve` call, zero amount is NOT transferable
    /// by tokenApprovee via a `transferFrom` call, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories approval, zero amount, transferFrom, balance
    /// @custom:ercx-concerned-function approve, transferFrom
    function testPositiveApproveAllowsZeroTransferFrom(
        address tokenApprover,
        address tokenApprovee,
        address tokenReceiver,
        uint256 approvedAmount,
        uint256 balance
    ) external initializeStateOneUserGeneralAddress(tokenApprover, balance) {
        internalTestPositiveApproveAllowsTransferFrom(
            tokenApprover, tokenApprovee, tokenReceiver, approvedAmount, 0, balance
        );
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
        address tokenApprover,
        address tokenApprovee,
        address tokenReceiver,
        uint256 approvedAmount,
        uint256 transferAmount,
        uint256 balance
    ) external {
        vm.assume(transferAmount > 0);
        internalTestPositiveApproveAllowsTransferFrom(
            tokenApprover, tokenApprovee, tokenReceiver, approvedAmount, transferAmount, balance
        );
    }

    /// @notice Internal property test: After a tokenApprover approves a tokenApprovee some positive amount, any amount up to
    /// the said amount MUST be transferable by tokenApprovee, provided a sufficient balance of tokenApprover.
    function internalTestPositiveApproveAllowsTransferFrom(
        address tokenApprover,
        address tokenApprovee,
        address tokenReceiver,
        uint256 approveAmount,
        uint256 transferAmount,
        uint256 balance
    )
        internal
        initializeStateOneUserGeneralAddress(tokenApprover, balance)
        isNotZeroAddress(tokenApprovee)
        isNotZeroAddress(tokenReceiver)
    {
        vm.assume(approveAmount > 0);
        vm.assume(transferAmount <= approveAmount);
        vm.assume(balance >= transferAmount);

        CallResult memory callApprove = _tryCustomerApprove(tokenApprover, tokenApprovee, approveAmount);
        conditionalSkip(!callApprove.success, "Inconclusive test: tokenApprover failed to approve tokenApprovee.");
        assertSuccess(
            _tryCustomerTransferFrom(tokenApprovee, tokenApprover, tokenReceiver, transferAmount),
            "The token approvee failed to transferFrom from the token approver to some other account account."
        );
    }

    /**
     *
     *
     * allowance() mandatory checks.
     *
     *
     */

    /// @notice Zero approved amount MUST be reflected in the allowance correctly after a tokenApprover approves a tokenApprovee for zero amount.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Zero approved amount is NOT reflected in the allowance correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: approve.
    /// @custom:ercx-categories approval, allowance, zero amount
    /// @custom:ercx-concerned-function approve
    function testZeroApproveLeadsToAllowance(address tokenApprover, address tokenApprovee) external {
        _internalTestApproveLeadsToAllowance(tokenApprover, tokenApprovee, 0);
    }

    /// @notice Positive approved amount MUST be reflected in the allowance correctly after a tokenApprover approves a tokenApprovee for a positive amount.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Positive approved amount is NOT reflected in the allowance correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: approve.
    /// @custom:ercx-categories approval, allowance
    /// @custom:ercx-concerned-function approve
    function testPositiveApproveLeadsToAllowance(address tokenApprover, address tokenApprovee, uint256 amount)
        external
    {
        vm.assume(amount > 0);
        _internalTestApproveLeadsToAllowance(tokenApprover, tokenApprovee, amount);
    }

    /// @notice Internal property test: An arbitrary approved `amount` MUST be reflected in the allowance.
    function _internalTestApproveLeadsToAllowance(address tokenApprover, address tokenApprovee, uint256 amount)
        internal
    {
        CallResult memory callApprove = _tryCustomerApprove(tokenApprover, tokenApprovee, amount);
        conditionalSkip(!callApprove.success, "Inconclusive test: tokenApprover failed to approve tokenApprovee.");
        assertEq(
            cut.allowance(tokenApprover, tokenApprovee),
            amount,
            "The value of allowance(tokenApprover, tokenApprovee) does not equate the value approved by tokenApprover to tokenApprovee."
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
}
