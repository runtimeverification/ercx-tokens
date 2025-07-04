// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERCAbstract.sol";
import {IERC1155} from "openzeppelin-contracts/token/ERC1155/IERC1155.sol";
import {IERC1155Receiver} from "openzeppelin-contracts/token/ERC1155/IERC1155Receiver.sol";
import {ERC1155ReceiverMock} from "openzeppelin-contracts/mocks/token/ERC1155ReceiverMock.sol";

/// @notice Abstract contract that defines internal functions that are used in ERC1155 test suite
abstract contract ERC1155Abstract is ERCAbstract {
    /**
     *
     * Glossary                                                                         *
     * -------------------------------------------------------------------------------- *
     * tokenId       : ID of a token                                                    *
     * tokenIds      : array of token ids (usually pair with tokenAmounts)              *
     * tokenAmount   : amount of tokens of some tokenId                                 *
     * tokenAmounts  : array of token amounts (usually pair with tokenIds)              *
     * tokenOwner    : address that owns tokens of some provided tokenId/tokenIds       *
     * tokenOwners   : array of token owners                                            *
     * tokenReceiver : address that will receive the token/s                            *
     *
     */

    /**
     *
     *
     * Declaration of state variables and events
     *
     *
     */
    enum ArithmeticOperator {
        Equal,
        Lesser,
        Greater
    }

    // IERC1155 interface from Openzeppelin
    IERC1155 public cut1155;

    // Some events, expected to be emitted from the contract.
    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );
    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function init(address token) internal virtual {
        cut1155 = IERC1155(token);
    }

    /**
     *
     *
     * Initialization modifier
     *
     *
     */

    /// @notice Deal `tokenBalance` amount of NFT with `tokenId` for alice.
    modifier dealAliceSingleNft(uint256 tokenId, uint256 tokenBalance) {
        _dealUserSingleNft(alice, tokenId, tokenBalance);
        _;
    }

    /// @notice Deal `tokenBalance` amount of NFT with `tokenId` for bob.
    modifier dealBobSingleNft(uint256 tokenId, uint256 tokenBalance) {
        _dealUserSingleNft(bob, tokenId, tokenBalance);
        _;
    }

    /// @notice Deal `tokenBalance1` and `tokenBalance2` amounts of NFTs with `tokenId1` and `tokenId2` for alice and bob.
    modifier dealTwoUsersSingleNfts(uint256 tokenId1, uint256 tokenBalance1, uint256 tokenId2, uint256 tokenBalance2) {
        if (tokenId1 == tokenId2) {
            vm.assume(tokenBalance1 < MAX_UINT256 - tokenBalance2);
        }
        _dealUserSingleNft(alice, tokenId1, tokenBalance1);
        _dealUserSingleNft(bob, tokenId2, tokenBalance2);
        _;
    }

    /// @notice Internal function to deal user single NFT
    function _dealUserSingleNft(address user, uint256 tokenId, uint256 tokenBalance) internal {
        vm.assume(tokenId < MAX_UINT96); // restrict the ID num as some ERC1155 tokens do not allow high ID num
        dealERC1155(address(cut1155), user, tokenId, tokenBalance);
        conditionalSkip(
            cut1155.balanceOf(user, tokenId) != tokenBalance,
            "Inconclusive test: Issue with dealing NFTs to dummy user."
        );
    }

    /// @notice Deal amounts of NFTs in array `tokenBalances` with batch IDs in array `tokenIds` for alice.
    modifier dealAliceBatchNft(uint256[3] memory tokenIds, uint256[3] memory tokenBalances) {
        _dealUserBatchNft(alice, tokenIds, tokenBalances);
        _;
    }

    /// @notice Deal amounts of NFTs in array `tokenBalances` with batch IDs in array `tokenIds` for bob.
    modifier dealBobBatchNft(uint256[3] memory tokenIds, uint256[3] memory tokenBalances) {
        _dealUserBatchNft(bob, tokenIds, tokenBalances);
        _;
    }

    /// @notice Deal amounts of NFTs in arrays with batch IDs in arrays for alice and bob.
    modifier dealTwoUsersBatchNft(
        uint256[3] memory tokenIds1,
        uint256[3] memory tokenBalances1,
        uint256[3] memory tokenIds2,
        uint256[3] memory tokenBalances2
    ) {
        // Dealing NFTs to alice
        _dealUserBatchNft(alice, tokenIds1, tokenBalances1);
        // Dealing NFTs to bob
        // note: Cannot use _dealUserBatchNft(bob, tokenIds, tokenBalances) as we need the extra condition
        // that in case Alice has balance of some tokenId in tokenIds2
        // Make sure the IDs are different
        vm.assume(tokenIds2[0] != tokenIds2[1]);
        vm.assume(tokenIds2[0] != tokenIds2[2]);
        vm.assume(tokenIds2[1] != tokenIds2[2]);
        for (uint8 i = 0; i < 3; i++) {
            // in the event that Alice has balance of some tokenId in tokenIds2
            vm.assume(tokenBalances2[i] < MAX_UINT256 - cut1155.balanceOf(alice, tokenIds2[i]));
            _dealUserSingleNft(bob, tokenIds2[i], tokenBalances2[i]);
        }
        _;
    }

    /// @notice Internal function to deal user batch NFTs
    function _dealUserBatchNft(address user, uint256[3] memory tokenIds, uint256[3] memory tokenBalances) internal {
        // Make sure the IDs are different
        vm.assume(tokenIds[0] != tokenIds[1]);
        vm.assume(tokenIds[0] != tokenIds[2]);
        vm.assume(tokenIds[1] != tokenIds[2]);
        for (uint8 i = 0; i < 3; i++) {
            _dealUserSingleNft(user, tokenIds[i], tokenBalances[i]);
        }
    }

    /**
     *
     *
     * Internal helper functions.
     *
     *
     */

    /// @notice Convert static array (length 3) of uint256 values to dynamic arrays
    function _convertLength3Uint256ArrayFromStaticToDynamic(uint256[3] memory array)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory _array = new uint256[](3);
        for (uint8 i = 0; i < 3; i++) {
            _array[i] = array[i];
        }
        return _array;
    }

    /// @notice Convert static array (length 3) of address values to dynamic arrays
    function _convertLength3AddressArrayFromStaticToDynamic(address[3] memory array)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory _array = new address[](3);
        for (uint8 i = 0; i < 3; i++) {
            _array[i] = array[i];
        }
        return _array;
    }

    /// @notice Set up contract receiver
    /// @dev if _correctRecRecVal is set to true, then set _otherRecRetVal to bytes4(0).
    /// Otherwise, include an additional "bytes4 _otherRecRetVal" input for the test function and
    /// let the fuzz mechanism take care of the random bytes4 return value.
    /// Same goes for _correctBatRetVal and _otherBatRetVal.
    /// @dev If _recReverts set to true, then the contract receiver will always revert when receiving tokens.
    /// Same goes for _batReverts.
    function _setUpReceiverContract(
        bool _correctRecRetVal,
        bytes4 _otherRecRetVal,
        bool _recReverts,
        bool _correctBatRetVal,
        bytes4 _otherBatRetVal,
        bool _batReverts
    ) internal returns (IERC1155Receiver) {
        bytes4 _recRetval;
        bytes4 _batRetval;
        // if _correctRecRecVal is set to true, the receiver contract will return the correct
        // bytes4 return value, which is `onERC1155Received(address,address,uint256,uint256,bytes)`
        if (_correctRecRetVal) {
            _recRetval = IERC1155Receiver.onERC1155Received.selector;
        }
        // otherwise, the return value will be set `_otherRecRetVal` as provided in the input
        else {
            // assumption that the provided `_otherRecRetVal != onERC1155Received(address,address,uint256,uint256,bytes)`
            vm.assume(_otherRecRetVal != IERC1155Receiver.onERC1155Received.selector);
            _recRetval = _otherRecRetVal;
        }
        // if _correctBatRecVal is set to true, the receiver contract will return the correct
        // bytes4 return value, which is `onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`
        if (_correctBatRetVal) {
            _batRetval = IERC1155Receiver.onERC1155BatchReceived.selector;
        } else {
            // assumption that the provided `_otherBatRetVal != onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`
            vm.assume(_otherBatRetVal != IERC1155Receiver.onERC1155BatchReceived.selector);
            _batRetval = _otherBatRetVal;
        }
        // Set up the receiver contract accordingly and return it as output
        ERC1155ReceiverMock receiverContract = new ERC1155ReceiverMock(_recRetval, _recReverts, _batRetval, _batReverts);
        return IERC1155Receiver(address(receiverContract));
    }

    function _tryAliceSetApprovalForAll(address _operator, bool _approved) internal returns (bool, bool) {
        return _tryCustomerSetApprovalForAll(alice, _operator, _approved);
    }

    function _tryBobSetApprovalForAll(address _operator, bool _approved) internal returns (bool, bool) {
        return _tryCustomerSetApprovalForAll(bob, _operator, _approved);
    }

    function _tryCustomerSetApprovalForAll(address _customer, address _operator, bool _approved)
        internal
        returns (bool, bool)
    {
        vm.startPrank(_customer);
        (bool success, bool result) = _trySetApprovalForAll(_operator, _approved);
        vm.stopPrank();
        return (success, result);
    }

    function _trySetApprovalForAll(address _operator, bool _approved) internal returns (bool, bool) {
        bytes memory data = abi.encodeWithSelector(cut1155.setApprovalForAll.selector, _operator, _approved);
        (bool success, bytes memory returnData) = address(cut1155).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    function _tryAliceCallsSafeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) internal returns (bool, bool) {
        return _tryCustomerCallsSafeTransferFrom(alice, _from, _to, _id, _value, _data);
    }

    function _tryBobCallsSafeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
        internal
        returns (bool, bool)
    {
        return _tryCustomerCallsSafeTransferFrom(bob, _from, _to, _id, _value, _data);
    }

    function _tryCustomerCallsSafeTransferFrom(
        address _customer,
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) internal returns (bool, bool) {
        vm.startPrank(_customer);
        (bool success, bool result) = _trySafeTransferFrom(_from, _to, _id, _value, _data);
        vm.stopPrank();
        return (success, result);
    }

    function _trySafeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
        internal
        returns (bool, bool)
    {
        // Note: For the following line, we cannot use `abi.encodeWithSelector` as it clashes with ERC-721 safeTransferFrom
        bytes memory data = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)", _from, _to, _id, _value, _data
        );
        (bool success, bytes memory returnData) = address(cut1155).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    function _tryAliceCallsSafeBatchTransferFrom(
        address _from,
        address _to,
        uint256[3] memory _ids,
        uint256[3] memory _values,
        bytes calldata _data
    ) internal returns (bool, bool) {
        return _tryCustomerCallsSafeBatchTransferFrom(alice, _from, _to, _ids, _values, _data);
    }

    function _tryBobCallsSafeBatchTransferFrom(
        address _from,
        address _to,
        uint256[3] memory _ids,
        uint256[3] memory _values,
        bytes calldata _data
    ) internal returns (bool, bool) {
        return _tryCustomerCallsSafeBatchTransferFrom(bob, _from, _to, _ids, _values, _data);
    }

    function _tryCustomerCallsSafeBatchTransferFrom(
        address _customer,
        address _from,
        address _to,
        uint256[3] memory _ids,
        uint256[3] memory _values,
        bytes calldata _data
    ) internal returns (bool, bool) {
        vm.startPrank(_customer);
        (bool success, bool result) = _trySafeBatchTransferFrom(_from, _to, _ids, _values, _data);
        vm.stopPrank();
        return (success, result);
    }

    function _trySafeBatchTransferFrom(
        address _from,
        address _to,
        uint256[3] memory _ids,
        uint256[3] memory _values,
        bytes calldata _data
    ) internal returns (bool, bool) {
        uint256[] memory _dynamicIds = _convertLength3Uint256ArrayFromStaticToDynamic(_ids);
        uint256[] memory _dynamicValues = _convertLength3Uint256ArrayFromStaticToDynamic(_values);
        bytes memory data = abi.encodeWithSelector(
            cut1155.safeBatchTransferFrom.selector, _from, _to, _dynamicIds, _dynamicValues, _data
        );
        (bool success, bytes memory returnData) = address(cut1155).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    function _trySafeBatchTransferFromDynamic(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes calldata _data
    ) internal returns (bool, bool) {
        bytes memory data =
            abi.encodeWithSelector(cut1155.safeBatchTransferFrom.selector, _from, _to, _ids, _values, _data);
        (bool success, bytes memory returnData) = address(cut1155).call(data);
        bool returnValue = false;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (bool));
        }
        return (success, returnValue);
    }

    /**
     *
     *
     * Internal helper functions for Desirable and Feature tests.
     *
     *
     */

    /// @notice Internal function that checks how a successful `safeTransferFrom` call
    /// increases the tokenBalance of tokenId for an EOA or a contract tokenReceiver
    /// (via `toContract`). It checks if the increase is as expected, lesser than expected,
    /// or more than expected, according to the operator in `arithmeticOperator`.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    function _propertySafeTransferFromIncreaseReceiverBalance(
        bool toContract,
        ArithmeticOperator arithmeticOperator,
        uint256 tokenId,
        uint256 tokenSenderBalance,
        uint256 tokenReceiverBalance,
        uint256 tokenAmount,
        bytes calldata data
    ) internal {
        vm.assume(tokenAmount <= tokenSenderBalance);
        (bool approvalSuccess,) = _tryAliceSetApprovalForAll(bob, true);
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155Received` return
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        } else {
            toAddress = bob;
        }
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        (bool callSuccess,) = _tryBobCallsSafeTransferFrom(alice, toAddress, tokenId, tokenAmount, data);
        // Skip the test if the safeTransferFrom call fails
        conditionalSkip(
            !callSuccess,
            "Inconclusive test: Calling `safeTransferFrom` from Alice to tokenReceiver by Bob reverts unexpectedly."
        );
        if (arithmeticOperator == ArithmeticOperator.Equal) {
            assertEq(
                cut1155.balanceOf(toAddress, tokenId),
                tokenReceiverBalance + tokenAmount,
                "Balance of tokenId for tokenReceiver does not increase as expected."
            );
        } else if (arithmeticOperator == ArithmeticOperator.Lesser) {
            assertLt(
                cut1155.balanceOf(toAddress, tokenId),
                tokenReceiverBalance + tokenAmount,
                "Balance of tokenId for tokenReceiver increases >= expected."
            );
        } else if (arithmeticOperator == ArithmeticOperator.Greater) {
            assertGt(
                cut1155.balanceOf(toAddress, tokenId),
                tokenReceiverBalance + tokenAmount,
                "Balance of tokenId for tokenReceiver increases <= expected."
            );
        }
    }

    /// @notice Internal function that checks how a successful `safeTransferFrom` call
    /// to an EOA or a contract tokenReceiver (via `toContract`) decreases tokenBalance
    /// of tokenId for tokenOwner. It checks if the decrease is as expected, lesser than expected,
    /// or more than expected, according to the operator in `arithmeticOperator`.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    function _propertySafeTransferFromDecreaseOwnerBalance(
        bool toContract,
        ArithmeticOperator arithmeticOperator,
        uint256 tokenId,
        uint256 tokenBalance,
        uint256 tokenAmount,
        bytes calldata data
    ) internal {
        vm.assume(tokenAmount <= tokenBalance);
        (bool approvalSuccess,) = _tryAliceSetApprovalForAll(bob, true);
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155Received` return
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        } else {
            toAddress = carol;
        }
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        (bool callSuccess,) = _tryBobCallsSafeTransferFrom(alice, toAddress, tokenId, tokenAmount, data);
        // Skip the test if the safeTransferFrom call fails
        conditionalSkip(
            !callSuccess,
            "Inconclusive test: Calling `safeTransferFrom` from Alice to tokenReceiver by Bob reverts unexpectedly."
        );
        if (arithmeticOperator == ArithmeticOperator.Equal) {
            assertEq(
                tokenBalance - cut1155.balanceOf(alice, tokenId),
                tokenAmount,
                "Balance of tokenId for Alice does not decrease as expected."
            );
        } else if (arithmeticOperator == ArithmeticOperator.Lesser) {
            assertLt(
                tokenBalance - cut1155.balanceOf(alice, tokenId),
                tokenAmount,
                "Balance of tokenId for Alice decreases >= expected."
            );
        } else if (arithmeticOperator == ArithmeticOperator.Greater) {
            assertGt(
                tokenBalance - cut1155.balanceOf(alice, tokenId),
                tokenAmount,
                "Balance of tokenId for Alice decreases <= expected."
            );
        }
    }

    /// @notice Internal function that checks how a successful `safeTransferFrom` call
    /// by tokenOwner from her account back to herself changes her tokenBalance
    /// of tokenId. It checks if the change is as expected, lesser than expected,
    /// or more than expected, according to the operator in `arithmeticOperator`.
    function _propertySelfSafeTransferFromSelfToSelfChangeOwnerBalance(
        ArithmeticOperator arithmeticOperator,
        uint256 tokenId,
        uint256 tokenBalance,
        uint256 tokenAmount,
        bytes calldata data
    ) internal {
        vm.assume(tokenAmount <= tokenBalance);
        (bool callSuccess,) = _tryAliceCallsSafeTransferFrom(alice, alice, tokenId, tokenAmount, data);
        // Check if Alice can call `safeTransferFrom` from her own account without approval
        // As this is a recommended property but not mandatory, we need the branch if this safeTransferFrom call fails.
        // If Alice cannot call `safeTransferFrom` from her own account without approval,
        // then try calling `setApprovalForAll` to herself
        if (!callSuccess) {
            (bool approvalSuccess,) = _tryAliceSetApprovalForAll(alice, true);
            // Skip the test if the setApprovalForAll call fails
            conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to herself.");
            (bool callSuccessAgain,) = _tryAliceCallsSafeTransferFrom(alice, alice, tokenId, tokenAmount, data);
            // Skip the test if the safeTransferFrom call fails
            conditionalSkip(
                !callSuccessAgain,
                "Inconclusive test: Calling `safeTransferFrom` from Alice to herself by herself reverts unexpectedly."
            );
        }
        // The following code entails the part where `safeTransferFrom` is called successfully as expected
        if (arithmeticOperator == ArithmeticOperator.Equal) {
            assertEq(
                cut1155.balanceOf(alice, tokenId), tokenBalance, "Balance of tokenId for Alice changes unexpectedly."
            );
        } else if (arithmeticOperator == ArithmeticOperator.Lesser) {
            assertLt(cut1155.balanceOf(alice, tokenId), tokenBalance, "Balance of tokenId for Alice does not decrease.");
        } else if (arithmeticOperator == ArithmeticOperator.Greater) {
            assertGt(cut1155.balanceOf(alice, tokenId), tokenBalance, "Balance of tokenId for Alice does not increase.");
        }
    }
}
