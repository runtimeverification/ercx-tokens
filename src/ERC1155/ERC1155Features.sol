// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "./ERC1155Abstract.sol";

/// @notice Abstract contract that consists of testing functions with test for properties 
/// that are neither desirable nor undesirable but instead implementation choices.
abstract contract ERC1155Features is ERC1155Abstract {

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
    *
    * safeTransferFrom feature                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       checks.
    *
    ****************************/

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for an EOA tokenReceiver 
    /// less than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call increases the tokenBalance of tokenId for an EOA 
    /// tokenReceiver greater than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseEoaReceiverBalanceLtExpected(uint256 tokenId, uint256 aliceTokenBalance, uint256 bobTokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealTwoUsersSingleNfts(tokenId, aliceTokenBalance, tokenId, bobTokenBalance)
    {
        _propertySafeTransferFromIncreaseReceiverBalance(false, ArithmeticOperator.Lesser, tokenId, aliceTokenBalance, bobTokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for an EOA tokenReceiver 
    /// greater than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call increases the tokenBalance of tokenId for an EOA 
    /// tokenReceiver less than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseEoaReceiverBalanceGtExpected(uint256 tokenId, uint256 aliceTokenBalance, uint256 bobTokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealTwoUsersSingleNfts(tokenId, aliceTokenBalance, tokenId, bobTokenBalance)
    {
        _propertySafeTransferFromIncreaseReceiverBalance(false, ArithmeticOperator.Greater, tokenId, aliceTokenBalance, bobTokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to an EOA tokenReceiver decreases the tokenBalance of tokenId for tokenOwner 
    /// less than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to an EOA tokenReceiver decreases the tokenBalance of tokenId for tokenOwner 
    /// greater than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToEoaDecreaseOwnerBalanceLtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(false, ArithmeticOperator.Lesser, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to an EOA tokenReceiver decreases the tokenBalance of tokenId for tokenOwner 
    /// greater than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to an EOA tokenReceiver decreases the tokenBalance of tokenId for tokenOwner 
    /// less than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToEoaDecreaseOwnerBalanceGtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(false, ArithmeticOperator.Greater, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for a contract tokenReceiver 
    /// less than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call increases the tokenBalance of tokenId for a contract 
    /// tokenReceiver greater than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseContractReceiverBalanceLtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        _propertySafeTransferFromIncreaseReceiverBalance(true, ArithmeticOperator.Lesser, tokenId, tokenBalance, 0, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call increases the tokenBalance of tokenId for a contract tokenReceiver 
    /// greater than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call increases the tokenBalance of tokenId for a contract 
    /// tokenReceiver less than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, contract receiver
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromIncreaseContractReceiverBalanceGtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance) {
        _propertySafeTransferFromIncreaseReceiverBalance(true, ArithmeticOperator.Greater, tokenId, tokenBalance, 0, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to a contract tokenReceiver decreases the tokenBalance of tokenId for 
    /// tokenOwner less than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to a contract tokenReceiver decreases the tokenBalance of tokenId for 
    /// tokenOwner greater than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance, contract receiver 
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToContractDecreaseOwnerBalanceLtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(true, ArithmeticOperator.Lesser, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice A successful `safeTransferFrom` call to a contract tokenReceiver decreases the tokenBalance of tokenId for 
    /// tokenOwner greater than what was expected.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `safeTransferFrom` call to a contract tokenReceiver decreases the tokenBalance of tokenId for 
    /// tokenOwner less than or equal to what was expected.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance, contract receiver 
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSafeTransferFromToContractDecreaseOwnerBalanceGtExpected(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySafeTransferFromDecreaseOwnerBalance(true, ArithmeticOperator.Greater, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice The tokenBalance of any tokenId decreases after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The tokenBalance of any tokenId does not decrease after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSelfSafeTransferFromSelfToSelfDecreasesOwnerBalance(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySelfSafeTransferFromSelfToSelfChangeOwnerBalance(ArithmeticOperator.Lesser, tokenId, tokenBalance, tokenAmount, data);
    }

    /// @notice The tokenBalance of any tokenId increases after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// NOTE: If `testSetApprovalForAllNotRevert` fails, then the result of this test is inconclusive.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The tokenBalance of any tokenId does not increase after a successful `safeTransferFrom` call 
    /// by tokenOwner from her account back to herself.
    /// @custom:ercx-inconclusive The test is skipped as there is either an issue when dealing tokens to dummy users for interacting with the contract
    /// OR calling the following functions: setApprovalForAll, safeTransferFrom.
    /// @custom:ercx-categories single transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, setApprovalForAll
    function testSelfSafeTransferFromSelfToSelfIncreasesOwnerBalance(uint256 tokenId, uint256 tokenBalance, uint256 tokenAmount, bytes calldata data) 
    external dealAliceSingleNft(tokenId, tokenBalance)
    {
        _propertySelfSafeTransferFromSelfToSelfChangeOwnerBalance(ArithmeticOperator.Greater, tokenId, tokenBalance, tokenAmount, data);
    }

}