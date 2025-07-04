// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "../ERCAbstract.sol";

/// @notice Abstract contract that defines internal functions that are used in ERC20 test suite
abstract contract ERC20Abstract is ERCAbstract {
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

    // IERC20 interface from Openzeppelin
    IERC20 public cut;

    function init(address token) internal virtual {
        cut = IERC20(token);
    }

    // Some events, expected to be emitted from the contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
     *
     *
     * Initialization modifier
     *
     *
     */

    /// @notice Parameterized initialization of the balances of two dummy users,
    /// `balance1` -> `alice` and `balance2` -> `bob`.
    modifier initializeStateTwoUsers(uint256 balance1, uint256 balance2) {
        vm.assume(balance1 <= MAX_UINT256 - balance2);
        vm.assume(cut.totalSupply() <= MAX_UINT256 - balance1 - balance2);
        // Give balance1 tokens to Alice
        (bool dealAlice,) = _dealERC20Token(address(cut), alice, balance1);
        conditionalSkip(!dealAlice, "Inconclusive test: Issue with dealing tokens to dummy user, Alice.");
        // Give balance2 tokens to Bob
        (bool dealBob,) = _dealERC20Token(address(cut), bob, balance2);
        conditionalSkip(!dealBob, "Inconclusive test: Issue with dealing tokens to dummy user, Bob.");
        _;
    }

    /// @notice Parameterized initialization of the balances of two dummy users,
    /// `balance1` -> `alice` and `balance2` -> `bob`.
    modifier initializeStateTwoUsersGeneralAddresses(address user1, uint256 balance1, address user2, uint256 balance2) {
        vm.assume(user1 != address(0x0));
        vm.assume(user2 != address(0x0));
        vm.assume(user1 != user2);
        vm.assume(balance1 <= MAX_UINT256 - balance2);
        vm.assume(cut.totalSupply() <= MAX_UINT256 - balance1 - balance2);
        // Give balance1 tokens to user1
        (bool dealUser1,) = _dealERC20Token(address(cut), user1, balance1);
        conditionalSkip(!dealUser1, "Inconclusive test: Issue with dealing tokens to dummy user 1.");
        // Give balance2 tokens to user2
        (bool dealUser2,) = _dealERC20Token(address(cut), user2, balance2);
        conditionalSkip(!dealUser2, "Inconclusive test: Issue with dealing tokens to dummy user 2.");
        _;
    }

    /// @notice Parameterized initialization of the balances of two dummy users,
    /// `balance1` -> `alice` and `balance2` -> `bob`.
    modifier initializeStateOneUserGeneralAddress(address user, uint256 balance) {
        vm.assume(user != address(0x0));
        vm.assume(cut.totalSupply() <= MAX_UINT256 - balance);

        // Give balance tokens to user
        (bool dealUser,) = _dealERC20Token(address(cut), user, balance);
        conditionalSkip(!dealUser, "Inconclusive test: Issue with dealing tokens to dummy user.");
        _;
    }

    /// @notice Parametrized initialization of the allowance of `alice` to `bob`
    modifier initializeAllowanceOneUser(uint256 allowance) {
        vm.prank(alice);
        cut.approve(bob, allowance);
        _;
    }

    /// @notice Parametrized initialization of the allowance of `alice` to `alice`
    modifier initializeAllowanceSelf(uint256 allowance) {
        vm.prank(alice);
        cut.approve(alice, allowance);
        _;
    }

    modifier updateOwner() {
        bool updatedOwner = _updateContractOwner();
        conditionalSkip(!updatedOwner, "Inconclusive test: Failed to update the contract owner.");
        emit log("Successfully updated the contract owner.");
        _;
    }

    function _updateContractOwner() internal returns (bool) {
        string[8] memory signatures =
            ["owner()", "tokenManager()", "newOwner()", "ico()", "admin()", "admin1()", "manager()", "controller()"];
        bool updated = false;
        uint8 i = 0;
        while (!updated && i < signatures.length) {
            string memory signature = signatures[i];
            (bool success, bytes memory balData) = address(cut).call(abi.encodeWithSignature(signature));
            if (success) {
                contractOwner = abi.decode(balData, (address));
                updated = true;
            }
            i += 1;
        }
        return updated;
    }

    address[] receivers;

    modifier setupReceivers() {
        receivers.push(bob);
        receivers.push(carol);
        _;
    }

    modifier unpauseIfPaused() {
        (bool success, bytes memory result) = address(cut).call(abi.encodeWithSignature("paused()"));
        if (success) {
            bool decodedResult = abi.decode(result, (bool));
            if (decodedResult) {
                emit log("The contract was paused.");
                vm.prank(contractOwner);
                (bool successUnpause,) = address(cut).call(abi.encodeWithSignature("unpause()"));
                conditionalSkip(!successUnpause, "Inconclusive test: Failed to unpause the contract.");
                emit log("Successfully unpaused the contract.");
            }
        }
        _;
    }

    /**
     *
     * Getting some variable value
     *
     */
    function _getVariableValue(string memory variableName) internal returns (bool, bytes memory) {
        (bool success, bytes memory returnData) =
            address(cut).call(abi.encodeWithSignature(string(abi.encodePacked(variableName, "()"))));
        return (success, returnData);
    }

    /**
     *
     *
     * Internal helper functions.
     *
     *
     */

    /* Arbitrary customer abstractions */

    /// @notice Abstracts away a transfer made by a `customer`.
    function _tryCustomerTransfer(address customer, address tokenReceiver, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = _tryTransfer(tokenReceiver, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away an approval made by a `customer`.
    function _tryCustomerApprove(address customer, address tokenApprovee, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = tryApprove(tokenApprovee, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a transferFrom made by a `customer`.
    function _tryCustomerTransferFrom(address customer, address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = _tryTransferFrom(tokenSender, tokenReceiver, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a transferProxy made by a `customer`.
    function _tryCustomerTokenTransferProxy(
        address customer,
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("transferProxy(address,address,uint256,uint256,uint8,bytes32,bytes32)"));
        bytes memory data = abi.encodeWithSelector(selector, _from, _to, _value, _feeMesh, _v, _r, _s);
        vm.startPrank(customer);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
    }

    /* Alice abstractions */

    /// @notice Abstracts away a transfer made by Alice.
    function _tryAliceTransfer(address tokenReceiver, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerTransfer(alice, tokenReceiver, amount);
    }

    /// @notice Abstracts away an approval made by Alice.
    function _tryAliceApprove(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerApprove(alice, tokenApprovee, amount);
    }

    /// @notice Abstracts away a transferFrom made by Alice.
    function _tryAliceTransferFrom(address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (CallResult memory)
    {
        return _tryCustomerTransferFrom(alice, tokenSender, tokenReceiver, amount);
    }

    /// @notice Abstracts away a proxy transfer made by Alice.
    function _tryAliceTokenTransferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal returns (CallResult memory) {
        return _tryCustomerTokenTransferProxy(alice, _from, _to, _value, _feeMesh, _v, _r, _s);
    }

    /* Bob abstractions */

    /// @notice Abstracts away a transfer made by Bob.
    function _tryBobTransfer(address tokenReceiver, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerTransfer(bob, tokenReceiver, amount);
    }

    /// @notice Abstracts away an approval made by Bob.
    function _tryBobApprove(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerApprove(bob, tokenApprovee, amount);
    }

    /// @notice Abstracts away a transferFrom made by Bob.
    function _tryBobTransferFrom(address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (CallResult memory)
    {
        return _tryCustomerTransferFrom(bob, tokenSender, tokenReceiver, amount);
    }

    /// @notice Abstracts away a proxy transfer made by Bob.
    function _tryBobTokenTransferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal returns (CallResult memory) {
        return _tryCustomerTokenTransferProxy(bob, _from, _to, _value, _feeMesh, _v, _r, _s);
    }

    /* Carol abstractions */

    /// @notice Abstracts away a proxy transfer made by Carol.
    function _tryCarolTokenTransferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal returns (CallResult memory) {
        return _tryCustomerTokenTransferProxy(carol, _from, _to, _value, _feeMesh, _v, _r, _s);
    }

    /* Safe versions of functions */

    /// @notice Safe version of transfer where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryTransfer(address tokenReceiver, uint256 amount) internal returns (CallResult memory) {
        bytes memory data = abi.encodeWithSelector(cut.transfer.selector, tokenReceiver, amount);
        return _callOptionalReturn(data);
    }

    /// @notice Safe version of transferFrom where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryTransferFrom(address tokenSender, address tokenReceiver, uint256 amount)
        internal
        returns (CallResult memory)
    {
        bytes memory data = abi.encodeWithSelector(cut.transferFrom.selector, tokenSender, tokenReceiver, amount);
        return _callOptionalReturn(data);
    }

    /// @notice Safe version of approve where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function tryApprove(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        bytes memory data = abi.encodeWithSelector(cut.approve.selector, tokenApprovee, amount);
        return _callOptionalReturn(data);
    }

    /* More internal helper functions */

    function _callOptionalReturn(bytes memory data) internal returns (CallResult memory) {
        return _callOptionalReturn(address(cut), data);
    }

    /**
     *
     *
     * try functions for add-on functions
     *
     *
     */

    /**
     *
     */
    /* Pausing abstractions. */
    /**
     *
     */

    // @notice Safe version of pause function where it never reverts but always returns a bool to signal success.
    function _tryPause() internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("pause()"));
        bytes memory data = abi.encodeWithSelector(selector);
        return _callOptionalReturn(data);
    }

    /**
     *
     */
    /* Burning abstractions. */
    /**
     *
     */
    function _tryBurnTokensAmount(address burner, uint256 amountToBurn) internal returns (CallResult memory) {
        string[2] memory burnFunctionNames = ["burn", "burnToken"];
        //string[2] memory burnFunctionSignatures = ["(uint256)", "(uint256)"];
        string memory burnFunctionSignature = "(uint256)";
        for (uint8 i = 0; i < burnFunctionNames.length; i++) {
            string memory name = burnFunctionNames[i];
            //string memory sig = burnFunctionSignatures[i];
            string memory sig = burnFunctionSignature;
            CallResult memory callResult =
                _tryBurnTokensWithFunctionAmount(_concatenate(name, sig), burner, amountToBurn);
            if (callResult.success) {
                return callResult;
            }
        }
        return CallResult(false, OptionalReturn.RETURN_ABSENT);
    }

    function _tryBurnTokensAddressAmount(address burningAddress, address burnedAddress, uint256 amountToBurn)
        internal
        returns (CallResult memory)
    {
        string[3] memory burnFunctionNames = ["burnFrom", "burn", "burnToken"];
        //string[2] memory burnFunctionSignatures = ["(address,uint256)", "(address,uint256)", "(address,uint256)"];
        string memory burnFunctionSignature = "(address,uint256)";
        for (uint8 i = 0; i < burnFunctionNames.length; i++) {
            string memory name = burnFunctionNames[i];
            //string memory sig = burnFunctionSignatures[i];
            string memory sig = burnFunctionSignature;
            CallResult memory callResult = _tryBurnTokensWithFunctionAddressAmount(
                _concatenate(name, sig), burningAddress, burnedAddress, amountToBurn
            );
            if (callResult.success) {
                return callResult;
            }
        }
        return CallResult(false, OptionalReturn.RETURN_ABSENT);
    }

    function _tryBurnTokensWithFunctionAmount(string memory signature, address burner, uint256 amount)
        internal
        returns (CallResult memory)
    {
        bytes4 selector = selectorOf(signature);
        bytes memory data = abi.encodeWithSelector(selector, amount);
        vm.startPrank(burner);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
    }

    function _tryBurnTokensWithFunctionAddressAmount(
        string memory signature,
        address burningadddress,
        address _burnedaddress,
        uint256 amount
    ) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(signature);
        vm.startPrank(burningadddress);
        bytes memory data = abi.encodeWithSelector(selector, _burnedaddress, amount);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
    }

    // @notice Safe version of burnFrom function where it never reverts but always returns a bool to signal success.
    function _tryBurnFrom(address from, uint256 amount) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("burnFrom(address,uint256)"));
        bytes memory data = abi.encodeWithSelector(selector, from, amount);
        return _callOptionalReturn(data);
    }

    /**
     *
     */
    /* Minting abstractions. */
    /**
     *
     */
    function _mintTokenToAlice(uint256 amountToMint) internal returns (CallResult memory) {
        return _mintTokenToAddress(amountToMint, alice);
    }

    function _mintTokenToAddress(uint256 amountToMint, address receiver) internal returns (CallResult memory) {
        string[3] memory mintFunctionNames = ["mint", "issue", "mintToken"];
        string[3] memory mintFunctionSignatures = ["(address,uint256)", "(address,uint256)", "(address,uint256)"];
        uint8 i = 0;
        for (i = 0; i < mintFunctionNames.length; i++) {
            string memory name = mintFunctionNames[i];
            string memory sig = mintFunctionSignatures[i];
            CallResult memory callResult =
                _tryMintTokensToAddressWithFunction(_concatenate(name, sig), amountToMint, receiver);
            if (callResult.success) {
                return callResult;
            }
        }
        return CallResult(false, OptionalReturn.RETURN_ABSENT);
    }

    function _tryMintTokensToAddressWithFunction(string memory signature, uint256 amount, address receiver)
        internal
        returns (CallResult memory)
    {
        bytes4 selector = selectorOf(signature);
        vm.startPrank(contractOwner);
        bytes memory data = abi.encodeWithSelector(selector, receiver, amount);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
    }

    /**
     *
     */
    /* increaseAllowance abstractions. */
    /**
     *
     */

    /// @notice Safe version of increaseAllowance where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryIncreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("increaseAllowance(address,uint256)"));
        bytes memory data = abi.encodeWithSelector(selector, tokenApprovee, amount);
        return _callOptionalReturn(data);
    }

    /// @notice Abstracts away an increaseAllowance made by a `customer`.
    function _tryCustomerIncreaseAllowance(address customer, address tokenApprovee, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = _tryIncreaseAllowance(tokenApprovee, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away an allowance increase made by Alice.
    function _tryAliceIncreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerIncreaseAllowance(alice, tokenApprovee, amount);
    }

    /// @notice Abstracts away an allowance increase made by Bob.
    function _tryBobIncreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerIncreaseAllowance(bob, tokenApprovee, amount);
    }

    /**
     *
     */
    /* decreaseAllowance abstractions. */
    /**
     *
     */

    /// @notice Safe version of decreaseAllowance where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryDecreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("decreaseAllowance(address,uint256)"));
        bytes memory data = abi.encodeWithSelector(selector, tokenApprovee, amount);
        return _callOptionalReturn(data);
    }

    /// @notice Abstracts away an decreaseAllowance made by a `customer`.
    function _tryCustomerDecreaseAllowance(address customer, address tokenApprovee, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = _tryDecreaseAllowance(tokenApprovee, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away an allowance decrease made by Alice.
    function _tryAliceDecreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerDecreaseAllowance(alice, tokenApprovee, amount);
    }

    /// @notice Abstracts away an allowance decrease made by Bob.
    function _tryBobDecreaseAllowance(address tokenApprovee, uint256 amount) internal returns (CallResult memory) {
        return _tryCustomerDecreaseAllowance(bob, tokenApprovee, amount);
    }

    /**
     *
     * Unpausing transfers
     *
     */

    /// @notice Safe version of enableTokenTransfer where it never reverts but always returns a bool to signal success.
    function _tryEnableTokenTransfer(address enabler) internal returns (CallResult memory) {
        vm.startPrank(enabler);
        bytes4 selector = selectorOf(string("enableTokenTransfer()"));
        bytes memory data = abi.encodeWithSelector(selector);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
    }

    /// @notice Safe version of disableTokenTransfer where it never reverts but always returns a bool to signal success.
    function _tryDisableTokenTransfer(address enabler) internal returns (CallResult memory) {
        vm.startPrank(enabler);
        bytes4 selector = selectorOf(string("disableTokenTransfer()"));
        bytes memory data = abi.encodeWithSelector(selector);
        CallResult memory result = _callOptionalReturn(data);
        vm.stopPrank();
        return result;
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

    /// @notice Safe version of batchTransfer where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryBatchTransfer(address[] memory tokenReceivers, uint256 amount) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("batchTransfer(address[],uint256)"));
        bytes memory data = abi.encodeWithSelector(selector, tokenReceivers, amount);
        return _callOptionalReturn(data);
    }

    /// @notice Abstracts away a batchTransferFrom made by a `customer`.
    function _tryCustomerBatchTransfer(address customer, address[] memory tokenReceivers, uint256 amount)
        internal
        returns (CallResult memory)
    {
        vm.startPrank(customer);
        CallResult memory result = _tryBatchTransfer(tokenReceivers, amount);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a batch transfer made by Alice.
    function _tryAliceBatchTransfer(address[] memory tokenReceivers, uint256 amount)
        internal
        returns (CallResult memory)
    {
        return _tryCustomerBatchTransfer(alice, tokenReceivers, amount);
    }

    /// @notice Abstracts away a batch transfer made by Alice.
    function _tryContractOwnerBatchTransfer(address[] memory tokenReceivers, uint256 amount)
        internal
        returns (CallResult memory)
    {
        return _tryCustomerBatchTransfer(contractOwner, tokenReceivers, amount);
    }

    function _maximizeBalance(address maximizedAddress) internal {
        uint256 totalSupply = cut.totalSupply();
        uint256 balance = cut.balanceOf(maximizedAddress);
        if (totalSupply + balance < MAX_UINT256) {
            _dealERC20Token(address(cut), maximizedAddress, MAX_UINT256 - totalSupply - balance - 1);
        }
    }

    /**
     *
     */
    /* Sell and setPrice abstractions. */
    /**
     *
     */
    function _trySell(uint256 amount) internal returns (CallResult memory) {
        bytes4 selector = selectorOf(string("sell(uint256)"));
        bytes memory data = abi.encodeWithSelector(selector, amount);
        return _callOptionalReturn(data);
    }
}
