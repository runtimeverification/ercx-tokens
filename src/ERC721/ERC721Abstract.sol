// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../interfaces/ERCx721Interface.sol";
import "../ERCAbstract.sol";
import "../mocks/ERC721Receiver.sol";
import "../mocks/ERC721IncorrectReceiver.sol";

/// @notice Abstract contract that defines internal functions that are used in ERC-721 test suite
abstract contract ERC721Abstract is ERCAbstract {

    using stdStorage for StdStorage;

    ERCx721Interface cut;
    IERC721Receiver aliceReceiver;
    IERC721Receiver bobReceiver;
    IERC721Receiver carolReceiver;
    IERC721Receiver eveReceiver;

    address dan;
    address eve;

    uint256 tokenIdWithOwner;
    uint256[3] tokenIdsWithOwners;

    function init(address token) internal virtual {
        cut = ERCx721Interface(token);
    }

    /****************************
    *
    Events
    *
    ****************************/

    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /****************************
    *
    Initial state
    *
    ****************************/

    modifier withUsers() {
        aliceReceiver = new ERC721Receiver("alice");
        alice = address(aliceReceiver);
        bobReceiver = new ERC721Receiver("bob");
        bob = address(bobReceiver);
        carolReceiver = new ERC721Receiver("carol");
        carol = address(carolReceiver);
        // Dan is not a token receiver
        dan = makeAddr("dan");
        vm.assume(dan.code.length == 0);
        // Eve is an incorrect receiver
        eveReceiver = new ERC721IncorrectReceiver("eve");
        eve = address(eveReceiver);
        _;
    }

    /*
    Provide tokens owned by a user.
    */

    modifier dealAnOwnedTokenToAlice(uint256 tokenId) {
        (bool success, string memory reason) = _dealERC721Token(alice, tokenId);
        conditionalSkip(!success, reason);
        _;
    }

    function _dealAnOwnedTokenToAlice(uint256 tokenId) internal {
        _dealERC721Token(alice, tokenId);
    }

    modifier dealAnOwnedTokenToCustomer(address customer, uint256 tokenId) {
        (bool success, string memory reason) = _dealERC721Token(customer, tokenId);
        conditionalSkip(!success, reason);
        _;
    }

    modifier dealSeveralOwnedTokensToAlice(uint256[3] memory tokenIds) {
        (bool success, string memory reason) = _dealSeveralOwnedTokensToCustomer(alice, tokenIds);
        conditionalSkip(!success, reason);
        _;
    }

    function _dealSeveralOwnedTokensToAlice(uint256[3] memory tokenIds) 
    internal {
        _dealSeveralOwnedTokensToCustomer(alice, tokenIds);
    }

    function _dealSeveralOwnedTokensToCustomer(address customer, uint256[3] memory tokenIds) 
    internal returns (bool, string memory) {
        for (uint8 i = 0; i < tokenIds.length; i++) {
            (bool success, string memory reason) = _dealERC721Token(customer, tokenIds[i]);
            if (!success) {
                return (false, reason);
            }
        }
        return (true, "");
    }

    // This modifier ensures that the provided address is not an address implementing the ERC721Receiver interface.
    // We currently have 3 addresses that do this: alice, bob, and carol
    modifier ensureNotATokenReceiver(address _address) {
        vm.assume(_address != address(0x0));
        vm.assume(_address.code.length == 0);
        _;
    }

    /****************************
    *
    General helper functions
    *
    ****************************/

    function _getSelector(string calldata _func) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function _hasOwner(uint256 tokenId) internal view returns (bool) {
        try cut.ownerOf(tokenId) returns (address owner) {
            if (owner != address(0x0)) {
                return true;
            }
            else {
                return false;
            }
        }
        catch {
            return false;
        }
    }

    /****************************
    *
    Deal tokens
    *
    ****************************/
    
    function _dealERC721Token(address tokenReceiver, uint256 tokenId) 
    internal returns (bool, string memory) {
        try this.externalDealERC721(address(cut), tokenReceiver, tokenId) {
            (, address newOwner) = _tryOwnerOf(tokenId);
            if (newOwner == tokenReceiver) {
                return (true, "");
            }
            else {
                return _tryOwnerTransferFromToReceiver(tokenReceiver, tokenId);
            }
        } catch {
            return _tryOwnerTransferFromToReceiver(tokenReceiver, tokenId);
        }
    }

    function externalDealERC721(address token, address tokenReceiver, uint256 tokenId) external {
        dealERC721(token, tokenReceiver, tokenId);
    }

    function _tryOwnerTransferFromToReceiver(address tokenReceiver, uint256 tokenId) 
    internal returns (bool, string memory) {
        (bool success, address owner) = _tryOwnerOf(tokenId);
        if (!success || owner == address(0x0)) {
            return (false, "Failed to retrieve a tokenId with non-zero address owner to deal.");
        }
        _tryCustomerTransferFrom(owner, owner, tokenReceiver, tokenId);
        (, address newOwner) = _tryOwnerOf(tokenId);
        if (newOwner == tokenReceiver) {
            return (true, "");
        }
        else {
            return (false, "The owner of a non-zero tokenId cannot call `transferFrom` to tokenReceiver.");
        }
    }


    /****************************
    *
    * Safe versions of functions.
    *
    ****************************/

    /// @notice Safe version of ownerOf where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryOwnerOf(uint256 tokenId) 
    internal returns (bool, address) {
        bytes memory callReturnData = abi.encodeWithSelector(cut.ownerOf.selector, tokenId);
        (bool success, bytes memory returnData) = address(cut).call(callReturnData);
        address returnValue = address(0x0);
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (address));
        }
        return (success, returnValue);
    }

    /// @notice Safe version of balanceOf where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryBalanceOf(address account) 
    internal returns (bool, uint256) {
        bytes memory callReturnData = abi.encodeWithSelector(cut.balanceOf.selector, account);
        (bool success, bytes memory returnData) = address(cut).call(callReturnData);
        uint256 returnValue = 0;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return (success, returnValue);
    }
    
    /// @notice Safe version of safeTransferFrom with data where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _trySafeTransferFromWithData(address tokenSender, address tokenReceiver, uint256 tokenId, bytes memory data)
    internal returns (CallResult memory) {
        bytes memory callReturnData = abi.encodeWithSignature("safeTransferFrom(address,address,uint256,bytes)", tokenSender, tokenReceiver, tokenId, data);
        return _callOptionalReturn(callReturnData);
    }

    /// @notice Safe version of safeTransferFrom without data where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _trySafeTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        bytes memory callReturnData = abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", tokenSender, tokenReceiver, tokenId);
        return _callOptionalReturn(callReturnData);
    }

    /// @notice Safe version of transferFrom where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        bytes memory callReturnData = abi.encodeWithSignature("transferFrom(address,address,uint256)", tokenSender, tokenReceiver, tokenId);
        return _callOptionalReturn(callReturnData);
    }

    /// @notice Safe version of approve where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryApprove(address approvee, uint256 tokenId)
    internal returns (CallResult memory) {
        bytes memory  callReturnData = abi.encodeWithSelector(cut.approve.selector, approvee, tokenId);
        return _callOptionalReturn(callReturnData);
    }

    /// @notice Safe version of getApproved where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    /// @notice Safe version of getApproved where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryGetApproved(uint256 tokenId) 
    internal returns (bool, address) {
        bytes memory callReturnData = abi.encodeWithSelector(cut.getApproved.selector, tokenId);
        (bool success, bytes memory returnData) = address(cut).call(callReturnData);
        address returnValue = address(0x0);
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (address));
        }
        return (success, returnValue);

    }

    /// @notice Safe version of isApprovedForAll where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _tryIsApprovedForAll(address owner, address operator) 
    internal returns (bool, bool) {
        bytes memory callReturnData = abi.encodeWithSelector(cut.isApprovedForAll.selector, owner, operator);
        (bool success, bytes memory returnData) = address(cut).call(callReturnData);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /// @notice Safe version of setApprovalForAll where it never reverts but always returns a bool to signal success.
    /// @dev The function performs low-level external call to the test-subject contract and 
    /// manually evaluate the success state and return value (if any) of the call.
    function _trySetApprovalForAll(address approvee, bool direction) 
    internal returns (CallResult memory) {
        bytes memory callReturnData = abi.encodeWithSelector(cut.setApprovalForAll.selector, approvee, direction);
        return _callOptionalReturn(callReturnData);
    }
    
    /****************************
    *
    * Internal helper functions.
    *
    ****************************/

    function _callOptionalReturn(bytes memory data) 
    internal returns (CallResult memory) {
        return _callOptionalReturn(address(cut), data);
    }

    /* Arbitrary customer abstractions */

    // ownerOf

    /// @notice Abstracts away an owner request made by a `customer` on a `tokenId`.
    function _tryCustomerOwnerOf(address customer, uint256 tokenId)
    internal returns (bool, address) {
        vm.startPrank(customer);
        (bool success, address result) = _tryOwnerOf(tokenId);
        vm.stopPrank();
        return (success, result);
    }

    // balanceOf

    /// @notice Abstracts away a balance request made by a `customer` on an `account`.
    function _tryCustomerBalanceOf(address customer, address account)
    internal returns (bool, uint256) {
        vm.startPrank(customer);
        (bool success, uint256 result) = _tryBalanceOf(account);
        vm.stopPrank();
        return (success, result);
    }

    // safeTansferFrom with data

    /// @notice Abstracts away a safeTansferFrom made by a `customer` with data.
    function _tryCustomerSafeTransferFromWithData(address customer, address tokenSender, address tokenReceiver, uint256 tokenId, bytes memory data)
    internal returns (CallResult memory) {
        vm.startPrank(customer);
        CallResult memory result = _trySafeTransferFromWithData(tokenSender, tokenReceiver, tokenId, data);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a safeTansferFrom made by Alice with data.
    function _tryAliceSafeTransferFromWithData(address tokenSender, address tokenReceiver, uint256 tokenId, bytes memory data)
    internal returns (CallResult memory) {
        return _tryCustomerSafeTransferFromWithData(alice, tokenSender, tokenReceiver, tokenId, data);
    }

    /// @notice Abstracts away a safeTansferFrom made by Bob with data.
    function _tryBobSafeTransferFromWithData(address tokenSender, address tokenReceiver, uint256 tokenId, bytes memory data)
    internal returns (CallResult memory) {
        return _tryCustomerSafeTransferFromWithData(bob, tokenSender, tokenReceiver, tokenId, data);
    }

    // safeTansferFrom without data

    /// @notice Abstracts away a safeTansferFrom made by a `customer` without data.
    function _tryCustomerSafeTransferFrom(address customer, address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        vm.startPrank(customer);
        CallResult memory result = _trySafeTransferFrom(tokenSender, tokenReceiver, tokenId);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a safeTansferFrom made by Alice without data.
    function _tryAliceSafeTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerSafeTransferFrom(alice, tokenSender, tokenReceiver, tokenId);
    }

    /// @notice Abstracts away a safeTansferFrom made by Bob without data.
    function _tryBobSafeTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerSafeTransferFrom(bob, tokenSender, tokenReceiver, tokenId);
    }

    // tansferFrom

    /// @notice Abstracts away a tansferFrom made by a `customer` without data.
    function _tryCustomerTransferFrom(address customer, address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        vm.startPrank(customer);
        CallResult memory result = _tryTransferFrom(tokenSender, tokenReceiver, tokenId);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a safeTansferFrom made by Alice with data.
    function _tryAliceTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerTransferFrom(alice, tokenSender, tokenReceiver, tokenId);
    }

    /// @notice Abstracts away a safeTansferFrom made by Bob with data.
    function _tryBobTransferFrom(address tokenSender, address tokenReceiver, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerTransferFrom(bob, tokenSender, tokenReceiver, tokenId);
    }

    // approve
    
    /// @notice Abstracts away an approve made by a `customer`.
    function _tryCustomerApprove(address customer, address approvee, uint256 tokenId)
    internal returns (CallResult memory) {
        vm.startPrank(customer);
        CallResult memory result = _tryApprove(approvee, tokenId);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away a transferFrom made by Alice.
    function _tryAliceApprove(address approvee, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerApprove(alice, approvee, tokenId);
    }

    /// @notice Abstracts away a transferFrom made by Bob.
    function _tryBobApprove(address approvee, uint256 tokenId)
    internal returns (CallResult memory) {
        return _tryCustomerApprove(bob, approvee, tokenId);
    }

    // getApproved

    /// @notice Abstracts away a query of the approved address made by a `customer` on an `tokenId`.
    function _tryCustomerGetApproved(address customer, uint256 tokenId)
    internal returns (bool, address) {
        vm.startPrank(customer);
        (bool success, address result) = _tryGetApproved(tokenId);
        vm.stopPrank();
        return (success, result);
    }

     // isApprovedForAll

    /// @notice Abstracts away a query of whether some `operator` has approval over `owner` made by a `customer`.
    function _tryCustomerIsApprovedForAll(address customer, address owner, address operator)
    internal returns (bool, bool) {
        vm.startPrank(customer);
        (bool success, bool result) = _tryIsApprovedForAll(owner, operator);
        vm.stopPrank();
        return (success, result);
    }

    // setApprovedForAll

    /// @notice Abstracts away setting some `approvee` on some `direction` by Alice.
    function _tryAliceSetApprovalForAll(address approvee, bool direction)
    internal returns (CallResult memory) {
        vm.startPrank(alice);
        CallResult memory result = _trySetApprovalForAll(approvee, direction);
        vm.stopPrank();
        return result;
    }

    /// @notice Abstracts away setting some `approvee` on some `direction`by an `approver`.
    function _tryCustomerSetApprovalForAll(address approver, address approvee, bool direction)
    internal returns (CallResult memory) {
        vm.startPrank(approver);
        CallResult memory result = _trySetApprovalForAll(approvee, direction);
        vm.stopPrank();
        return result;
    }

    // Combined actions

    // - Using safeTransferFrom (with data)

    function _AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(uint256 tokenId, bytes memory data, address approvee, address tokenReceiver) internal returns (bool) {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(approvee, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll to the approvee.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(approvee, alice, tokenReceiver, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to token receiver.");
        return true;
    }

    function _AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(uint256 tokenId, bytes memory data, address tokenReceiver) internal returns (bool) {
        return _AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(tokenId, data, bob, tokenReceiver);
    }

    function _AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(uint256 tokenId, bytes memory data) internal returns (bool) {
        return _AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(tokenId, data, bob);
    }
    
    function _AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToCarol(uint256 tokenId, bytes memory data) internal returns (bool) {
        return _AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(tokenId, data, carol);
    }

    // - Using safeTransferFrom (without data)

    function _AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(uint256 tokenId, address approvee, address tokenReceiver) internal returns (bool) {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(approvee, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll to the approvee.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(approvee, alice, tokenReceiver, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to token receiver.");
        return true;
    }

    function _AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(uint256 tokenId, address tokenReceiver) internal returns (bool) {
        return _AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, bob, tokenReceiver);
    }

    function _AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(uint256 tokenId) internal returns (bool) {
        return _AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(tokenId, bob);
    }

    // - Using transferFrom (without data)

    function _AliceSetApprovedForAllCustomerAndCustomerTransfersFromToSomeone(uint256 tokenId, address approvee, address tokenReceiver) internal returns (bool) {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(approvee, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll to the approvee.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(approvee, alice, tokenReceiver, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not transferFrom from Alice to token receiver.");
        return true;
    }

    function _AliceSetApprovedForAllBobAndBobTransfersFromToSomeone(uint256 tokenId, address tokenReceiver) internal returns (bool) {
        return _AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, bob, tokenReceiver);
    }

    function _AliceSetApprovedForAllBobAndBobTransfersFromToSelf(uint256 tokenId) internal returns (bool) {
        return _AliceSetApprovedForAllBobAndBobTransfersFromToSomeone(tokenId, bob);
    }

}
