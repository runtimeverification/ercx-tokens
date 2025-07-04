pragma solidity >=0.6.2 <0.9.0;

import "../ERC20Abstract.sol";

/// @notice Abstract contract that consists of the security properties, including desirable properties for the sane functioning of the token and properties
/// of add-on functions commonly created and used by ERC20 developers, such as increase/decreaseAllowance.
abstract contract ERC20Security is ERC20Abstract {
    using stdStorage for StdStorage;

    /**
     *
     *
     * Dealing tokens to dummy users checks
     *
     *
     */

    /// @notice It is possible to deal the intended amount of tokens to dummy users for interacting with the contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback There is an issue when dealing the intended amount of tokens to dummy users for interacting with the contract.
    /// This could be due to issues with
    /// (a) calling of the `transfer` function by the top token holder, or
    /// (b) the presence of fees from the `transfer` function.
    /// @custom:ercx-categories transfer, fees
    /// @custom:ercx-concerned-function transfer
    function testDealIntendedTokensToDummyUsers(uint256 aliceBalance, uint256 bobBalance) public {
        vm.assume(aliceBalance <= MAX_UINT256 - bobBalance);
        vm.assume(cut.totalSupply() <= MAX_UINT256 - aliceBalance - bobBalance);
        // Give aliceAssetsBalance tokens to Alice
        (bool dealAlice, string memory reasonAlice) = _dealERC20Token(address(cut), alice, aliceBalance);
        assertTrue(dealAlice, reasonAlice);
        // Give bobAssetsBalance tokens to Bob
        (bool dealBob, string memory reasonBob) = _dealERC20Token(address(cut), bob, bobBalance);
        assertTrue(dealBob, reasonBob);
        // Check that the asset balances of Alice and Bob are correct
        assertEq(cut.balanceOf(alice), aliceBalance, "Failure to deal the intended number of tokens to Alice.");
        assertEq(cut.balanceOf(bob), bobBalance, "Failure to deal the intended number of tokens to Bob.");
    }

    /**
     *
     */
    /**
     *
     */
    /* Tests related to desirable properties. */
    /**
     *
     */
    /**
     *
     */

    /**
     *
     *
     * Calling of balanceOf() checks.
     *
     *
     */

    /// @notice A `msg.sender` SHOULD be able to retrieve his/her own balance.
    /// @dev The test just consists in executing the balanceOf function and checking that it does not yield an error, from the msg.sender.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `msg.sender` CANNOT retrieve his/her own balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testBalanceOfCaller(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.startPrank(alice);
        cut.balanceOf(alice);
        vm.stopPrank();
    }

    /// @notice A `msg.sender` SHOULD be able to retrieve balance of an address different from his/hers.
    /// @dev The test just consists in executing the balanceOf function and checking that it does not yield an error, from a different address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `msg.sender` CANNOT retrieve balance of an address different from his/hers.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testBalanceOfNonCaller(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.startPrank(bob);
        cut.balanceOf(alice);
        vm.stopPrank();
    }

    /**
     *
     *
     * Zero address checks.
     *
     *
     */

    /// @notice The zero address SHOULD NOT have any token from the contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The zero address HAS some token/s from the contract.
    /// @custom:ercx-categories zero address, balance
    function testAddressZeroHasNoToken() external {
        assertEq(cut.balanceOf(address(0x0)), 0, "The balance of the zero address is not equal to 0.");
    }

    /// @notice A `transfer` call of zero amount to the zero address SHOULD revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transfer` call of zero amount to the zero address DOES NOT revert.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, zero address
    /// @custom:ercx-concerned-function transfer
    function testZeroTransferToZeroShouldRevert(uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        assertFail(_tryAliceTransfer(address(0x0), 0));
    }

    /// @notice A `transfer` call of any positive amount to the zero address SHOULD revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transfer` call of a positive amount to the zero address DOES NOT revert.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function transfer
    function testPositiveTransferToZeroShouldRevert(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        assertFail(_tryAliceTransfer(address(0x0), amount), "Alice could transfer some tokens to the zero address.");
    }

    /// @notice A `transferFrom` call of zero amount to the zero address SHOULD revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom` call of zero amount to the zero address DOES NOT revert.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, zero amount, zero address
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTransferFromToZeroShouldRevert(uint256 balance1, uint256 balance2) external {
        _internalTestTransferFromToZeroShouldRevert(0, balance1, balance2);
    }

    /// @notice A `transferFrom` call of any positive amount to the zero address SHOULD revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom` call of a positive amount to the zero address DOES NOT revert.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, zero address
    /// @custom:ercx-concerned-function transferFrom
    function testPositiveTransferFromToZeroShouldRevert(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        _internalTestTransferFromToZeroShouldRevert(amount, balance1, balance2);
    }

    function _internalTestTransferFromToZeroShouldRevert(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount <= cut.balanceOf(alice));

        CallResult memory callResultApprove = _tryAliceApprove(bob, amount);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice was not able to approve Bob.");
        assertFail(
            _tryBobTransferFrom(alice, address(0x0), amount), "Bob was able to transfer from Alice to the zero address."
        );
    }

    /// @notice A `transfer` call of any positive amount SHOULD revert if the tokenSender is the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transfer` call of some positive amount DOES NOT revert if the tokenSender is the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function transfer
    function testZeroAddressCannotTransferPositiveAmount(uint256 amount) external {
        vm.assume(amount > 0);
        vm.assume(amount < MAX_UINT256 - cut.totalSupply());
        _dealERC20Token(address(cut), address(0x0), amount);
        assertFail(
            _tryCustomerTransfer(address(0x0), alice, amount),
            "A transfer with the zero address as token sender was possible."
        );
    }

    /// @notice A `approve` call of any positive amount SHOULD revert if the tokenSender is the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `approve` call of some positive amount DOES NOT revert if the tokenSender is the zero address.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve
    function testZeroAddressCannotApprovePositiveAmount(uint256 approveAmount) external {
        vm.assume(approveAmount > 0);
        assertFail(
            _tryCustomerApprove(address(0x0), alice, approveAmount),
            "An approve with the zero address as token sender was possible."
        );
    }

    /// @notice A successful call of `approve` of any amount to the zero address SHOULD NOT be allowed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful call of `approve` of an amount to the zero address IS allowed.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve
    function testCannotApprovePositiveAmountToZeroAddress(uint256 approveAmount) external {
        vm.assume(approveAmount > 0);
        assertFail(_tryAliceApprove(address(0x0), approveAmount), "Alice could approve the zero address.");
    }

    /**
     *
     *
     * Self transfer checks.
     *
     *
     */

    /// @notice Self `transfer` call of zero amount is ALLOWED and SHOULD NOT modify the balance.
    /// @dev The test fails if the transfer is reverted or if the transfer is accepted and results in a modified balance of the account initiating the call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `transfer` call of zero amount is NOT ALLOWED or it MODIFIES the balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, balance
    /// @custom:ercx-concerned-function transfer
    function testZeroSelfTransfer(uint256 balance1, uint256 balance2) external {
        _internalTestSelfTransfer(0, balance1, balance2);
    }

    /// @notice Self `transfer` call of positive amount is ALLOWED and SHOULD NOT modify the balance.
    /// @dev The test fails if the transfer is reverted or if the transfer is accepted and results in a modified balance of the account initiating the call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `transfer` call of positive amount is NOT ALLOWED or it MODIFIED the balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transfer
    function testPositiveSelfTransfer(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        _internalTestSelfTransfer(amount, balance1, balance2);
    }

    function _internalTestSelfTransfer(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        uint256 aliceBalance = cut.balanceOf(alice);
        vm.assume(aliceBalance >= amount);

        assertSuccess(_tryAliceTransfer(alice, amount));
        assertEq(aliceBalance, cut.balanceOf(alice), "Alice's balance was unexpectedly modified after a self transfer.");
    }

    /**
     *
     *
     * Total balance transfer checks.
     *
     *
     */

    /// @notice A `msg.sender` CAN call `transfer` of her total balance of zero to a tokenReceiver and the balances are not modified.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `msg.sender` CANNOT call `transfer` of her total balance amount of zero to a tokenReceiver or the balances were modified.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount, balance
    /// @custom:ercx-concerned-function transfer
    function testZeroTotalTransferToOther(uint256 balance2) external {
        internalTestTotalTransferToOther(0, balance2);
    }

    /// @notice A `msg.sender` CAN call `transfer` of her total balance amount to a tokenReceiver and the balances are modified accordingly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `msg.sender` CANNOT call `transfer` of her total balance amount to a tokenReceiver or the balances were not modified as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance, transfer
    /// @custom:ercx-concerned-function transfer
    function testPositiveTotalTransferToOther(uint256 balance1, uint256 balance2) external {
        vm.assume(balance1 > 0);
        internalTestTotalTransferToOther(balance1, balance2);
    }

    function internalTestTotalTransferToOther(uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 carolInitialBalance = cut.balanceOf(carol);
        assertSuccess(_tryAliceTransfer(carol, aliceInitialBalance));
        assertEq(cut.balanceOf(alice), 0, "Alice still has some tokens even after transferring all her tokens.");
        assertEq(
            cut.balanceOf(carol),
            carolInitialBalance + aliceInitialBalance,
            "Carol's balance has not been augmented by the amount of tokens sent to her."
        );
    }

    /// @notice A tokenReceiver CAN call `transferFrom` of the tokenSender's total balance amount of zero.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A tokenReceiver CANNOT call `transferFrom` of the tokenSender's total balance amount of zero.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, zero amount, balance
    /// @custom:ercx-concerned-function transferFrom
    function testZeroTotalTransferFromToOther(uint256 balance2) external {
        _internalTestTotalTransferFromToOther(0, balance2);
    }

    /// @notice A tokenReceiver CAN call `transferFrom` of the tokenSender's total balance amount given that tokenSender has approved that.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A tokenReceiver CANNOT call `transferFrom` of the tokenSender's total balance amount even though tokenSender has approved that.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories approval, transferFrom, balance
    /// @custom:ercx-concerned-function transferFrom
    function testPositiveTotalTransferFromToOther(uint256 balance1, uint256 balance2) external {
        vm.assume(balance1 > 0);
        _internalTestTotalTransferFromToOther(balance1, balance2);
    }

    function _internalTestTotalTransferFromToOther(uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 carolInitialBalance = cut.balanceOf(carol);

        CallResult memory callResultApprove = _tryAliceApprove(bob, aliceInitialBalance);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobTransferFrom(alice, carol, aliceInitialBalance));
        assertEq(cut.balanceOf(alice), 0, "Alice still has some tokens even after transferring all her tokens.");
        assertEq(
            cut.balanceOf(carol),
            carolInitialBalance + aliceInitialBalance,
            "Carol's balance has not been augmented by the amount of tokens sent to her."
        );
    }

    /**
     *
     *
     * Multiple transfers checks.
     *
     *
     */

    /// @notice Multiple calls of `transfer` of zero amount are ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Multiple calls of `transfer` of zero amount are NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, zero amount
    /// @custom:ercx-concerned-function transfer
    function testZeroMultipleTransfer(uint256 balance1, uint256 balance2) external {
        _internalTestMultipleTransfer(0, balance1, balance2);
    }

    /// @notice  Multiple `transfer` calls of positive amounts are ALLOWED given that the sum of the transferred amounts is less than or equal to the tokenSender's balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Multiple `transfer` calls of positive amounts are NOT ALLOWED even though the sum of the transferred amounts is less than or equal to the tokenSender's balance.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transfer
    function testPositiveMultipleTransfer(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        _internalTestMultipleTransfer(amount, balance1, balance2);
    }

    function _internalTestMultipleTransfer(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice) / 3);
        assertSuccess(_tryAliceTransfer(bob, amount), "Alice could not transfer to Bob.");
        assertSuccess(_tryAliceTransfer(carol, amount), "Alice could not transfer to Carol.");
        assertSuccess(_tryAliceTransfer(address(this), amount), "Alice could not transfer some tokens.");
    }

    /// @notice Multiple calls of `transferFrom` of zero amount are ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Multiple calls of `transferFrom` of zero amount are NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, zero amount
    /// @custom:ercx-concerned-function transferFrom
    function testZeroMultipleTransferFrom(uint256 balance1, uint256 balance2) external {
        _internalTestMultipleTransferFrom(0, balance1, balance2);
    }

    /// @notice Multiple `transferFrom` calls of positive amounts are ALLOWED given that the sum of the transferred amounts is less than or equal
    /// to the tokenSender's balance and approvals are given by the tokenSender.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Multiple `transferFrom` calls of positive amounts are NOT ALLOWED even though the sum of the transferred amounts is
    /// less than or equal to the tokenSender's balance and approvals are given by the tokenSender.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve.
    /// @custom:ercx-categories transferFrom, balance
    /// @custom:ercx-concerned-function transferFrom
    function testPositiveMultipleTransferFrom(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        _internalTestMultipleTransferFrom(amount, balance1, balance2);
    }

    function _internalTestMultipleTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice) / 3);
        CallResult memory callResultApprove = _tryAliceApprove(bob, cut.balanceOf(alice));
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobTransferFrom(alice, bob, amount), "Alice could not transfer to Bob.");
        assertSuccess(_tryBobTransferFrom(alice, carol, amount), "Alice could not transfer to Carol.");
        assertSuccess(_tryBobTransferFrom(alice, address(this), amount), "Alice could not transfer some tokens.");
    }

    /// @notice Multiple calls of `transferFrom` SHOULD NOT be allowed once allowance reach zero even if the tokenSender's balance is more than the allowance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Multiple calls of `transferFrom` ARE allowed even though the allowance has reached zero.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, allowance, balance
    /// @custom:ercx-concerned-function transferFrom
    function testMultipleTransferFromCannotExceedAllowance(
        uint256 amount1,
        uint256 amount2,
        uint256 balance1,
        uint256 balance2
    ) external initializeStateTwoUsers(balance1, balance2) {
        vm.assume(amount1 > 0);
        vm.assume(amount1 < cut.balanceOf(alice) / 2);
        vm.assume(amount2 > 0);
        // To make sure that Alice still have enough tokens in her balance to transferFrom
        vm.assume(amount2 <= amount1);

        CallResult memory callResultApprove = _tryAliceApprove(bob, amount1);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, bob, amount1);
        // Skip the test if the transferFrom call fails
        conditionalSkip(
            !callResultTransferFrom.success, "Inconclusive test: Bob could not transferFrom his initial allowance."
        );
        assertFail(
            _tryBobTransferFrom(alice, carol, amount2),
            "Bob could transfer from Alice even if his allowance reached zero."
        );
    }

    /**
     *
     *
     * approve desirable checks.
     *
     *
     */

    /// @notice Consecutive calls of `approve` function of zero-to-zero amounts CAN be called
    /// and the allowance is set to the right amount after the second call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Consecutive calls of `approve` function of zero-to-zero amounts CANNOT be called
    /// OR the allowance is set to the wrong amount after the second call.
    /// @custom:ercx-categories approval, zero amount
    /// @custom:ercx-concerned-function approve
    function testCorrectOverwriteApproveZeroToZero() external {
        // to make sure the allowance of Alice for bob is reset to 0
        if (cut.allowance(alice, bob) != 0) {
            assertSuccess(_tryAliceApprove(bob, 0));
        }
        // first call of approve function of zero amount
        assertSuccess(_tryAliceApprove(bob, 0), "Alice could not approve Bob for zero amount a first time.");
        // second call of approve function of zero amount
        assertSuccess(_tryAliceApprove(bob, 0), "Alice could not approve Bob for zero amount a second time.");
        assertEq(
            cut.allowance(alice, bob),
            0,
            "Allowance is not set to the right amount after the second `approve` is called."
        );
    }

    /// @notice Consecutive calls of `approve` function of zero-to-positive amounts CAN be called
    /// and the allowance is set to the right amount after the second call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Consecutive calls of `approve` function of zero-to-positive amounts CANNOT be called
    /// OR the allowance is set to the wrong amount after the second call.
    /// @custom:ercx-categories approval, zero amount
    /// @custom:ercx-concerned-function approve
    function testCorrectOverwriteApproveZeroToPositive(uint256 approveAmount2) external {
        // to make sure the allowance of Alice for bob is reset to 0
        if (cut.allowance(alice, bob) != 0) {
            assertSuccess(_tryAliceApprove(bob, 0));
        }
        vm.assume(approveAmount2 > 0);
        // first call of approve function of zero amount
        assertSuccess(_tryAliceApprove(bob, 0), "Alice could not approve Bob for zero amount.");
        // second call of approve function of positive amount
        assertSuccess(_tryAliceApprove(bob, approveAmount2), "Alice could not approve Bob for some positive amount.");
        assertEq(
            cut.allowance(alice, bob),
            approveAmount2,
            "Allowance is not set to the right amount after the second `approve` is called."
        );
    }

    /// @notice Consecutive calls of `approve` function of positive-to-zero amounts CAN be called
    /// and the allowance is set to the right amount after the second call.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Consecutive calls of `approve` function of positive-to-zero amounts CANNOT be called
    /// OR the allowance is set to the wrong amount after the second call.
    /// @custom:ercx-categories approval, zero amount
    /// @custom:ercx-concerned-function approve
    function testCorrectOverwriteApprovePositiveToZero(uint256 approveAmount1) external {
        // to make sure the allowance of Alice for bob is reset to 0
        if (cut.allowance(alice, bob) != 0) {
            assertSuccess(_tryAliceApprove(bob, 0));
        }
        vm.assume(approveAmount1 > 0);
        // first call of approve function of positive amount
        assertSuccess(_tryAliceApprove(bob, approveAmount1), "Alice could not approve Bob for some positive amount.");
        // second call of approve function of zero amount
        assertSuccess(_tryAliceApprove(bob, 0), "Alice could not approve Bob for zero amount.");
        assertEq(
            cut.allowance(alice, bob),
            0,
            "Allowance is not set to the right amount after the second `approve` is called."
        );
    }

    /// @notice If consecutive calls of `approve` function of positive-to-positive amounts can be called,
    /// then the allowance is set to the right amount after the second call.
    /// @custom:ercx-expected optional
    /// @custom:ercx-feedback Consecutive calls of `approve` function of positive-to-positive amounts can be called
    /// but the allowance is set to the wrong amount after the second call.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve
    function testCorrectOverwriteApprovePositiveToPositive(uint256 approveAmount1, uint256 approveAmount2) external {
        // to make sure the allowance of Alice for bob is reset to 0
        if (cut.allowance(alice, bob) != 0) {
            assertSuccess(_tryAliceApprove(bob, 0));
        }
        vm.assume(approveAmount1 > 0);
        vm.assume(approveAmount2 > 0);
        // first call of approve function of positive amount
        assertSuccess(_tryAliceApprove(bob, approveAmount1));
        // second call of approve function of another positive amount
        CallResult memory secondApproveResult = _tryAliceApprove(bob, approveAmount2);
        if (secondApproveResult.success && secondApproveResult.optionalReturn != OptionalReturn.RETURN_FALSE) {
            assertEq(
                cut.allowance(alice, bob),
                approveAmount2,
                "Alice's allowance to Bob is not set to the right amount after the second `approve` is called."
            );
        } else {
            emit log("The second `approve` call of positive value is unsuccessful");
        }
    }

    /**
     *
     *
     * Self approval checks.
     *
     *
     */

    /// @notice Self approval of zero amount is ALLOWED and the allowance is correctly updated.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self approval of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval, zero amount
    /// @custom:ercx-concerned-function approve
    function testZeroSelfApprove(uint256 balance1, uint256 balance2) external {
        internalTestSelfApprove(0, balance1, balance2);
    }

    /// @notice Self approval of positive amount is ALLOWED and the allowance is correctly updated.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self approval of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve
    function testPositiveSelfApprove(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        internalTestSelfApprove(amount, balance1, balance2);
    }

    function internalTestSelfApprove(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice));
        // Alice self approves
        assertSuccess(_tryAliceApprove(alice, amount), "Alice could not self approve.");
        assertEq(cut.allowance(alice, alice), amount, "Alice's allowance to herself has not the expected value.");
    }

    /// @notice Self approval and call of `transferFrom` from its own account of zero amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self approval and call of `transferFrom` from its own account of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval, transferFrom, zero amount
    /// @custom:ercx-concerned-function approve, transferFrom
    function testZeroSelfApproveTransferFrom(uint256 balance1, uint256 balance2) external {
        _internalTestSelfApproveTransferFrom(0, balance1, balance2);
    }

    /// @notice Self approval and call of `transferFrom` from its own account of positive amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self approval and call of `transferFrom` from its own account of positive amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories approval, transferFrom
    /// @custom:ercx-concerned-function approve, transferFrom
    function testPositiveSelfApproveTransferFrom(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        _internalTestSelfApproveTransferFrom(amount, balance1, balance2);
    }

    function _internalTestSelfApproveTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice));
        // Alice self approves
        assertSuccess(_tryAliceApprove(alice, amount), "Alice could not self approve.");
        // Alice transfers using transferFrom
        assertSuccess(
            _tryAliceTransferFrom(alice, bob, amount),
            "Alice could not transfer from her account after self approving herself."
        );
    }

    /**
     *
     *
     * Fee-taking checks.
     *
     *
     */

    /// @notice The `transfer` function DOES NOT take fees at test execution time.
    /// @dev This ensures that the token is not deflationary via transfer.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `transfer` function TAKES fees at test execution time.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: transfer.
    /// @custom:ercx-categories transfer, fees
    /// @custom:ercx-concerned-function transfer
    function testFeeTakingTransferPresent(uint256 amount, uint256 balance1, uint256 balance2) external {
        internalFeeTakingTransfer(amount, balance1, balance2);
    }

    /// @notice The `transfer` function DOES NOT have the potential to take fees.
    /// @dev This ensures that the token is not deflationary via transfer.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `transfer` function HAS the potential to take fees.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: transfer.
    /// @custom:ercx-categories transfer, fees
    /// @custom:ercx-concerned-function transfer
    function testFeeTakingTransferPotential(
        uint256[2] memory feeAmounts,
        uint256 amount,
        uint256 balance1,
        uint256 balance2
    ) external initializeFees(feeAmounts) {
        internalFeeTakingTransfer(amount, balance1, balance2);
    }

    /// @notice Internal property test: transfer does not take fees.
    function internalFeeTakingTransfer(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(cut.balanceOf(alice) >= amount);
        uint256 preAliceBalance = cut.balanceOf(alice);
        uint256 preBobBalance = cut.balanceOf(bob);

        CallResult memory callResultTransfer = _tryAliceTransfer(bob, amount);
        // If the `transfer` call succeeds, check if the balances change as expected.
        // Otherwise, it may be due to insufficient Alice's balance to make the `transfer` call.
        if (callResultTransfer.success) {
            assertEq(
                preAliceBalance - amount,
                cut.balanceOf(alice),
                "Alice's balance was not decreased by the amount transferred from her."
            );
            assertEq(
                preBobBalance + amount,
                cut.balanceOf(bob),
                "Bob's balance was not increased by the amount transferred to him."
            );
        }
    }

    /// @notice The `transferFrom` function DOES NOT take fees at test execution time.
    /// @dev This ensures that the token is not deflationary via transferFrom.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `transfer` function TAKES fees at test execution time.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, fees
    /// @custom:ercx-concerned-function transferFrom
    function testFeeTakingTransferFromPresent(uint256 amount, uint256 balance1, uint256 balance2) external {
        _internalFeeTakingTransferFrom(amount, balance1, balance2);
    }

    /// @notice The `transferFrom` function DOES NOT have the potential to take fees.
    /// @dev This ensures that the token is not deflationary via transfer.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `transferFrom` function HAS the potential to take fees.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, fees
    /// @custom:ercx-concerned-function transferFrom
    function testFeeTakingTransferFromPotential(
        uint256[2] memory feeAmounts,
        uint256 amount,
        uint256 balance1,
        uint256 balance2
    ) external initializeFees(feeAmounts) {
        _internalFeeTakingTransferFrom(amount, balance1, balance2);
    }

    /// @notice Internal property test: transferFrom does not take fees.
    function _internalFeeTakingTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(cut.balanceOf(alice) >= amount);
        uint256 preAliceBalance = cut.balanceOf(alice);
        uint256 preBobBalance = cut.balanceOf(bob);

        CallResult memory callResultApprove = _tryAliceApprove(bob, amount);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, bob, amount);
        // If the `transferFrom` call succeeds, check if the balances change as expected.
        // Otherwise, it may be due to insufficient Alice's balance to make the `transferFrom` call.
        if (callResultTransferFrom.success) {
            assertEq(
                preAliceBalance - amount,
                cut.balanceOf(alice),
                "Alice's balance was not decreased by the amount transferred from her."
            );
            assertEq(
                preBobBalance + amount,
                cut.balanceOf(bob),
                "Bob's balance was not increased by the amount transferred to him."
            );
        }
    }

    /// @notice Try to initialize possible fees in the contract
    /// @dev The goal of the modifier initializeFees is to assign random values to possible feeSynonyms
    /// (if they were found in the code) through fuzzing, continue with the function that the modifier
    /// is applied to (hence the _;), after which reset the values of feeSynonyms back to its original values.
    modifier initializeFees(uint256[2] memory feeAmounts) {
        string[2] memory feeSynonyms = ["basisPointsRate()", "maximumFee()"];
        bool[2] memory callSuccesses;
        bytes[2] memory feeDatas;

        // for each feeSynonym, initialize fee if the feeSynonym can be called
        for (uint8 i = 0; i < 2; i++) {
            string memory feeSynonym = feeSynonyms[i];
            uint256 feeAmount = feeAmounts[i];
            (bool callSuccess, bytes memory feeData) = address(cut).call(abi.encodeWithSignature(feeSynonym));
            if (callSuccess && feeData.length != 0) {
                stdstore.target(address(cut)).sig(feeSynonym).checked_write(feeAmount);
            }
            callSuccesses[i] = callSuccess;
            feeDatas[i] = feeData;
        }

        // rest of the function code
        _;

        // for each feeSynonym that has been initialized, revert back to its previous value
        for (uint8 i = 0; i < 2; i++) {
            bool callSuccess = callSuccesses[i];
            bytes memory feeData = feeDatas[i];
            string memory feeSynonym = feeSynonyms[i];
            if (callSuccess && feeData.length != 0) {
                uint256 previousFee = abi.decode(feeData, (uint256));
                stdstore.target(address(cut)).sig(feeSynonym).checked_write(previousFee);
            }
        }
    }

    /**
     *
     *
     * transfer/transferFrom desirable checks
     *
     *
     */

    /// @notice A successful call of `transfer` DOES NOT update the balance of users who are neither the tokenSender nor the tokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful call of `transfer` UPDATES the balance of users who are neither the tokenSender nor the tokenReceiver.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: transfer.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transfer
    function testTransferDoesNotUpdateOthersBalances(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        uint256 preDifferentIdBalance = cut.balanceOf(carol);
        CallResult memory callResultTransfer = _tryAliceTransfer(bob, amount);
        // Skip the test if the transfer call fails
        conditionalSkip(!callResultTransfer.success, "Inconclusive test: Transfer could not happen.");
        uint256 postDifferentIdBalance = cut.balanceOf(carol);
        assertEq(
            preDifferentIdBalance,
            postDifferentIdBalance,
            "Some user different from the tokenSender and tokenReceiver had her balance modified after a transfer."
        );
    }

    /// @notice A successful call of `transferFrom` DOES NOT update the balance of users who are neither the tokenSender nor the tokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful call of `transferFrom` UPDATES the balance of users who are neither the tokenSender nor the tokenReceiver.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, balance
    /// @custom:ercx-concerned-function transferFrom
    function testTransferFromDoesNotUpdateOthersBalances(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        uint256 preDifferentIdBalance = cut.balanceOf(carol);
        CallResult memory callResultApprove = _tryAliceApprove(bob, amount);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, bob, amount);
        // Skip the test if the transferFrom call fails
        conditionalSkip(
            !callResultTransferFrom.success,
            "Inconclusive test: Alice could not transfer to Bob via `transferFrom` call."
        );
        uint256 postDifferentIdBalance = cut.balanceOf(carol);
        assertEq(
            preDifferentIdBalance,
            postDifferentIdBalance,
            "Some user different from the tokenSender and tokenReceiver had her balance modified after a transferFrom."
        );
    }

    /// @notice The contract's `totalSupply` variable SHOULD NOT be altered after `transfer` is called.
    /// @dev The test only checks if the contract's totalSupply variable is altered after transfer is called,
    /// and not if the sum of all balances remains constant.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The contract's `totalSupply` variable IS altered after `transfer` is called.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: transfer.
    /// @custom:ercx-categories transfer, total supply
    /// @custom:ercx-concerned-function transfer
    function testTotalSupplyConstantAfterTransfer(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        uint256 preTotalSupply = cut.totalSupply();
        CallResult memory callResultTransfer = _tryAliceTransfer(bob, amount);
        // Skip the test if the transfer call fails
        conditionalSkip(!callResultTransfer.success, "Inconclusive test: Alice could not transfer.");
        uint256 postTotalSupply = cut.totalSupply();
        assertEq(preTotalSupply, postTotalSupply, "The total supply has changed after a transfer.");
    }

    /// @notice The contract's `totalSupply` variable SHOULD NOT be altered after `transferFrom` is called.
    /// @dev The test only checks if the contract's totalSupply variable is altered after transferFrom is called,
    /// and not if the sum of all balances remains constant.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The contract's `totalSupply` variable IS altered after `transferFrom` is called.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, total supply
    /// @custom:ercx-concerned-function transferFrom
    function testTotalSupplyConstantAfterTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        external
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        uint256 preTotalSupply = cut.totalSupply();
        CallResult memory callResultApprove = _tryAliceApprove(bob, amount);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob");
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, carol, amount);
        // Skip the test if the transferFrom call fails
        conditionalSkip(
            !callResultTransferFrom.success,
            "Inconclusive test: Bob could not transfer to Alice via a `transferFrom` call."
        );
        uint256 postTotalSupply = cut.totalSupply();
        assertEq(preTotalSupply, postTotalSupply, "The total supply has changed after a transferFrom.");
    }

    /// @notice A successful `transferFrom` of any positive amount MUST decrease the allowance of the tokenSender by the transferred amount.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `transferFrom` of any positive amount DOES NOT decrease the allowance of the tokenSender by the transferred amount.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transferFrom, allowance
    /// @custom:ercx-concerned-function transferFrom
    function testTransferFromDecreaseAllowanceAsExpected(uint256 amount, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= cut.balanceOf(alice));
        vm.assume(allowance >= amount);
        vm.assume(allowance < MAX_UINT256);
        CallResult memory callResultApprove = _tryAliceApprove(bob, allowance);
        // Skip the test if the approve call fails
        conditionalSkip(!callResultApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callResultTransferFrom = _tryBobTransferFrom(alice, carol, amount);
        // Skip the test if the transferFrom call fails
        conditionalSkip(
            !callResultTransferFrom.success,
            "Inconclusive test: Bob could not transfer to Alice via a `transferFrom` call."
        );
        assertEq(
            allowance - amount,
            cut.allowance(alice, bob),
            "The allowance of Alice to Bob was not decreased by the transferred amount between them."
        );
    }

    /**
     *
     */
    /**
     *
     */
    /* Tests related to addon functions. */
    /**
     *
     */
    /**
     *
     */

    /* Some events for logging purpose. */
    event CutContractFailure(string message, bytes returnData);
    event CutContractFailure(string message);

    /**
     *
     */
    /* Pausing checks. */
    /**
     *
     */

    /// @notice Transfer should not be possible when token is paused.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After pausing the token, a transfer could happen or the balance of the tokenSender or the tokenReceiver changed unexpectedely.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR updating the owner of the contract OR calling the following functions: pause.
    /// @custom:ercx-categories balance, transfer, pause
    /// @custom:ercx-concerned-function pause
    function testTransferAreNotPossibleWhenPaused(uint256 transferredAmount, uint256 initialBalanceAlice)
        external
        updateOwner
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 prevBalanceAlice = cut.balanceOf(alice);
        vm.assume(transferredAmount < prevBalanceAlice);
        vm.startPrank(contractOwner);
        CallResult memory callResultPause = _tryPause();
        // Skip the test if the pause call fails
        conditionalSkip(!callResultPause.success, "Inconclusive test: Failed to pause the contract.");
        assertFail(_tryAliceTransfer(bob, transferredAmount));
        assertEq(prevBalanceAlice, cut.balanceOf(alice), "Alice's balance has been modified unexpectedly.");
        assertEq(0, cut.balanceOf(bob), "Bob's balance has been modified unexpectedly.");
    }

    /// @notice TransferFrom should not be possible when token is paused.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After pausing the token, a transferFrom could happen or the balance of the tokenSender or the tokenReceiver changed unexpectedely.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR updating the owner of the contract OR calling the following functions: pause.
    /// @custom:ercx-categories balance, transfer, pause
    /// @custom:ercx-concerned-function pause
    function testTransferFromAreNotPossibleWhenPaused(uint256 transferredAmount, uint256 initialBalanceAlice)
        external
        updateOwner
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 prevBalanceAlice = cut.balanceOf(alice);
        vm.assume(transferredAmount < prevBalanceAlice);
        vm.startPrank(contractOwner);
        CallResult memory callResultPause = _tryPause();
        // Skip the test if the pause call fails
        conditionalSkip(!callResultPause.success, "Inconclusive test: Failed to pause the contract.");
        _tryAliceApprove(bob, transferredAmount);
        assertFail(_tryBobTransferFrom(alice, bob, transferredAmount));
        assertEq(prevBalanceAlice, cut.balanceOf(alice), "Alice's balance has been modified unexpectedely.");
        assertEq(0, cut.balanceOf(bob), "Bob's balance has been modified unexpectedely.");
    }

    /**
     *
     */
    /* Burning checks. */
    /**
     *
     */

    /// @notice User balance should be updated correctly after burning (via `burn(uint256)` or `burnToken(uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burn(uint256)` or `burnToken(uint256)`), the user balance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burn, burnToken
    function testBurningUpdatesBalance(uint256 burnedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 prevBalanceAlice = cut.balanceOf(alice);
        vm.assume(burnedAmount > 0);
        vm.assume(burnedAmount <= prevBalanceAlice);
        CallResult memory callResultBurn = _tryBurnTokensAmount(alice, burnedAmount);
        // Skip the test if the burn call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burn tokens.");
        assertEq(
            prevBalanceAlice - burnedAmount,
            cut.balanceOf(alice),
            "After a burn, the balance of the account from which tokens were burned was not updated correctly."
        );
    }

    /// @notice User balance should not change when burning zero token (via `burn(uint256)` or `burnToken(uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning 0 token (via `burn(uint256)` or `burnToken(uint256)`), the user balance has changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burn, burnToken
    function testBurningZeroTokenDoesNotUpdateBalance(uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 prevBalanceAlice = cut.balanceOf(alice);
        CallResult memory callResultBurn = _tryBurnTokensAmount(alice, 0);
        // Skip the test if the burn call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burn tokens.");
        assertEq(
            prevBalanceAlice,
            cut.balanceOf(alice),
            "After a burn of zero tokens, the balance of the account from which tokens were burned has changed."
        );
    }

    /// @notice Total supply should be updated correctly after burning (via `burn(uint256)` or `burnToken(uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burn(uint256)` or `burnToken(uint256)`), the total supply was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burn, burnToken
    function testBurningUpdatesTotalSupply(uint256 burnedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        vm.assume(burnedAmount > 0);
        vm.assume(burnedAmount <= cut.balanceOf(alice));

        uint256 initialTotalSupply = cut.totalSupply();
        CallResult memory callResultBurn = _tryBurnTokensAmount(alice, burnedAmount);
        // Skip the test if the burn call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burn tokens.");
        assertEq(
            initialTotalSupply - burnedAmount,
            cut.totalSupply(),
            "After a burn, the total supply was not updated correctly."
        );
    }

    /// @notice Total supply should not change after burning zero tokens (via `burn(uint256)` or `burnToken(uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burn(uint256)` or `burnToken(uint256)`), the total supply was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burn, burnToken
    function testBurningZeroTokenDoesNotUpdateTotalSupply(uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 initialTotalSupply = cut.totalSupply();
        CallResult memory callResultBurn = _tryBurnTokensAmount(alice, 0);
        // Skip the test if the burn call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burn tokens.");
        assertEq(initialTotalSupply, cut.totalSupply(), "After a burn of zero token, the total supply has changed.");
    }

    /// @notice User balance should be updated correctly after burning (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// The balance of the tokenApprover is decreased by the burned amount. The balance of the tokenApprovee (performing the burn) is let unchanged.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the user balance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromUpdatesBalance(uint256 burnedAmount, uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 initialUserBalanceAlice = cut.balanceOf(alice);
        uint256 initialUserBalanceBob = cut.balanceOf(bob);
        vm.assume(burnedAmount > 0);
        vm.assume(burnedAmount <= allowedAmount);
        vm.assume(burnedAmount <= initialUserBalanceAlice);

        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, burnedAmount);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(
            initialUserBalanceAlice - burnedAmount,
            cut.balanceOf(alice),
            "After a burnFrom, the balance of the tokenApprover was not updated correctly."
        );
        assertEq(
            initialUserBalanceBob, cut.balanceOf(bob), "After a burnFrom, the balance of the tokenApprovee has changed."
        );
    }

    /// @notice User balance should not change after burning zero token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning zero token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the user balance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromZeroTokenDoesNotUpdateBalances(uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 initialUserBalance = cut.balanceOf(alice);
        uint256 initialUserBalanceBob = cut.balanceOf(bob);

        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, 0);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(
            initialUserBalance,
            cut.balanceOf(alice),
            "After a burnFrom of zero token, the balance of the tokenApprover has changed."
        );
        assertEq(
            initialUserBalanceBob,
            cut.balanceOf(bob),
            "After a burnFrom of zero token, the balance of the tokenApprovee has changed."
        );
    }

    /// @notice Total supply should be updated correctly after burning (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning from some token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the total supply was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromUpdatesTotalSupply(uint256 burnedAmount, uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 initialTotalSupply = cut.totalSupply();
        uint256 initialUserBalance = cut.balanceOf(alice);
        vm.assume(burnedAmount > 0);
        vm.assume(burnedAmount <= allowedAmount);
        vm.assume(burnedAmount <= initialUserBalance);
        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, burnedAmount);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(
            initialTotalSupply - burnedAmount,
            cut.totalSupply(),
            "After a burnFrom, the total supply was not updated correctly."
        );
    }

    /// @notice Total supply should not be updated after burning zero token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning zero token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the total supply has changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromZeroTokenDoesNotUpdateTotalSupply(uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        uint256 initialTotalSupply = cut.totalSupply();

        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, 0);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(initialTotalSupply, cut.totalSupply(), "After a burnFrom of zero token, the total supply has changed.");
    }

    /// @notice Allowance should be updated correctly after burning (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the allowance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromUpdatesAllowance(uint256 burnedAmount, uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        vm.assume(allowedAmount < MAX_UINT256);
        uint256 initialUserBalance = cut.balanceOf(alice);
        vm.assume(burnedAmount > 0);
        vm.assume(burnedAmount <= allowedAmount);
        vm.assume(burnedAmount <= initialUserBalance);
        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, burnedAmount);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(
            allowedAmount - burnedAmount,
            cut.allowance(alice, bob),
            "After a burnFrom, the allowance of the tokenApprovee for tokenApprover was not updated correctly."
        );
    }

    /// @notice Allowance should not change after burning zero token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After burning some token (via `burnFrom(address,uint256)` or `burnToken(address,uint256)` or `burn(address,uint256)`), the allowance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: burn, burnToken, burnFrom.
    /// @custom:ercx-categories balance, burn
    /// @custom:ercx-concerned-function burnFrom, burnToken, burn
    function testBurningFromZeroTokenDoesNotUpdateAllowance(uint256 allowedAmount, uint256 initialBalanceAlice)
        external
        initializeStateTwoUsers(initialBalanceAlice, 0)
    {
        _tryAliceApprove(bob, allowedAmount);
        CallResult memory callResultBurn = _tryBurnTokensAddressAmount(bob, alice, 0);
        // Skip the test if the burnFrom call fails
        conditionalSkip(!callResultBurn.success, "Inconclusive test: Failed to burnFrom tokens.");
        assertEq(
            allowedAmount,
            cut.allowance(alice, bob),
            "After a burnFrom of zero token, the allowance of the tokenApprovee for tokenApprover has changed."
        );
    }

    /**
     *
     */
    /* Minting checks. */
    /**
     *
     */

    /// @notice User balance should be updated correctly after minting (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After minting some token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`), the user balance was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: mint, mintToken, issue.
    /// @custom:ercx-categories balance, mint
    /// @custom:ercx-concerned-function mint, mintToken, issue
    function testMintingUpdatesBalance(uint256 mintedAmount) external updateOwner {
        uint256 initialTotalSupply = cut.totalSupply();
        vm.assume(mintedAmount > 0);
        vm.assume(mintedAmount < MAX_UINT256 - initialTotalSupply);
        uint256 initialUserBalance = cut.balanceOf(alice);
        CallResult memory callResultMint = _mintTokenToAlice(mintedAmount);
        // Skip the test if the mint call fails
        conditionalSkip(!callResultMint.success, "Inconclusive test: Failed to mint tokens.");
        assertEq(
            initialUserBalance + mintedAmount,
            cut.balanceOf(alice),
            "Alice's balance was not augmented with the amount minted to her."
        );
    }

    /// @notice Total supply should be updated correctly after minting (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After minting some token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`), the total supply was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: mint, mintToken, issue.
    /// @custom:ercx-categories balance, mint
    /// @custom:ercx-concerned-function mint, mintToken, issue
    function testMintingUpdatesTotalSupply(uint256 mintedAmount) external updateOwner {
        uint256 initialTotalSupply = cut.totalSupply();
        vm.assume(mintedAmount > 0);
        vm.assume(mintedAmount < MAX_UINT256 - initialTotalSupply);
        CallResult memory callResultMint = _mintTokenToAlice(mintedAmount);
        // Skip the test if the mint call fails
        conditionalSkip(!callResultMint.success, "Inconclusive test: Failed to mint tokens.");
        assertEq(
            initialTotalSupply + mintedAmount,
            cut.totalSupply(),
            "The total supply was not augmented by the minted amount."
        );
    }

    /// @notice Minting to the zero address should not be possible (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`). Minting to this address should fail.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was possible to mint tokens (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`) to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: mint, mintToken, issue.
    /// @custom:ercx-categories mint, zero address
    /// @custom:ercx-concerned-function mint, mintToken, issue
    function testMintingToZeroAddressShouldFail(uint256 mintedAmount) external updateOwner {
        vm.assume(mintedAmount > 0);
        vm.assume(mintedAmount < MAX_UINT256 - cut.totalSupply());
        assertFail(
            _mintTokenToAddress(mintedAmount, address(0x0)), "It was possible to mint tokens to the zero address."
        );
    }

    /// @notice Minting zero token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`) should not change the total supply.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback By minting zero token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`), the total supply changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: mint, mintToken, issue.
    /// @custom:ercx-categories mint, zero address
    /// @custom:ercx-concerned-function mint, mintToken, issue
    function testMintingZeroShouldNotChangeTotalSupply() external updateOwner {
        uint256 initialTotalSupply = cut.totalSupply();
        CallResult memory callResultMint = _mintTokenToAlice(0);
        // Skip the test if the mint call fails
        conditionalSkip(!callResultMint.success, "Inconclusive test: Failed to mint tokens.");
        assertEq(
            initialTotalSupply,
            cut.totalSupply(),
            "Total supply has changed unexpectedely while minting zero token to an account."
        );
    }

    /// @notice Minting zero token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`) should not change the balance of the account target of the mint.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback By minting zero token (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`), the balance of the target address changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: mint, mintToken, issue.
    /// @custom:ercx-categories mint, zero address
    /// @custom:ercx-concerned-function mint, mintToken, issue
    function testMintingZeroShouldNotChangeBalance() external updateOwner {
        uint256 initialUserBalance = cut.balanceOf(alice);
        CallResult memory callResultMint = _mintTokenToAlice(0);
        // Skip the test if the mint call fails
        conditionalSkip(!callResultMint.success, "Inconclusive test: Failed to mint tokens.");
        assertEq(
            initialUserBalance,
            cut.balanceOf(alice),
            "Balance of Alice has changed unexpectedely while minting zero token to this address."
        );
    }

    /// @notice The value of variable totalSupply, if it represents the sum of all tokens in the contract
    /// should not overflow when the sum of tokens changes via minting (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An overflow happened with variable totalSupply when the sum of tokens changed via minting (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: unpause.
    /// @custom:ercx-categories total supply, mint
    /// @custom:ercx-concerned-function mint, mintToken, issue
    /// @custom:ercx-note From Awesome Buggy ERC-20 repository: A2
    /// @custom:ercx-note The contract would add or decrease totalSupply without any check or using SafeMath when the sum of tokens changes, making overflow possible in totalSupply.
    function testTotalSupplyDoesNotOverflowByMinting(uint256 amountToMint) external updateOwner unpauseIfPaused {
        uint256 totalSupply_ = cut.totalSupply();
        if (totalSupply_ > 0) {
            vm.assume(amountToMint > MAX_UINT256 - totalSupply_);
        } else {
            amountToMint = MAX_UINT256;
        }
        CallResult memory callResultMint = _mintTokenToAlice(amountToMint);
        // If success, check that the new totalSupply == MAX_UINT256 or initla amount.
        // Otherwise, it means it is impossible to mint above MAX_UINT256,
        // which also implies the totalSupply cannot overflow.
        if (callResultMint.success) {
            emit log("Successfully minted.");
            uint256 newTotalSupply = cut.totalSupply();
            assertTrue(
                (newTotalSupply == MAX_UINT256) || (newTotalSupply == totalSupply_),
                "The total supply has not been augmented by the amount minted."
            );
        }
    }

    /// @notice Contract owner cannot control balance by using minting overflow (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The contract owner can control balance by minting numerous tokens to an account (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`),
    /// overflowing its balance to a small figure.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR updating the owner of the contract.
    /// @custom:ercx-categories balance, mint
    /// @custom:ercx-concerned-function mint, mintToken, issue
    /// @custom:ercx-note From Awesome Buggy ERC-20 repository: A6.
    /// @custom:ercx-note Contract owner with minting authority could control an account's balance at will by sending numerous tokens to the account and leading its balance overflowing to a small figure. (CVE-2018-11812)
    function testBalanceDoesNotOverflowByMinting(uint256 initialBalance)
        external
        updateOwner
        initializeStateTwoUsers(initialBalance, initialBalance)
    {
        vm.assume(initialBalance > 1);
        uint256 prevBalance = cut.balanceOf(alice);
        // Setting Alice's balance to MAX_UINT256
        CallResult memory callResultMint = _mintTokenToAlice(MAX_UINT256 - prevBalance);
        // If success, try minting 1 additional token.
        // Otherwise, it means it is impossible to mint MAX_UINT256,
        // which also implies the totalSupply cannot overflow.
        if (callResultMint.success) {
            CallResult memory callResultMint1 = _mintTokenToAlice(1);
            // Adding one token
            // If success, check that the new balance of Alice is more than her original balance.
            // Otherwise, it means it is impossible to mint MAX_UINT256 or above,
            // which also implies the totalSupply cannot overflow.
            if (callResultMint1.success) {
                uint256 nextBalance = cut.balanceOf(alice);
                assertLt(
                    prevBalance, nextBalance, "After minting some tokens to Alice, her balance has not been augmented."
                );
            }
        }
    }

    /// @notice Contract owner cannot issue random amounts of tokens (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`)
    /// by bypassing the check of max minting value using great values.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The contract owner can bring about an overflow and issue random amounts of tokens (via `mint(address,uint256)` or `mintToken(address,uint256)` or `issue(address,uint256)`)
    /// by passing a great value and pass the check of max minting value.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER updating the owner of the contract
    /// OR calling the following functions: tokenLimit.
    /// @custom:ercx-categories mint
    /// @custom:ercx-concerned-function mint, mintToken, issue
    /// @custom:ercx-note From Awesome Buggy ERC-20 repository: A8.
    /// @custom:ercx-note Owner can bring about an overflow and issue random amounts of tokens by passing a great value and pass the check of max minting value. (CVE-2018-11809)
    function testNoExcessByMintingViaOverflow(uint256 amountToMint) external updateOwner {
        uint256 totalSupply = cut.totalSupply();
        (bool successLimit, bytes memory dataLimit) = _getVariableValue("tokenLimit");
        // Skip the test if the tokenLimit call fails
        conditionalSkip(!successLimit, "Inconclusive test: Failed to call tokenLimit.");
        uint256 tokenLimit = abi.decode(dataLimit, (uint256));
        emit log_uint(tokenLimit);
        vm.assume(amountToMint > MAX_UINT256 - totalSupply);
        CallResult memory callResultMint = _mintTokenToAlice(amountToMint);
        // If success, check that Alice's balance remains less than or equal to the tokenLimit.
        // Otherwise, it means it is impossible to mint above MAX_UINT256,
        // which also implies the totalSupply cannot overflow.
        if (callResultMint.success) {
            assertLe(cut.balanceOf(alice), tokenLimit, "Alice balance has been augmented to more than the token limit.");
        }
    }

    /**
     *
     */
    /* increaseAllowance checks. */
    /**
     *
     */

    /// @notice A successful `increaseAllowance` call of zero amount MUST emit the Approval event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `increaseAllowance` call of zero amount DOES NOT emit the Approval event correctly.
    /// @custom:ercx-categories allowance, zero amount, event
    /// @custom:ercx-concerned-function increaseAllowance, Approval
    function testZeroIncreaseAllowanceEventEmission() external {
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, 0);
        assertSuccess(
            _tryCustomerIncreaseAllowance(alice, bob, 0),
            "Calling increaseAllowance of zero amount did not emit the Approval event."
        );
    }

    /// @notice A successful `increaseAllowance` call of positive amount MUST emit the Approval event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `increaseAllowance` call of positive amount DOES NOT emit the Approval event correctly.
    /// @custom:ercx-categories allowance, event
    /// @custom:ercx-concerned-function increaseAllowance, Approval
    function testPositiveIncreaseAllowanceEventEmission(uint256 amount) external {
        vm.assume(amount > 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, amount);
        assertSuccess(
            _tryCustomerIncreaseAllowance(alice, bob, amount),
            "Calling increaseAllowance of zero amount did not emit the Approval event."
        );
    }

    /// @notice After a tokenApprover increases the allowance of a tokenApprovee by some positive amount via an
    /// `increaseAllowance` call, zero amount MUST be transferable by tokenApprovee, provided a sufficient balance
    /// of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover increases the allowance of a tokenApprovee by some positive
    /// amount via an `increaseAllowance` call, zero amount CANNOT be transferred by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount, balance, transferFrom
    /// @custom:ercx-concerned-function increaseAllowance
    function testPositiveIncreaseAllowanceAllowsZeroTransferFrom(
        uint256 increaseAmount,
        uint256 balance1,
        uint256 balance2,
        uint256 initAllowance
    ) external {
        internalTestPositiveIncreaseAllowanceAllowsTransferFrom(increaseAmount, 0, balance1, balance2, initAllowance);
    }

    /// @notice After a tokenApprover increases the allowance of a tokenApprovee by some positive amount via an
    /// `increaseAllowance` call, any amount up to the increased allowance MUST be transferable by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover increases the allowance of a tokenApprovee by some positive amount
    /// via a `increaseAllowance` call, some amount up to the increased allowance CANNOT be transferred by
    /// tokenApprovee, provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, transferFrom, balance
    /// @custom:ercx-concerned-function increaseAllowance
    function testPositiveIncreaseAllowanceAllowsPositiveTransferFrom(
        uint256 increaseAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2,
        uint256 initAllowance
    ) external {
        vm.assume(transferAmount > 0);
        internalTestPositiveIncreaseAllowanceAllowsTransferFrom(
            increaseAmount, transferAmount, balance1, balance2, initAllowance
        );
    }

    /// @notice Internal property test: After a tokenApprover increases the allowance of a tokenApprovee some positive amount, any amount up to
    /// the said amount MUST be transferable by tokenApprovee, provided a sufficient balance of tokenApprover.
    function internalTestPositiveIncreaseAllowanceAllowsTransferFrom(
        uint256 increaseAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2,
        uint256 initAllowance
    ) internal initializeAllowanceOneUser(initAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(increaseAmount > 0);
        vm.assume(increaseAmount <= MAX_UINT256 - initAllowance);
        vm.assume(transferAmount <= initAllowance + increaseAmount);
        vm.assume(cut.balanceOf(alice) >= transferAmount);
        assertSuccess(_tryAliceIncreaseAllowance(bob, increaseAmount));
        assertSuccess(
            _tryBobTransferFrom(alice, bob, transferAmount),
            "Bob could not transferFrom Alice after she allowed Bob with increaseAllowance."
        );
    }

    /// @notice A successful `increaseAllowance` call MUST increase the allowance of the tokenApprovee correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `increaseAllowance` call DOES NOT increase the allowance of the tokenApprovee correctly.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function increaseAllowance
    function testIncreaseAllowanceAsExpected(uint256 addedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(addedValue > 0);
        vm.assume(addedValue < MAX_UINT256 - allowance);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceIncreaseAllowance(bob, addedValue));
        assertEq(
            allowance + addedValue,
            cut.allowance(alice, bob),
            "Alice allowance to Bob was not increased by the amount used with increaseAllowance."
        );
    }

    /// @notice The `increaseAllowance` function DOES NOT ALLOW allowance to be double-spent, i.e.,
    /// Alice CAN increase her allowance for Bob by the correct amount even if Bob tries to front-run her by
    /// calling `transferFrom` call right before her call.
    /// @dev This tests simulates front running by placing Bob's call before Alice's
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `increaseAllowance` function ALLOWS allowance to be double-spent, i.e.,
    /// Alice CANNOT increase her allowance for Bob by the correct amount even if Bob tries to front-run her by
    /// calling `transferFrom` call right before her call.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function increaseAllowance
    function testIncreaseAllowanceDoubleSpend(uint256 prevAllowance, uint256 increaseAmount, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
        initializeAllowanceOneUser(prevAllowance)
    {
        vm.assume(prevAllowance < MAX_UINT256 - increaseAmount);
        // To account for cases in which allowance can be greater than balance
        uint256 maxSpendable = prevAllowance > cut.balanceOf(alice) ? cut.balanceOf(alice) : prevAllowance;
        uint256 allowanceLeft = cut.allowance(alice, bob) - maxSpendable;
        // Bob sends to himself all the maximum spendable
        assertSuccess(_tryBobTransferFrom(alice, bob, maxSpendable));
        assertEq(cut.allowance(alice, bob), allowanceLeft);
        // Alice increases Bob's allowance by `increaseAmount`
        assertSuccess(_tryAliceIncreaseAllowance(bob, increaseAmount));
        // Check that the allowance has increased correctly
        assertEq(
            cut.allowance(alice, bob),
            allowanceLeft + increaseAmount,
            "Alice's increased allowance to Bob was not reflected correctly."
        );
    }

    /* Self incremental approval checks. */

    /// @notice Self `increaseAllowance` call of zero amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `increaseAllowance` call of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount
    /// @custom:ercx-concerned-function increaseAllowance
    function testZeroSelfIncreaseAllowance(uint256 balance1, uint256 balance2) external {
        internalTestSelfIncreaseAllowance(0, balance1, balance2);
    }

    /// @notice Self `increaseAllowance` call of positive amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `increaseAllowance` call of positive amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function increaseAllowance
    function testPositiveSelfIncreaseAllowance(uint256 amount, uint256 balance1, uint256 balance2) external {
        vm.assume(amount > 0);
        internalTestSelfIncreaseAllowance(amount, balance1, balance2);
    }

    function internalTestSelfIncreaseAllowance(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice));
        // Alice self approves
        assertSuccess(_tryAliceIncreaseAllowance(alice, amount));
        assertEq(
            cut.allowance(alice, alice),
            amount,
            "Alice's allowance to herself was not taken into account after self approving."
        );
    }

    /// @notice Self `increaseAllowance` call, followed by a `transferFrom` call of zero amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `increaseAllowance` call, followed by a `transferFrom` call of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount, transferFrom
    /// @custom:ercx-concerned-function increaseAllowance
    function testZeroSelfIncreaseAllowanceTransferFrom(uint256 balance1, uint256 balance2) external {
        _internalTestSelfIncreaseAllowanceTransferFrom(0, balance1, balance2);
    }

    /// @notice Self `increaseAllowance` call, followed by a `transferFrom` call of some positive amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `increaseAllowance` call, followed by a `transferFrom` call of some positive amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, transferFrom
    /// @custom:ercx-concerned-function increaseAllowance
    function testPositiveSelfIncreaseAllowanceTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        external
    {
        vm.assume(amount > 0);
        _internalTestSelfIncreaseAllowanceTransferFrom(amount, balance1, balance2);
    }

    function _internalTestSelfIncreaseAllowanceTransferFrom(uint256 amount, uint256 balance1, uint256 balance2)
        internal
        initializeStateTwoUsers(balance1, balance2)
    {
        vm.assume(amount < cut.balanceOf(alice));
        // Alice self approves
        assertSuccess(_tryAliceIncreaseAllowance(alice, amount));
        // Alice transfers using transferFrom
        assertSuccess(
            _tryAliceTransferFrom(alice, bob, amount), "After Alice self-approved, she could not transferFrom to Bob."
        );
    }

    /**
     *
     */
    /* decreaseAllowance checks. */
    /**
     *
     */

    /// @notice A successful `decreaseAllowance` call of zero amount MUST emit the Approval event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `decreaseAllowance` call of zero amount DOES NOT emit the Approval event correctly.
    /// @custom:ercx-categories allowance, zero amount, event
    /// @custom:ercx-concerned-function decreaseAllowance, Approval
    function testZeroDecreaseAllowanceEventEmission() external {
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, 0);
        assertSuccess(
            _tryCustomerDecreaseAllowance(alice, bob, 0),
            "After reducing the allowance by 0 with decreaseAllowance, the Approval event was not emitted."
        );
    }

    /// @notice A successful `decreaseAllowance` call of positive amount MUST emit the Approval event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `decreaseAllowance` call of positive amount DOES NOT emit the Approval event correctly.
    /// @custom:ercx-categories allowance, event
    /// @custom:ercx-concerned-function decreaseAllowance, Approval
    function testPositiveDecreaseAllowanceEventEmission(uint256 amount, uint256 allowance)
        external
        initializeAllowanceOneUser(allowance)
    {
        vm.assume(amount > 0);
        vm.assume(amount <= allowance);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, allowance - amount);
        assertSuccess(
            _tryAliceDecreaseAllowance(bob, amount),
            "After reducing the allowance with decreaseAllowance, the Approval event was not emitted."
        );
    }

    /// @notice After a tokenApprover decreases the allowance of a tokenApprovee by some positive amount
    /// via a `decreaseAllowance` call, zero amount MUST be transferable by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover decreases the allowance of a tokenApprovee by some positive amount
    /// via a `decreaseAllowance` call, zero amount CANNOT be transferred by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount, transferFrom, balance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testPositiveDecreaseAllowanceAllowsZeroTransferFrom(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2
    ) external {
        internalTestPositiveDecreaseAllowanceAllowsTransferFrom(initAllowance, decreaseAmount, 0, balance1, balance2);
    }

    /// @notice After a tokenApprover decreases the allowance of a tokenApprovee by some positive amount via a
    /// `decreaseAllowance` call, any amount up to the decreased allowance MUST be transferable by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a tokenApprover decreases the allowance of a tokenApprovee by some positive amount via a
    /// `decreaseAllowance` call, any amount up to the decreased allowance CANNOT be transferred by tokenApprovee,
    /// provided a sufficient balance of tokenApprover.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, transferFrom, balance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testPositiveDecreaseAllowanceAllowsPositiveTransferFrom(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) external {
        vm.assume(transferAmount > 0);
        internalTestPositiveDecreaseAllowanceAllowsTransferFrom(
            initAllowance, decreaseAmount, transferAmount, balance1, balance2
        );
    }

    /// @notice Internal property test: After a tokenApprover decreases the allowance of a tokenApprovee some positive amount, any amount up to
    /// the said amount MUST be transferable by tokenApprovee, provided a sufficient balance of tokenApprover.
    function internalTestPositiveDecreaseAllowanceAllowsTransferFrom(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 transferAmount,
        uint256 balance1,
        uint256 balance2
    ) internal initializeAllowanceOneUser(initAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(decreaseAmount > 0);
        vm.assume(decreaseAmount <= initAllowance);
        vm.assume(transferAmount <= initAllowance - decreaseAmount);
        vm.assume(cut.balanceOf(alice) >= transferAmount);
        assertSuccess(_tryAliceDecreaseAllowance(bob, decreaseAmount));
        assertSuccess(
            _tryBobTransferFrom(alice, bob, transferAmount),
            "After Alice allowance to Bob was decreased, Bob could not transferFrom some amount up to the remaining allowance."
        );
    }

    /// @notice A successful `decreaseAllowance` call MUST decrease the allowance of the tokenApprovee correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `decreaseAllowance` call DOES NOT decrease the allowance of the tokenApprovee correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceAsExpected(uint256 substractedValue, uint256 allowance, uint256 balance1)
        external
        initializeStateTwoUsers(balance1, 0)
    {
        vm.assume(substractedValue > 0);
        vm.assume(substractedValue <= cut.balanceOf(alice));
        vm.assume(allowance >= substractedValue);
        vm.assume(allowance < MAX_UINT256);
        assertSuccess(_tryAliceApprove(bob, allowance));
        assertSuccess(_tryAliceDecreaseAllowance(bob, substractedValue));
        assertEq(
            allowance - substractedValue,
            cut.allowance(alice, bob),
            "Bob's reduced allowance with decreaseAllowance was not reflected in his allowance."
        );
    }

    /// @notice The `decreaseAllowance` function DOES NOT ALLOW allowance to be double-spent, i.e.,
    /// Alice CAN decrease her allowance for Bob by the correct amount even if Bob tries to front-run her by
    /// calling `transferFrom` call right before her call.
    /// @dev This tests simulates front running by placing Bob's call before Alice's
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The `decreaseAllowance` function ALLOWS allowance to be double-spent, i.e.,
    /// Alice CANNOT decrease her allowance for Bob by the correct amount even if Bob tries to front-run her by
    /// calling `transferFrom` call right before her call.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceDoubleSpend(
        uint256 prevAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2,
        uint256 transferAmount
    ) external initializeAllowanceOneUser(prevAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(prevAllowance < MAX_UINT256 - decreaseAmount);
        // Account for cases in which allowance can be greater than balance
        uint256 maxSpendable = prevAllowance > cut.balanceOf(alice) ? cut.balanceOf(alice) : prevAllowance;
        vm.assume(transferAmount <= maxSpendable);
        uint256 allowanceLeft = cut.allowance(alice, bob) - transferAmount;
        vm.assume(decreaseAmount <= allowanceLeft); // Won't decrease more allowance than there is so it won't revert
        // Bob sends to himself some tokens
        assertSuccess(_tryBobTransferFrom(alice, bob, transferAmount));
        assertEq(cut.allowance(alice, bob), allowanceLeft);
        // Alice decreases Bob's allowance by `decreaseAmount`
        assertSuccess(_tryAliceDecreaseAllowance(bob, decreaseAmount));
        // Check that the allowance has decreased correctly
        assertEq(
            cut.allowance(alice, bob),
            allowanceLeft - decreaseAmount,
            "Alice's decreased allowance to Bob was not reflected correctly."
        );
    }

    /// @notice A `decreaseAllowance` call will REVERT if there's not enough allowance to decrease.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `decreaseAllowance` call DOES NOT REVERT if there's not enough allowance to decrease.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testDecreaseAllowanceBehaviorExact(
        uint256 prevAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2
    ) external initializeAllowanceOneUser(prevAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(prevAllowance < decreaseAmount);
        // Alice tries to decrease more allowance from Bob to what he has
        assertFail(
            _tryAliceDecreaseAllowance(bob, decreaseAmount),
            "A call to decreaseAllowance was succesful even though there was no allowance to reduce."
        );
    }

    /* Self decremental approval checks. */

    /// @notice Self `decreaseAllowance` call of zero amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `decreaseAllowance` call of zero amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount
    /// @custom:ercx-concerned-function decreaseAllowance
    function testZeroSelfDecreaseAllowance(uint256 initAllowance, uint256 balance1, uint256 balance2) external {
        _internalTestSelfDecreaseAllowance(initAllowance, 0, balance1, balance2);
    }

    /// @notice Self `decreaseAllowance` call of positive amount is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `decreaseAllowance` call of positive amount is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance
    /// @custom:ercx-concerned-function decreaseAllowance
    function testPositiveSelfDecreaseAllowance(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2
    ) external {
        vm.assume(decreaseAmount > 0);
        _internalTestSelfDecreaseAllowance(initAllowance, decreaseAmount, balance1, balance2);
    }

    function _internalTestSelfDecreaseAllowance(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2
    ) internal initializeAllowanceSelf(initAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(decreaseAmount < cut.balanceOf(alice));
        vm.assume(decreaseAmount <= cut.allowance(alice, alice));
        // Alice self decreases
        assertSuccess(_tryAliceDecreaseAllowance(alice, decreaseAmount));
        assertEq(
            cut.allowance(alice, alice),
            initAllowance - decreaseAmount,
            "Alice decreased allowance to herself was not reflected correctly."
        );
    }

    /// @notice Self `decreaseAllowance` call of zero amount, followed by a `transferFrom` call of an amount up
    /// to the decreased allowance for herself is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `decreaseAllowance` call of zero amount, followed by a `transferFrom` call of an amount up
    /// to the decreased allowance for herself is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, zero amount, transferFrom
    /// @custom:ercx-concerned-function decreaseAllowance
    function testZeroSelfDecreaseAllowanceTransferFrom(
        uint256 initAllowance,
        uint256 balance1,
        uint256 balance2,
        uint256 transferAmount
    ) external {
        _internalTestSelfDecreaseAllowanceTransferFrom(initAllowance, 0, balance1, balance2, transferAmount);
    }

    /// @notice Self `decreaseAllowance` call of positive amount, followed by a `transferFrom` call of an amount up
    /// to the decreased allowance for herself is ALLOWED.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Self `decreaseAllowance` call of positive amount, followed by a `transferFrom` call of an amount up
    /// to the decreased allowance for herself is NOT ALLOWED.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories allowance, transferFrom
    /// @custom:ercx-concerned-function decreaseAllowance
    function testPositiveSelfDecreaseAllowanceTransferFrom(
        uint256 initAllowance,
        uint256 amount,
        uint256 balance1,
        uint256 balance2,
        uint256 transferAmount
    ) external {
        vm.assume(amount > 0);
        _internalTestSelfDecreaseAllowanceTransferFrom(initAllowance, amount, balance1, balance2, transferAmount);
    }

    function _internalTestSelfDecreaseAllowanceTransferFrom(
        uint256 initAllowance,
        uint256 decreaseAmount,
        uint256 balance1,
        uint256 balance2,
        uint256 transferAmount
    ) internal initializeAllowanceSelf(initAllowance) initializeStateTwoUsers(balance1, balance2) {
        vm.assume(decreaseAmount < cut.allowance(alice, alice));
        vm.assume(transferAmount <= cut.allowance(alice, alice) - decreaseAmount);
        vm.assume(transferAmount <= cut.balanceOf(alice));
        // Alice self decreases allowance
        assertSuccess(_tryAliceDecreaseAllowance(alice, decreaseAmount));
        // Alice transfers using transferFrom
        assertSuccess(
            _tryAliceTransferFrom(alice, bob, transferAmount),
            "Alice could not transferFrom her account after decreasing her allowance."
        );
    }

    /**
     *
     * Unpausing transfers
     *
     */

    /// @notice If the contract has a walletAddress and an enableTransfer function, an address different from walletAddress can not enable token transfers through function enableTokenTransfer()
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Some address different from walletAddress could enable token transfer through function enableTokenTransfer()
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: walletAddress.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function enableTokenTransfer
    /// @custom:ercx-note from Awesome buggy repository, A11
    function testNonWalletAddressCannotEnableTransfer() external {
        (bool successWallet, bytes memory data) = _getVariableValue("walletAddress");
        // Skip the test if the walletAddress call fails
        conditionalSkip(
            !successWallet, "Inconclusive test: Impossible to retrieve wallet address using variable walletAddress."
        );
        address walletAddress = abi.decode(data, (address));
        vm.assume(alice != walletAddress);
        assertFail(_tryEnableTokenTransfer(alice), "Alice, who is not the walletAddress, could enable token transfers.");
    }

    /// @notice  If the contract has a walletAddress and an enableTransfer function, address walletAddress can enable token transfers through function enableTokenTransfer()
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Some address different from walletAddress could enable token transfer through function enableTokenTransfer()
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: walletAddress.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function enableTokenTransfer
    /// @custom:ercx-note from Awesome buggy repository, A11
    function testWalletAddressCanEnableWalletTransfer() external {
        (bool successWallet, bytes memory data) = _getVariableValue("walletAddress");
        // Skip the test if the walletAddress call fails
        conditionalSkip(
            !successWallet, "Inconclusive test: Impossible to retrieve wallet address using variable walletAddress."
        );
        address walletAddress = abi.decode(data, (address));
        assertSuccess(_tryEnableTokenTransfer(walletAddress), "The wallet address could not enable token transfers.");
    }

    /// @notice  If the contract has a walletAddress and an disableTransfer function, an address different from walletAddress can not disable token transfers through function enableTokenTransfer()
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Some address different from walletAddress could enable token transfer through function enableTokenTransfer()
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: walletAddress.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function disableTokenTransfer
    /// @custom:ercx-note from Awesome buggy repository, A11
    function testNonWalletAddressCannotDisableTransfer() external {
        (bool successWallet, bytes memory data) = _getVariableValue("walletAddress");
        // Skip the test if the walletAddress call fails
        conditionalSkip(
            !successWallet, "Inconclusive test: Impossible to retrieve wallet address using variable walletAddress."
        );
        address walletAddress = abi.decode(data, (address));
        vm.assume(alice != walletAddress);
        assertFail(
            _tryDisableTokenTransfer(alice), "Alice, who is not the walletAddress, could disable token transfers."
        );
    }

    /// @notice  If the contract has a walletAddress and an disableTransfer function, address walletAddress can disable token transfers through function enableTokenTransfer()
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Some address different from walletAddress could enable token transfer through function enableTokenTransfer()
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with calling the following functions: walletAddress.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function disableTokenTransfer
    /// @custom:ercx-note from Awesome buggy repository, A11
    function testWalletAddressCanDisableWalletTransfer() external {
        (bool successWallet, bytes memory data) = _getVariableValue("walletAddress");
        // Skip the test if the walletAddress call fails
        conditionalSkip(
            !successWallet, "Inconclusive test: Impossible to retrieve wallet address using variable walletAddress."
        );
        address walletAddress = abi.decode(data, (address));
        assertSuccess(_tryDisableTokenTransfer(walletAddress), "The wallet address could not disable token transfers.");
    }

    /**
     *
     * Constructor / Ownership - Issue with case
     *
     */

    /// @notice  Only contract caller can call function owned() which sets ownership of the contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Some address different from contract owner could call function owned() and become contract owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with updating the owner of the contract.
    /// @custom:ercx-categories ownership
    /// @custom:ercx-concerned-function owned
    /// @custom:ercx-note from Awesome buggy repository, A14
    function testShouldNotChangeOwnership() external updateOwner {
        vm.assume(contractOwner != alice);
        bytes4 selector = selectorOf(string("owned()"));
        bytes memory encodedSelectorOwned = abi.encodeWithSelector(selector);
        vm.startPrank(alice);
        (bool successOwned,) = address(cut).call(encodedSelectorOwned);
        if (successOwned) {
            // Update contractowner
            if (_updateContractOwner()) {
                if (contractOwner == alice) {
                    assertTrue(false, "Alice, who is not the contract owner, could set herself as contract owner.");
                }
            }
        } else {
            emit log("Alice could not change owner, as expected.");
        }
    }

    /**
     *
     * setOwner - changing ownership checks
     *
     */

    /// @notice If the contract has a function setOwner(address), an address different from the current contract owner should not be able to call function setOwner(address).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An address different from the current contract owner could call function setOwner(address), hence getting ownership of the contract.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with updating the owner of the contract.
    /// @custom:ercx-categories ownership
    /// @custom:ercx-concerned-function setOwner
    /// @custom:ercx-note from Awesome buggy repository, A14
    function testNonOwnerCannotChangeOwner() external updateOwner {
        address initialContractOwer = contractOwner;
        bytes4 selector = selectorOf(string("setOwner(address)"));
        bytes memory encodedSelectorSetOwner = abi.encodeWithSelector(selector, bob);
        vm.startPrank(alice);
        (bool successSetOwner,) = address(cut).call(encodedSelectorSetOwner);
        vm.stopPrank();
        if (successSetOwner) {
            _updateContractOwner();
            if (contractOwner == bob || contractOwner != initialContractOwer) {
                assertTrue(
                    false, "Alice, who is not the contract owner, was able to change the registered contract owner."
                );
            }
        } else {
            emit log("Alice could not set owner, as expected.");
        }
    }

    /// @notice If the contract has a function setOwner(address), the current contract owner should be able to call function setOwner(address).
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The current contract owner could not call function setOwner(address), hence being denied his ownership privilege.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue with EITHER updating the owner of the contract
    /// OR calling the following functions: setOwner.
    /// @custom:ercx-categories ownership
    /// @custom:ercx-concerned-function setOwner
    /// @custom:ercx-note from Awesome Buggy A17
    function testOwnerCanChangeOwner() external updateOwner {
        address initialContractOwner = contractOwner;
        bytes4 selector = selectorOf(string("setOwner(address)"));
        bytes memory encodedSelectorSetOwner = abi.encodeWithSelector(selector, bob);
        vm.startPrank(initialContractOwner);
        (bool successSetOwner,) = address(cut).call(encodedSelectorSetOwner);
        vm.stopPrank();
        // Skip the test if the setOwner call fails
        conditionalSkip(!successSetOwner, "Inconclusive test: The owner cannot call the setOwner function.");
        _updateContractOwner();
        assertTrue(
            contractOwner == bob && contractOwner != initialContractOwner,
            "The contract owner was not able to change the registered contract owner."
        );
    }

    /**
     *
     * batchTransfer checks - batchTransfer() makes multiple transactions simultaneously
     *
     * After passing several transferring addresses
     *   and amounts by the caller, the function would conduct some checks then transfer tokens by modifying balances,
     *   while overflow might occur in uint256 amount = uint256(cnt) * _value if _value is a huge number.
     * It results in passing the sender's balance check in require( _value > 0 && balances[msg.sender] >= amount)
     *   due to making amount become a small value rather than cnt times of _value, then transfers out tokens exceeding balances[msg.sender].
     * (CVE-2018-10299).
     *
     */

    /// @notice Property test: batchTransfer from a tokenSender to multiple tokenReceivers reverts when there is an overflow of the total amount transferred, i.e., amount * tokenReceivers.length is above MAX_UINT256.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback batchTransfer from a tokenSender to multiple tokenReceivers does not revert when there is an overflow of the total amount transferred, i.e., amount * tokenReceivers.length is above MAX_UINT256.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR updating the owner of the contract OR calling the following functions: unpause.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function batchTransfer
    /// @custom:ercx-note from Awesome Buggy A1
    function testBatchTransferDoesNotOverflow(uint256 balanceAlice, uint256 transferAmount)
        external
        initializeStateTwoUsers(balanceAlice, 0)
        setupReceivers
        updateOwner
        unpauseIfPaused
    {
        _maximizeBalance(alice);
        // Test Body
        transferAmount = bound(transferAmount, MAX_UINT256 / 2, ((MAX_UINT256 / 3) * 2));
        CallResult memory callResult = _tryAliceBatchTransfer(receivers, transferAmount);
        if (!callResult.success) {
            emit CutContractFailure("batchTransfer(address[], uint256) failed");
        } else {
            assertTrue(false, "Alice was able to batchTransfer more than MAX_UIN256 in total.");
        }
    }

    /// @notice Property test: batchTransfer from the contractOwner to multiple tokenReceivers does not overflow when the total amount transferred is above MAX_UINT256.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An overflow happened during batch transferring tokens from contract owner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with updating the owner of the contract
    /// OR calling the following functions: unpause.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function batchTransfer
    /// @custom:ercx-note from Awesome Buggy A1
    function testBatchTransferDoesNotOverflowByContractOwner(uint256 transferAmount)
        external
        setupReceivers
        updateOwner
        unpauseIfPaused
    {
        receivers.push(alice);
        _maximizeBalance(contractOwner);
        // Test body
        transferAmount = bound(transferAmount, MAX_UINT256 / 3, (MAX_UINT256 / 2));
        CallResult memory callResult = _tryContractOwnerBatchTransfer(receivers, MAX_UINT256 / 3 + 1);
        if (!callResult.success) {
            emit CutContractFailure("batchTransfer(address[], uint256) failed");
        } else {
            assertTrue(false, "The contract owner was able to batchTransfer more than MAX_UIN256 in total.");
        }
    }

    /**
     *
     * Sell and setPrice checks
     *
     * Some contracts let owner control the price of transferring between ethers and tokens by users, yet owner could maliciously set a huge sellPrice to make an overflow in computing equivalent ethers.
     * The original number of ethers becomes a small value, causing the user receiving insufficient ethers. (CVE-2018-11811)
     *
     */

    /// @notice Property test: Contract owner cannot control sell price by using overflow.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The contract owner can set a huge sellPrice to make an overflow in computing equivalent ethers.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue EITHER with dealing tokens to dummy users for interacting with the contract
    /// OR updating the owner of the contract.
    /// @custom:ercx-categories ownership, sell
    /// @custom:ercx-concerned-function sell, setPrices
    /// @custom:ercx-note from Awesome Buggy A4
    function testOwnerCannotOverflowSellBySettingPrice(uint256 amount, uint256 balanceAlice)
        external
        initializeStateTwoUsers(balanceAlice, 0)
        updateOwner
    {
        vm.assume(amount <= cut.balanceOf(alice));
        vm.assume(amount > 1);
        vm.deal(address(cut), 1000 ether);
        vm.assume(address(cut).balance >= amount);
        uint256 sellPrice = MAX_UINT256 / amount + 1;
        // Setting a sell price that allows for an overflow with amount * sellPrice.
        bytes4 selector = selectorOf(string("setPrices(uint256,uint256)"));
        bytes memory encodedSelectorSetPrices = abi.encodeWithSelector(selector, sellPrice, 0);
        vm.startPrank(contractOwner);
        // Trying to set the price.
        (bool successSetPrices,) = address(cut).call(encodedSelectorSetPrices);
        vm.stopPrank();
        if (successSetPrices) {
            uint256 alicePreSellBalanceEth = address(alice).balance;
            vm.startPrank(alice);
            CallResult memory result = _trySell(amount);
            vm.stopPrank();
            if (result.success) {
                emit log("Successful sell.");
                emit log_uint(sellPrice);
                uint256 alicePostSellBalanceEth = address(alice).balance;
                assertLt(
                    alicePreSellBalanceEth + sellPrice,
                    alicePostSellBalanceEth,
                    "Alice ether balance was not augmented with the corresponding amount from the sold tokens."
                ); // Since Alice is selling strictly more than one token, she should have strictly more than her previous balance + the price in ether of one token
            }
        }
    }
}
