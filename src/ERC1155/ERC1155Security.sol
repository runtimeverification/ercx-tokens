// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC1155Abstract.sol";

/// @notice Abstract contract that consists of the security properties, including desirable properties for the sane functioning of the token and properties
/// of add-on functions commonly created and used by ERC1155 developers.
abstract contract ERC1155Security is ERC1155Abstract {

    /***********************************************************************************
    * Glossary                                                                         *
    * -------------------------------------------------------------------------------- *
    * tokenId       : ID of a token                                                    *
    * tokenIds      : array of token ids (usually pair with tokenAmounts)              *
    * tokenAmount   : amount of tokens of some tokenId                                 *
    * tokenAmounts  : array of token amounts (usually pair with tokenIds)              *
    * tokenOwner    : address that owns tokens of some provided tokenId/tokenIds       *
    * tokenOwners   : array of token owners                                            *
    * tokenReceiver : address that will receive the token/s                            *
    ***********************************************************************************/

    /*******************************************/
    /*******************************************/
    /* Tests related to desirable properties. */
    /*******************************************/
    /*******************************************/

    /****************************
    *
    * safeTransferFrom desirable checks.
    *
    ****************************/

    /// @notice A `safeTransferFrom` call MUST revert if the `from` address, i.e., tokenOwner, is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call does NOT revert even if the `from` address, i.e., tokenOwner, is the zero address
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories single transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromRevertsIfFromIsZeroAddress(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external 
    {
        address zeroAddress = address(0);
        vm.assume(tokenAmount <= tokenBalance);
        _dealUserSingleNft(zeroAddress, tokenId, tokenBalance);
        _tryCustomerSetApprovalForAll(zeroAddress, alice, true);
        // Note: No condition check for the above call as regardless if the zero address can call `setApprovalForAll`,
        // we still need to check if the safeTransferFrom call would still fail if the zero address is the tokenOwner.
        (bool callSuccess,) = _tryCustomerCallsSafeTransferFrom(alice, zeroAddress, bob, tokenId, tokenAmount, data);
        assertFalse(callSuccess, "Alice can call `safeTransferFrom` with `from` address == zero address.");
    }

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for an EOA tokenReceiver as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call does NOT increase the tokenBalance of tokenId for an EOA tokenReceiver as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseEoaReceiverBalanceAsExpected(uint256 tokenId, uint256 aliceTokenBalance, uint256 bobTokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealTwoUsersSingleNfts(tokenId, aliceTokenBalance, tokenId, bobTokenBalance)
    {
        _propertySafeTransferFromIncreaseReceiverBalance(false, ArithmeticOperator.Equal, tokenId, aliceTokenBalance, bobTokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to an EOA tokenReceiver decreases the tokenBalance of tokenId for tokenOwner as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to an EOA tokenReceiver does NOT decrease the tokenBalance of tokenId for tokenOwner as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToEoaDecreaseOwnerBalanceAsExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(false, ArithmeticOperator.Equal, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for a contract tokenReceiver as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call does NOT increase the tokenBalance of tokenId for a contract tokenReceiver as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseContractReceiverBalanceAsExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        _propertySafeTransferFromIncreaseReceiverBalance(true, ArithmeticOperator.Equal, tokenId, tokenBalance, 0, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to a contract tokenReceiver decreases the tokenBalance of tokenId for tokenOwner as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to a contract tokenReceiver does NOT decrease the tokenBalance of tokenId for tokenOwner as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance, contract receiver 
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToContractDecreaseOwnerBalanceAsExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(true, ArithmeticOperator.Equal, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice The tokenBalance of any tokenId DOES NOT change after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The tokenBalance of any tokenId changes after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSelfSafeTransferFromSelfToSelfDoesNotChangeOwnerBalance(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySelfSafeTransferFromSelfToSelfChangeOwnerBalance(ArithmeticOperator.Equal, tokenId, tokenBalance, tokenAmount, data);
    }


    /****************************
    *
    * safeBatchTransferFrom desirable checks.
    *
    ****************************/

    /// @notice A `safeBatchTransferFrom` call MUST revert if the `from` address, i.e., tokenOwner, is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call does NOT revert even if the `from` address, i.e., tokenOwner, is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories batch transfer, zero address
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromRevertsIfFromIsZeroAddress(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external 
    {
        address zeroAddress = address(0);
        _dealUserBatchNft(zeroAddress, tokenIds, tokenBalances);
        _tryCustomerSetApprovalForAll(zeroAddress, alice, true);
        // Note: No condition check for the above call as regardless if the zero address can call `setApprovalForAll`,
        // we still need to check if the safeBatchTransferFrom call would still fail if the zero address is the tokenOwner.
        (bool callSuccess,) = _tryCustomerCallsSafeBatchTransferFrom(alice, zeroAddress, bob, tokenIds, tokenBalances, data);
        assertFalse(callSuccess, "Alice can call `safeBatchTransferFrom` with `from` address == zero address.");
    }

    /// @notice A successful `safeBatchTransferFrom` call increases the tokenBalances of tokenIds for an EOA tokenReceiver as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` call does NOT increase the tokenBalance of tokenId for an EOA tokenReceiver as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, balance
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromIncreaseEoaReceiverBalancesAsExpected(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertySafeBatchTransferFromIncreaseReceiverBalancesAsExpected(false, tokenIds, tokenBalances, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call to an EOA tokenReceiver decreases the tokenBalances of tokenIds for tokenOwner as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` call to an EOA tokenReceiver does NOT decrease the tokenBalances of tokenIds for tokenOwner as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, balance
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromToEoaDecreaseOwnerBalancesAsExpected(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertySafeBatchTransferFromDecreaseOwnerBalancesAsExpected(false, tokenIds, tokenBalances, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call increases the tokenBalances of tokenIds for a contract tokenReceiver as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` call does NOT increase the tokenBalances of tokenIds for a contract tokenReceiver as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, balance, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromIncreaseContractReceiverBalancesAsExpected(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances) {
        _propertySafeBatchTransferFromIncreaseReceiverBalancesAsExpected(true, tokenIds, tokenBalances, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call to a contract tokenReceiver decreases the tokenBalances of tokenIds for tokenOwner as expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` call to a contract tokenReceiver does NOT decrease the tokenBalances of tokenIds for tokenOwner as expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, balance, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromToContractDecreaseOwnerBalancesAsExpected(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertySafeBatchTransferFromDecreaseOwnerBalancesAsExpected(true, tokenIds, tokenBalances, data);
    }

    /// @notice The tokenBalances of tokenIds DO NOT change after a successful `safeBatchTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The tokenBalances of tokenIds change after a successful `safeBatchTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, balance
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSelfSafeBatchTransferFromSelfToSelfDoNotChangeOwnerBalances(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        (bool callSuccess, ) = _tryAliceCallsSafeBatchTransferFrom(alice, alice, tokenIds, tokenBalances, data);
        // Check if Alice can call `safeBatchTransferFrom` from her own account without approval
        // As this is a recommended property but not mandatory, we need the branch if this safeTransferFrom call fails.
        // If Alice cannot call `safeBatchTransferFrom` from her own account without approval,
        // then try calling `setApprovalForAll` to herself
        if (!callSuccess) {
            (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(alice, true);
            // Skip the test if the setApprovalForAll call fails
            conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to herself.");
            (bool callSuccessAgain, ) = _tryAliceCallsSafeBatchTransferFrom(alice, alice, tokenIds, tokenBalances, data);
            // Skip the test if the safeBatchTransferFrom call fails
            conditionalSkip(!callSuccessAgain, "Inconclusive test: Calling `safeBatchTransferFrom` from Alice to herself by herself reverts unexpectedly.");
        }
        for (uint8 i = 0; i < 3; i++) {
            assertEq(cut1155.balanceOf(alice, tokenIds[i]), tokenBalances[i], "Some tokenBalance of tokenId for Alice does not decrease as expected.");
        }
    }


    /****************************
    *
    * balanceOfBatch desirable checks.
    *
    ****************************/

    /// @notice A `balanceOfBatch` call reverts if the length of accounts is not the same
    /// as the length of the tokenIds.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `balanceOfBatch` call does not revert even when the length of accounts is not the same
    /// as the length of the tokenIds.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOfBatch
    function testBalanceOfBatchUnequalArrayLengthsReverts(uint256 tokenId1, uint256 tokenId2) external {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = tokenId1;
        tokenIds[1] = tokenId2;
        bytes memory data = abi.encodeWithSelector(cut1155.balanceOfBatch.selector, accountsNoOwner, tokenIds);
        (bool success, ) = address(cut1155).call(data);
        assertFalse(success);
    }


    /****************************
    *
    * setApprovalForAll desirable checks.
    *
    ****************************/

    /// @notice Calling of `setApprovalForAll` with `operator` set to the zero address MUST revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling of `setApprovalForAll` with `operator` set to the zero address does not revert.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function setApprovalForAll
    function testSetApprovalForAllRevertsIfOperatorIsZeroAddress(bool approval) external 
    {
        (bool success, ) = _tryAliceSetApprovalForAll(address(0), approval);
        assertFalse(success, "Calling of `setApprovalForAll` with `operator` set to the zero address does not revert.");
    }


    /****************************
    *
    * Internal helper functions for Desirable tests.
    *
    ****************************/

    /// @notice Internal function to check if a successful `safeBatchTransferFrom` call increases the tokenBalances of tokenIds for an EOA or a contract tokenReceiver (via `toContract`) as expected.
    function _propertySafeBatchTransferFromIncreaseReceiverBalancesAsExpected(bool toContract, uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    internal
    {
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, true);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155Received` return
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        }
        else {
            toAddress = carol;
        }
        (bool callSuccess, ) = _tryBobCallsSafeBatchTransferFrom(alice, toAddress, tokenIds, tokenBalances, data);
        // Skip the test if the safeBatchTransferFrom call fails
        conditionalSkip(!callSuccess, "Inconclusive test: Calling `safeBatchTransferFrom` from Alice to tokenReceiver by Bob reverts unexpectedly.");
        for (uint8 i = 0; i < 3; i++) {
            assertEq(cut1155.balanceOf(toAddress, tokenIds[i]), tokenBalances[i], "Some tokenBalance of tokenId for the receiver does not increase as expected.");
        }
    }

    /// @notice Internal function to check if a successful `safeBatchTransferFrom` call to an EOA or a contract tokenReceiver (via `toContract`) decreases the tokenBalances of tokenIds for tokenOwner as expected.
    function _propertySafeBatchTransferFromDecreaseOwnerBalancesAsExpected(bool toContract, uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    internal 
    {
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, true);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155Received` return
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        }
        else {
            toAddress = carol;
        }
        (bool callSuccess, ) = _tryBobCallsSafeBatchTransferFrom(alice, toAddress, tokenIds, tokenBalances, data);
        // Skip the test if the safeBatchTransferFrom call fails
        conditionalSkip(!callSuccess, "Inconclusive test: Calling `safeBatchTransferFrom` from Alice to tokenReceiver by Bob reverts unexpectedly.");        
        for (uint8 i = 0; i < 3; i++) {
            assertEq(cut1155.balanceOf(alice, tokenIds[i]), 0, "Some tokenBalance of tokenId for Alice does not decrease as expected.");
        }
    }

}