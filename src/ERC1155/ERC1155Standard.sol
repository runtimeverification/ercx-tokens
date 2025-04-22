// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC1155Abstract.sol";

/// @notice Abstract contract that consists of testing functions which test for properties from the standard
/// stated in the official EIP1155 specification.
abstract contract ERC1155Standard is ERC1155Abstract {

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

    /****************************
    *****************************
    *
    * MANDATORY checks.
    *
    *****************************
    ****************************/

    /****************************
    *
    * supportsInterface mandatory checks.
    *
    ****************************/

    /// @notice A `supportsInterface` call MUST be SUCCESSFUL and MUST return the constant value `true` if `0xd9b67a26` 
    /// is passed through the interfaceID argument.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback `supportsInterface` call MUST be SUCCESSFUL and MUST return the constant value `true` if `0xd9b67a26` 
    /// is passed through the interfaceID argument.
    /// @custom:ercx-categories eip165
    /// @custom:ercx-concerned-function supportsInterface
    function testSupportsInterfaceReturnsTrueWhenRequired() external {
        assertTrue(cut1155.supportsInterface(0xd9b67a26));
    }


    /****************************
    *
    * safeTransferFrom mandatory checks.
    *
    ****************************/

    /// @notice A `safeTransferFrom` call is SUCCESSFUL if the caller has been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalance of tokenId).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call is UNSUCCESSFUL even if the caller has been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalance of tokenId).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromSucceedsWhenApproval(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount <= tokenBalance);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeTransferFromAlice(carol, tokenId, tokenAmount, data, "Calling `safeTransferFrom` with approval reverts.");
    }

    /// @notice A `safeTransferFrom` call MUST revert if the caller has not been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalance of tokenId).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call does NOT revert if the caller has not been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalance of tokenId).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromRevertsWhenNoApproval(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount <= tokenBalance);
        _propertyAliceSetApprovalForAllFalseForBobThenBobCannotCallSafeTransferFromAlice(carol, tokenId, tokenAmount, data, "Calling `safeTransferFrom` without approval does not revert.");
    }

    /// @notice A `safeTransferFrom` call MUST revert if the tokenReceiver is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call does NOT revert if the tokenReceiver is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToZeroAddressReverts(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount <= tokenBalance);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeTransferFromAlice(address(0), tokenId, tokenAmount, data, "Calling `safeTransferFrom` to zero address does not revert.");
    }

    /// @notice A `safeTransferFrom` call MUST revert if the tokenOwner has insufficient tokenBalance of tokenId 
    /// to be transferred (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call does NOT revert even if the tokenOwner has insufficient tokenBalance of tokenId 
    /// to be transferred (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromRevertsWhenInsufficientBalance(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount > tokenBalance);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeTransferFromAlice(carol, tokenId, tokenAmount, data, "Calling `safeTransferFrom` even with insufficient balance does not revert.");
    }

    /// @notice A successful `safeTransferFrom` call of zero amount to an EOA tokenReceiver 
    /// MUST emit `TransferSingle` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call of zero amount to an EOA 
    /// tokenReceiver call does NOT emit `TransferSingle` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, event
    /// @custom:ercx-concerned-function safeTransferFrom
    function testSafeTransferFromZeroAmountToEoaEventEmission(uint256 tokenId, uint256 tokenBalance, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _safeTransferFromToEoaEventEmission(tokenId, 0, data);
    }

    /// @notice A successful `safeTransferFrom` call of any positive amount to an EOA tokenReceiver 
    /// MUST emit `TransferSingle` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call of any positive amount to an EOA 
    /// tokenReceiver call does NOT emit `TransferSingle` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, event
    /// @custom:ercx-concerned-function safeTransferFrom
    function testSafeTransferFromPositiveAmountToEoaEventEmission(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount > 0);
        vm.assume(tokenAmount <= tokenBalance);
        _safeTransferFromToEoaEventEmission(tokenId, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to a contract tokenReceiver MUST emit `TransferSingle` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to a contract tokenReceiver does NOT emit `TransferSingle` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, event, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom
    function testSafeTransferFromZeroAmountToContractEventEmission(uint256 tokenId, uint256 tokenBalance, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _safeTransferFromToContractEventEmission(tokenId, 0, data);
    }

    /// @notice A successful `safeTransferFrom` call of any positive amount to a contract tokenReceiver 
    /// MUST emit `TransferSingle` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call of any positive amount to a 
    /// contract tokenReceiver does NOT emit `TransferSingle` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, event, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom
    function testSafeTransferFromPositiveAmountToContractEventEmission(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        vm.assume(tokenAmount > 0);
        vm.assume(tokenAmount <= tokenBalance);
        _safeTransferFromToContractEventEmission(tokenId, tokenAmount, data);
    }

    /// @notice A `safeTransferFrom` call MUST be completed if tokenReceiver is a smart contract and it implements 
    /// `onERC1155Received` with the correct return value.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call can NOT be completed even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155Received` with the correct return value.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromCompletesWhenCorrectContractReceiverReturn(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        vm.assume(tokenAmount <= tokenBalance);
        // Set up receiver contract with the correct `onERC1155Received` return
        IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeTransferFromAlice(address(receiverContract), tokenId, tokenAmount, data, "Calling `safeTransferFrom` from Alice to contract receiver by Bob reverts unexpectedly.");
    }

    /// @notice A `safeTransferFrom` call MUST revert if tokenReceiver is a smart contract and it implements 
    /// `onERC1155Received` with the incorrect return value.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call is successful even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155Received` with the incorrect return value.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromRevertsWhenIncorrectContractReceiverReturn(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data, bytes4 otherRetVal) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        vm.assume(tokenAmount <= tokenBalance);
        // Set up receiver contract with the incorrect return for single NFT transfers where 
        // we let the fuzz mechanism to take care of the bytes4 return value, i.e., via `otherRetVal` 
        IERC1155Receiver receiverContract = _setUpReceiverContract(false, otherRetVal, false, true, bytes4(0), false);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeTransferFromAlice(address(receiverContract), tokenId, tokenAmount, data, "Calling `safeTransferFrom` from Alice to contract receiver by Bob succeeds unexpectedly.");
    }

    /// @notice A `safeTransferFrom` call MUST revert if tokenReceiver is a smart contract and it implements 
    /// `onERC1155Received` but throws an error.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom` call is successful even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155Received` and throws an error.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories single transfer, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromRevertsWhenContractReceiverThrowsError(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        vm.assume(tokenAmount <= tokenBalance);
        // Set up receiver contract that will always reverts when receiving single NFT tokens
        IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), true, true, bytes4(0), false);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeTransferFromAlice(address(receiverContract), tokenId, tokenAmount, data, "Calling `safeTransferFrom` from Alice to contract receiver by Bob succeeds unexpectedly.");
    }


    /****************************
    *
    * safeBatchTransferFrom mandatory checks.
    *
    ****************************/

    /// @notice A `safeBatchTransferFrom` call is SUCCESSFUL if the caller has been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalances for respective tokenIds).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call is UNSUCCESSFUL even if the caller has been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalances for respective tokenId).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, approval
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromSucceedsWhenApproval(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeBatchTransferFromAlice(carol, tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` with approval reverts.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if the caller has not been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalances for the respective tokenIds).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call does NOT revert if the caller has not been approved to 
    /// manage the tokens from the tokenOwner (given that the tokenOwner has sufficient tokenBalances for the respective tokenIds).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, approval
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromRevertsWhenNoApproval(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertyAliceSetApprovalForAllFalseForBobThenBobCannotCallSafeBatchTransferFromAlice(carol, tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` without approval does not revert.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if the tokenReceiver is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call does NOT revert if the tokenReceiver is the zero address 
    /// (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, zero address
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromToZeroAddressReverts(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeBatchTransferFromAlice(address(0), tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` to zero address does not revert.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if the length of tokenIds is not the same
    /// as the length of the tokenBalances (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call does not revert even if the length of tokenIds is not the same
    /// as the length of the tokenBalances (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromUnequalArrayLengthsReverts(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, true);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        // Convert the fixed length arrays to dynamic arrays
        uint256 idsLength = tokenIds.length;
        uint256 balancesLength = tokenBalances.length - 1; // to make unequal array lengths
        uint256[] memory _tokenIds = new uint256[](idsLength);
        uint256[] memory _tokenBalances = new uint256[](balancesLength);
        for (uint8 i = 0; i < idsLength; i++) {
            if (i < balancesLength) {
                _tokenBalances[i] = tokenBalances[i];
            }
            _tokenIds[i] = tokenIds[i];
        }
        vm.startPrank(bob);
        (bool callSuccess, ) = _trySafeBatchTransferFromDynamic(alice, carol, _tokenIds, _tokenBalances, data);
        vm.stopPrank();
        assertFalse(callSuccess, "Calling `safeBatchTransferFrom` with unequal pair of arrays does not revert.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if any of the balance(s) of the holder(s) 
    /// for token(s) in `tokenIds` is lower than the respective amount(s) in `tokenAmounts` sent to 
    /// the tokenReceiver (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call does not revert even when some of the balance(s) of 
    /// the holder(s) for token(s) in `tokenIds` is lower than the respective amount(s) in `tokenAmounts` 
    /// sent to the tokenReceiver (given that the caller has been approved to manage the tokens from the tokenOwner).
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, balance
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromInsufficientBalancesReverts(uint256 tokenAmount, uint256 tokenId, uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        // Choose a random tokenId from 0 to 2 for the tokenAmount > tokenBalances[tokenId]
        tokenId = bound(tokenId, 0, 2);
        vm.assume(tokenAmount > tokenBalances[tokenId]);
        // Replace tokenBalances[tokenId] with tokenAmount and name this new array tokenAmounts
        uint256[3] memory tokenAmounts = tokenBalances;
        tokenAmounts[tokenId] = tokenAmount;
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeBatchTransferFromAlice(carol, tokenIds, tokenAmounts, data, "Calling `safeBatchTransferFrom` with insufficient balance does not revert.");
    }

    /// @notice A successful `safeBatchTransferFrom` call of an array of zero amounts to an EOA tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of an array of zero amounts to an EOA tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromAllZeroAmountsToEoaEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        uint256[3] memory tokenAmounts = [uint256(0), uint256(0), uint256(0)];
        _safeBatchTransferFromToEoaEventEmission(tokenIds, tokenAmounts, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call of an array with some positive and some zero amounts to an EOA tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of an array with some positive and some zero amounts to an EOA tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromSomeZeroAmountToEoaEventEmission(uint256 tokenId, uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        // Choose a random tokenId from 0 to 2 for the tokenBalances[tokenId] = 0
        tokenId = bound(tokenId, 0, 2);
        uint256[3] memory tokenAmounts = tokenBalances;
        tokenAmounts[tokenId] = 0;
        _safeBatchTransferFromToEoaEventEmission(tokenIds, tokenAmounts, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call of any positive amounts to an EOA tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of any positive amounts to an EOA tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromPositiveAmountsToEoaEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        for (uint8 i = 0; i < 3; i++) {
            vm.assume(tokenBalances[i] > 0);
        }
        _safeBatchTransferFromToEoaEventEmission(tokenIds, tokenBalances, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call of an array of zero amounts to a contract tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of an array of zero amounts to a contract tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromAllZeroAmountsToContractEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        uint256[3] memory tokenAmounts = [uint256(0), uint256(0), uint256(0)];
        _safeBatchTransferFromToContractEventEmission(tokenIds, tokenAmounts, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call of an array with some positive and some zero amounts to a contract tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of an array with some positive and some zero amounts to a contract tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromSomeZeroAmountToContractEventEmission(uint256 tokenId, uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        // Choose a random tokenId from 0 to 2 for the tokenBalances[tokenId] = 0
        tokenId = bound(tokenId, 0, 2);
        uint256[3] memory tokenAmounts = tokenBalances;
        tokenAmounts[tokenId] = 0;
        _safeBatchTransferFromToContractEventEmission(tokenIds, tokenAmounts, data);
    }

    /// @notice A successful `safeBatchTransferFrom` call of any positive amounts to a contract tokenReceiver MUST emit `TransferBatch` event correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeBatchTransferFrom` of any positive amounts to a contract tokenReceiver call does NOT emit `TransferBatch` event correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeBatchTransferFrom.
    /// @custom:ercx-categories batch transfer, event, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom
    function testSafeBatchTransferFromPositiveAmountsToContractEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances)
    {
        for (uint8 i = 0; i < 3; i++) {
            vm.assume(tokenBalances[i] > 0);
        }
        _safeBatchTransferFromToContractEventEmission(tokenIds, tokenBalances, data);
    }

    /// @notice A `safeBatchTransferFrom` call MUST be completed if tokenReceiver is a smart contract and it implements 
    /// `onERC1155BatchReceived` with the correct return value.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call can NOT be completed even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155BatchReceived` with the correct return value.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromCompletesWhenCorrectContractReceiverReturn(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances) {
        // Set up receiver contract with the correct `onERC1155BatchReceived` return 
        IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeBatchTransferFromAlice(address(receiverContract), tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` from Alice to contract receiver by Bob reverts unexpectedly.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if tokenReceiver is a smart contract and it implements 
    /// `onERC1155BatchReceived` with the incorrect return value.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call is successful even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155BatchReceived` with the incorrect return value.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromRevertsWhenIncorrectContractReceiverReturn(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data, bytes4 otherRetVal) 
    external dealAliceBatchNft(tokenIds, tokenBalances) {
        // Set up receiver contract with the incorrect return for batch NFT transfers where 
        // we let the fuzz mechanism to take care of the bytes4 return value, i.e., via `otherRetVal` 
        IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, false, otherRetVal, false);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeBatchTransferFromAlice(address(receiverContract), tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` from Alice to contract receiver by Bob succeeds unexpectedly.");
    }

    /// @notice A `safeBatchTransferFrom` call MUST revert if tokenReceiver is a smart contract and it implements 
    /// `onERC1155BatchReceived` but throws an error.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeBatchTransferFrom` call is successful even if tokenReceiver is a smart contract and 
    /// it implements `onERC1155BatchReceived` and throws an error.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories batch transfer, contract receiver
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll
    function testSafeBatchTransferFromRevertsWhenContractReceiverThrowsError(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances) {
        // Set up receiver contract that will always reverts when receiving batch NFT tokens
        IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), true);
        _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeBatchTransferFromAlice(address(receiverContract), tokenIds, tokenBalances, data, "Calling `safeBatchTransferFrom` from Alice to contract receiver by Bob succeeds unexpectedly.");
    }
    

    /****************************
    *
    * balanceOf mandatory checks.
    *
    ****************************/

    /// @notice Calling of `balanceOf` of any tokenId does not revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling of `balanceOf` of some tokenId reverts.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testBalanceOfNotRevert(uint256 tokenId) external 
    {
        // bound the ID num as some ERC1155 tokens do not allow high ID num
        tokenId = bound(tokenId, 0, MAX_UINT96);
        vm.startPrank(bob);
        bytes memory data = abi.encodeWithSignature("balanceOf(address,uint256)", alice, tokenId);
        (bool success, ) = address(cut1155).call(data);
        vm.stopPrank();
        assertTrue(success, "Calling of `balanceOf` reverts.");
    }

    /// @notice A successful `balanceOf` call MUST return the correct zero balance of the provided tokenId 
    /// from the provided tokenOwner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf` call does NOT return the correct zero balance of the provided tokenId 
    /// from the provided tokenOwner.
    /// @custom:ercx-categories balance, zero amount
    /// @custom:ercx-concerned-function balanceOf
    function testBalanceOfReturnsCorrectZeroBalance(uint256 tokenId) external 
    {
        assertEq(0, cut1155.balanceOf(alice, tokenId), "Incorrect value returned by balanceOf for an account with zero balance");
    }

    /// @notice A successful `balanceOf` call MUST return the correct non-zero balance of the provided tokenId 
    /// from the provided tokenOwner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf` call does NOT return the correct non-zero balance of the provided tokenId 
    /// from the provided tokenOwner.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testBalanceOfReturnsCorrectNonZeroBalance(uint256 tokenId, uint256 tokenBalance) external 
    dealAliceSingleNft(tokenId, tokenBalance) {
        vm.assume(tokenBalance > 0);
        assertEq(tokenBalance, cut1155.balanceOf(alice, tokenId), "Incorrect value returned by balanceOf for an account with non-zero balance");
    }


    /****************************
    *
    * balanceOfBatch mandatory checks.
    *
    ****************************/

    /// @notice Calling of `balanceOfBatch` of any array of tokenIds does not revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling of `balanceOfBatch` of some array of tokenIds reverts.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOfBatch
    function testBalanceOfBatchNotRevert(uint256[3] memory tokenIds) external 
    {
        address[3] memory tokenOwners = [alice, bob, carol];
        // Bound the ID nums as some ERC1155 tokens do not allow high ID num
        uint256[3] memory _tokenIds; 
        for (uint8 i = 0; i < 3; i++) {
            _tokenIds[i] = bound(tokenIds[i], 0, MAX_UINT96);
        }
        // convert static arrays to dynamic arrays to be passed for calling
        address[] memory _dynamicOwners = _convertLength3AddressArrayFromStaticToDynamic(tokenOwners);
        uint256[] memory _dynamicIds = _convertLength3Uint256ArrayFromStaticToDynamic(_tokenIds);
        vm.startPrank(contractOwner);
        bytes memory data = abi.encodeWithSignature("balanceOfBatch(address[],uint256[])", _dynamicOwners, _dynamicIds);
        (bool success, ) = address(cut1155).call(data);
        vm.stopPrank();
        assertTrue(success, "Calling of `balanceOfBatch` reverts.");
    }

    /// @notice A successful `balanceOfBatch` call MUST return the correct balances of the provided tokenIds 
    /// from the provided tokenOwners.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOfBatch` call does NOT return the correct balances of the provided tokenIds 
    /// from the provided tokenOwners.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when dealing tokens to dummy users for interacting with the contract.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOfBatch
    function testBalanceOfBatchReturnsCorrectBalances(uint256 tokenId1, uint256 tokenBalance1, 
    uint256 tokenId2, uint256 tokenBalance2) external 
    dealTwoUsersSingleNfts(tokenId1, tokenBalance1, tokenId2, tokenBalance2) {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = tokenId1;
        tokenIds[1] = tokenId2;
        uint256[3] memory expectedTokenBalances = [tokenBalance1, tokenBalance2, 0];
        uint256[] memory returnedTokenBalances = cut1155.balanceOfBatch(accountsNoOwner, tokenIds);
        assertEq(returnedTokenBalances.length, 3, "The returned array of token balances has incorrect length.");
        for (uint8 i = 0; i < 3; i++) {
            assertEq(expectedTokenBalances[i], returnedTokenBalances[i]);
        }
    }


    /****************************
    *
    * setApprovalForAll mandatory checks.
    *
    ****************************/

    /// @notice Calling of `setApprovalForAll` of any boolean value does not revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling of `setApprovalForAll` of some boolean value reverts.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testSetApprovalForAllNotRevert(bool approval) external 
    {
        (bool success, ) = _tryAliceSetApprovalForAll(bob, approval);
        assertTrue(success, "Calling of `setApprovalForAll` reverts.");
    }

    /// @notice A successful `setApprovalForAll` call MUST emit `ApprovalForAll` event correctly.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `setApprovalForAll` call does NOT emit `ApprovalForAll` event correctly.
    /// @custom:ercx-categories approval, event
    /// @custom:ercx-concerned-function setApprovalForAll
    function testSetApprovalForAllEventEmission(bool approved)
    external {
        vm.expectEmit();
        emit ApprovalForAll(alice, bob, approved);
        _tryAliceSetApprovalForAll(bob, approved);
    }


    /****************************
    *
    * isApprovedForAll mandatory checks.
    *
    ****************************/

    /// @notice Calling of `isApprovedForAll` by any caller on any tokenOwner of any operator does not revert.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Calling of `isApprovedForAll` by some caller on some tokenOwner of some operator reverts.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForAll
    function testIsApprovedForAllNotRevert() external 
    {
        vm.startPrank(carol);
        bytes memory data = abi.encodeWithSignature("isApprovedForAll(address,address)", alice, bob);
        (bool success, ) = address(cut1155).call(data);
        vm.stopPrank();
        assertTrue(success, "Calling of `isApprovedForAll` reverts.");
    }

    /// @notice A successful `isApprovedForAll` call MUST return the approval status 
    /// of an operator for a given owner correctly.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `isApprovedForAll` call does NOT return the approval status 
    /// of an operator for a given owner correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForAll, setApprovalForAll
    function testIsApprovedForAllReturnsCorrectApprovalStatus(bool approved)
    external {   
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, approved);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        bool approvalStatus = cut1155.isApprovedForAll(alice, bob);
        assertEq(approved, approvalStatus, "A `isApprovedForAll` call returns incorrect approval status.");
    }


    /****************************
    *****************************
    *
    * RECOMMENDED checks.
    *
    *****************************
    ****************************/

    /****************************
    *
    * Self transfer recommended checks.
    *
    ****************************/

    /// @notice An owner SHOULD be able to call `safeTransferFrom` on his/her own tokens as 
    /// an operator without the approval of him/herself.
    /// NOTE: If `testSetApprovalForAllNotRevert` and/or `testIsApprovedForAll` fails, 
    /// then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An owner cannot call `safeTransferFrom` on his/her own tokens as 
    /// an operator without the approval of him/herself. 
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, isApprovedForAll.
    /// @custom:ercx-categories single transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll, isApprovedForAll
    function testSelfSafeTransferFromWithoutApproval(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        vm.assume(tokenAmount <= tokenBalance);
        // Make sure that there is no approval of Alice to herself
        if (cut1155.isApprovedForAll(alice, alice)) {
            (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(alice, false);   
            // Skip the test if the setApprovalForAll call fails
            conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to herself.");     
            // Skip the test if the approval status cannot be set to false
            // Note: In this case, we will skip the test if the approval status is still set to true
            conditionalSkip(cut1155.isApprovedForAll(alice, alice), "Inconclusive test: Approval status from Alice to Alice cannot be set to false.");
        }
        (bool callSuccess, ) = _tryAliceCallsSafeTransferFrom(alice, carol, tokenId, tokenAmount, data);
        assertTrue(callSuccess, "Calling `safeTransferFrom` without approval by Alice from her own tokens reverts.");
    }

    /// @notice An owner SHOULD be able to call `safeBatchTransferFrom` on his/her own tokens as 
    /// an operator without the approval of him/herself. 
    /// NOTE: If `testSetApprovalForAllNotRevert` and/or `testIsApprovedForAll` fails, 
    /// then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An owner cannot call `safeBatchTransferFrom` on his/her own tokens as 
    /// an operator without the approval of him/herself.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, isApprovedForAll.
    /// @custom:ercx-categories batch transfer, approval
    /// @custom:ercx-concerned-function safeBatchTransferFrom, setApprovalForAll, isApprovedForAll
    function testSelfSafeBatchTransferFromWithoutApproval(uint256[3] memory tokenIds, uint256[3] memory tokenBalances, bytes calldata data) 
    external dealAliceBatchNft(tokenIds, tokenBalances) {
        // Make sure that there is no approval of Alice to herself
        if (cut1155.isApprovedForAll(alice, alice)) {
            (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(alice, false);   
            // Skip the test if the setApprovalForAll call fails
            conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to herself.");     
            // Skip the test if the approval status cannot be set to false
            // Note: In this case, we will skip the test if the approval status is still set to true
            conditionalSkip(cut1155.isApprovedForAll(alice, alice), "Inconclusive test: Approval status from Alice to Alice cannot be set to false.");
        }
        (bool callSuccess, ) = _tryAliceCallsSafeBatchTransferFrom(alice, carol, tokenIds, tokenBalances, data);
        assertTrue(callSuccess, "Calling `safeBatchTransferFrom` without approval by Alice from her own tokens reverts.");        
    }


    /****************************
    *****************************
    *
    * Internal helper functions for standard tests.
    *
    *****************************
    ****************************/

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true` and
    /// Bob can call `safeTransferFrom` Alice's token successfully
    function _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeTransferFromAlice(address _to, 
    uint256 _id, uint256 _value, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeTransferFromAlice(true, true, _to, _id, _value, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true` but
    /// Bob's `safeTransferFrom` call from Alice's token reverts
    function _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeTransferFromAlice(address _to, 
    uint256 _id, uint256 _value, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeTransferFromAlice(true, false, _to, _id, _value, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `false` and
    /// Bob's `safeTransferFrom` call from Alice's token reverts
    function _propertyAliceSetApprovalForAllFalseForBobThenBobCannotCallSafeTransferFromAlice(address _to, 
    uint256 _id, uint256 _value, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeTransferFromAlice(false, false, _to, _id, _value, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true/false` (via `_approved`) 
    /// and Bob can call `safeTransferFrom` Alice's token successfully/unsuccessfully (via `_shouldSucceed`)
    function _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeTransferFromAlice(bool _approved, 
    bool _shouldSucceed, address _to, uint256 _id, uint256 _value, bytes calldata _data, string memory _errorMessage)
    internal {
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, _approved);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        (bool callSuccess, ) = _tryBobCallsSafeTransferFrom(alice, _to, _id, _value, _data);
        if (_shouldSucceed) {
            assertTrue(callSuccess, _errorMessage);
        }
        else {
            assertFalse(callSuccess, _errorMessage);
        }
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true` and
    /// Bob can call `safeBatchTransferFrom` Alice's token successfully
    function _propertyAliceSetApprovalForAllTrueForBobThenBobCanCallSafeBatchTransferFromAlice(address _to, 
    uint256[3] memory _ids, uint256[3] memory _values, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeBatchTransferFromAlice(true, true, _to, _ids, _values, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true` but
    /// Bob's `safeBatchTransferFrom` call from Alice's token reverts
    function _propertyAliceSetApprovalForAllTrueForBobThenBobCannotCallSafeBatchTransferFromAlice(address _to, 
    uint256[3] memory _ids, uint256[3] memory _values, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeBatchTransferFromAlice(true, false, _to, _ids, _values, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `false` and
    /// Bob's `safeBatchTransferFrom` call from Alice's token reverts
    function _propertyAliceSetApprovalForAllFalseForBobThenBobCannotCallSafeBatchTransferFromAlice(address _to, 
    uint256[3] memory _ids, uint256[3] memory _values, bytes calldata _data, string memory _errorMessage)
    internal {
        _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeBatchTransferFromAlice(false, false, _to, _ids, _values, _data, _errorMessage);
    }

    /// @notice Internal function that checks for Alice to `setApprovalForAll` for Bob `true/false` (via `_approved`) 
    /// and Bob can call `safeBatchTransferFrom` Alice's token successfully/unsuccessfully (via `_shouldSucceed`)
    function _propertyAliceSetApprovalForAllUnknownForBobThenBobUnknownCallSafeBatchTransferFromAlice(bool _approved, 
    bool _shouldSucceed, address _to, uint256[3] memory _ids, uint256[3] memory _values, bytes calldata _data, string memory _errorMessage)
    internal {
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, _approved);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        (bool callSuccess, ) = _tryBobCallsSafeBatchTransferFrom(alice, _to, _ids, _values, _data);
        if (_shouldSucceed) {
            assertTrue(callSuccess, _errorMessage);
        }
        else {
            assertFalse(callSuccess, _errorMessage);
        }
    }

    /// @notice Internal function that checks for `TransferSingle` event mission 
    /// after `safeTransferFrom` is called to an EOA
    function _safeTransferFromToEoaEventEmission(uint256 tokenId, uint256 tokenAmount, bytes calldata data) internal 
    {
        _safeTransferFromEventEmission(false, tokenId, tokenAmount, data);
    }

    /// @notice Internal function that checks for `TransferSingle` event mission 
    /// after `safeTransferFrom` is called to a contract tokenReceiver
    function _safeTransferFromToContractEventEmission(uint256 tokenId, uint256 tokenAmount, bytes calldata data) internal 
    {
        _safeTransferFromEventEmission(true, tokenId, tokenAmount, data);
    }

    /// @notice Internal function that checks for `TransferSingle` event mission 
    /// after `safeTransferFrom` is called to an EOA address or a contract tokenReceiver (via `toContract`)
    function _safeTransferFromEventEmission(bool toContract, uint256 tokenId, uint256 tokenAmount, bytes calldata data) internal 
    {
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155Received` return
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        }
        else {
            toAddress = carol;
        }
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, true);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        vm.expectEmit();
        emit TransferSingle(bob, alice, toAddress, tokenId, tokenAmount);
        (bool callSuccess, ) = _tryBobCallsSafeTransferFrom(alice, toAddress, tokenId, tokenAmount, data);
        // The following conditionSkip is needed in case the safeTransferFrom call fails
        conditionalSkip(!callSuccess, "Inconclusive test: Bob failed to call `safeTransferFrom` from Alice to a tokenReceiver.");
    }

    /// @notice Internal function that checks for `TransferBatch` event mission 
    /// after `safeBatchTransferFrom` is called to an EOA
    function _safeBatchTransferFromToEoaEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenAmounts, bytes calldata data) internal 
    {
        _safeBatchTransferFromEventEmission(false, tokenIds, tokenAmounts, data);
    }

    /// @notice Internal function that checks for `TransferBatch` event mission 
    /// after `safeBatchTransferFrom` is called to a contract tokenReceiver
    function _safeBatchTransferFromToContractEventEmission(uint256[3] memory tokenIds, uint256[3] memory tokenAmounts, bytes calldata data) internal 
    {
        _safeBatchTransferFromEventEmission(true, tokenIds, tokenAmounts, data);
    }

    /// @notice Internal function that checks for `TransferBatch` event mission 
    /// after `safeBatchTransferFrom` is called to an EOA address or a contract tokenReceiver (via `toContract`)
    function _safeBatchTransferFromEventEmission(bool toContract, uint256[3] memory tokenIds, uint256[3] memory tokenAmounts, bytes calldata data) internal 
    {
        address toAddress;
        if (toContract) {
            // Set up receiver contract with the correct `onERC1155BatchReceived` return 
            IERC1155Receiver receiverContract = _setUpReceiverContract(true, bytes4(0), false, true, bytes4(0), false);
            toAddress = address(receiverContract);
        }
        else{
            toAddress = carol;
        }
        (bool approvalSuccess, ) = _tryAliceSetApprovalForAll(bob, true);
        // Skip the test if the setApprovalForAll call fails
        conditionalSkip(!approvalSuccess, "Inconclusive test: Alice failed to call `setApprovalForAll` to Bob.");
        uint256[] memory _tokenIds = _convertLength3Uint256ArrayFromStaticToDynamic(tokenIds);
        uint256[] memory _tokenAmounts = _convertLength3Uint256ArrayFromStaticToDynamic(tokenAmounts);
        vm.expectEmit();
        emit TransferBatch(bob, alice, toAddress, _tokenIds, _tokenAmounts);
        (bool callSuccess, ) = _tryBobCallsSafeBatchTransferFrom(alice, toAddress, tokenIds, tokenAmounts, data);
        // The following conditionSkip is needed in case the safeBatchTransferFrom call fails
        conditionalSkip(!callSuccess, "Inconclusive test: Bob failed to call `safeBatchTransferFrom` from Alice to a tokenReceiver.");
    }

}