// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC721Abstract.sol";

/// @notice Abstract contract that consists of the security properties, including desirable properties for the sane functioning of the token and properties
/// of add-on functions commonly created and used by ERC721 developers.
abstract contract ERC721Security is ERC721Abstract {

    /***********************************************************************************
    * Glossary                                                                         *
    * -------------------------------------------------------------------------------- *
    * tokenSender   : address that sends tokens (usually in a transaction)             *
    * tokenReceiver : address that receives tokens (usually in a transaction)          *
    * tokenApprover : address that approves tokens (usually in an approval)            *
    * tokenApprovee : address that tokenApprover approves of (usually in an approval)  *
    ***********************************************************************************/

    /*******************************************/
    /*******************************************/
    /* Tests related to desirable properties. */
    /*******************************************/
    /*******************************************/

    /****************************
    *
    * safeTransferFrom(address,address,uint256,bytes) desirable checks.
    *
    ****************************/

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataToEOAByOwnerUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesBalances(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataToReceiverByOwnerUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesBalances(bob, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that upon a safeTransferFrom with data, the balance of the tokenSender and the tokenReceiver are updated correctly.
    function _propertySafeTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId, bytes memory data) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceSafeTransferFromWithData(alice, to, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByReceiverOwnerToHimSelfDoesNotUpdatesBalance(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(alice, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the EOA token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByEOAOwnerToHimSelfDoesNotUpdatesBalance(bytes memory data)
    public withUsers() dealAnOwnedTokenToCustomer(dan, tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(dan, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom by the owner, the balance of the owner does not update.
    function _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(address owner, uint256 tokenId, bytes memory data) internal {
        uint256 ownerInitialBalance = cut.balanceOf(owner);
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(owner, owner, owner, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from the owner to self.");
        assertEq(cut.balanceOf(owner), ownerInitialBalance, "Balance of the owner has changed after sending a token to himself.");  
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByApprovedAddressToOwnerDoesNotUpdatesBalance(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {       
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(bob, alice, alice, tokenIdWithOwner, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Approved address could not safeTransferFrom from Alice to Alice.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after the approved address sent a token to his initial owner.");
    }

    //
 
    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not correctly updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedEOAAddressToSelfUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedReceiverAddressToSelfUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(bob, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom by the owner, the balance of the owner does not update.
    function _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(address approvedAddress, uint256 tokenId, bytes memory data) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(approvedAddress);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(approvedAddress, alice, approvedAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: approved address could not safeTransferFrom from Alice to him.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of Alice has not been decremented after sending a token.");
        assertEq(cut.balanceOf(approvedAddress), approvedInitialBalance + 1, "Balance of approved address has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedAddressToEOAUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedAddressToReceiverUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenIdWithOwner, data);
    }
    
    /// @notice Internal property-test checking that after a safeTransferFrom by the approved address, the balances of the tokenSender and the tokenReceiver are correctly updated.
    function _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(address to, uint256 tokenId, bytes memory data) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFromWithData(alice, to, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to Carol.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator , balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToEOAUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator , balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToReceiverUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that after a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator, the balances of the tokenSender and the tokenReceiver are correctly updated.
    function _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId, bytes memory data) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(tokenId, data, to)) {
                assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
                assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator  to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToSelfUpdatesBalances(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenIdWithOwner, data)) {
            assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
            assertEq(cut.balanceOf(bob), bobInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

    /****************************
    *
    * safeTransferFrom(address,address,uint256) desirable checks.
    *
    ****************************/

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromToEOAByOwnerUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromToReceiverByOwnerUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesBalances(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom(address,address,uint256)` (without data) by the tokenOwner, the balances of the tokenReceiver and the tokenReceiver are correctly updated. 
    function _propertySafeTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByReceiverOwnerToHimSelfDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, alice, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from Alice to self.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after sending a token to himself.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the EOA token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByEOAOwnerToHimSelfDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToCustomer(dan, tokenIdWithOwner) {
        uint256 ownerInitialBalance = cut.balanceOf(dan);
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(dan, dan, dan, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from Alice to self.");
        assertEq(cut.balanceOf(dan), ownerInitialBalance, "Balance of a user has changed after sending a token to himself.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByApprovedAddressToOwnerDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(bob, alice, alice, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Approved address could not safeTransferFrom from Alice to Alice.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after the approved address sent a token to his initial owner.");
    }

    //
 
    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedEOAAddressToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(dan);
        CallResult memory callApprove = _tryAliceApprove(dan, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(dan, alice, dan, tokenIdWithOwner);
        conditionalSkip (!callTransfer.success, "Inconclusive test: approved address could not safeTransferFrom from Alice to him.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(dan), approvedInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedReceiverAddressToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFrom(alice, bob, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to him.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(bob), bobInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedAddressToEOAUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedAddressToReceiverUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that after `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the balance of the tokenSender and the tokenReceiver are updated correctly.
    function _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to Carol.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToEOAUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToReceiverUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenIdWithOwner);
    }

    function _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(tokenId, to)) {
                assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
                assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenIdWithOwner)) {
            assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
            assertEq(cut.balanceOf(bob), bobInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

    /****************************
    *
    * transferFrom(address,address,uint256) desirable checks.
    *
    ****************************/

    /// @notice A `transferFrom(address,address,uint256)` by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenTransferFromToRecipientIsIncorrectReceiverByOwner()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // eve is an incorrect receiver
        assertFail(_tryAliceTransferFrom(alice, eve, tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApproveForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenTransferFromToRecipientIsIncorrectReceiverBySomeone()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerTransferFrom(bob, alice, eve, tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received."); 
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: transferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromToEOAByOwnerUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: transferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromToReceiverByOwnerUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerUpdatesBalances(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the owner, the balances of the tokenSender and the tokenReceiver are correctly updated.    
    function _propertyTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: transferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByReceiverOwnerToHimSelfDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, alice, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom from Alice to self.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after sending a token to himself.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the EOA token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: transferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByEOAOwnerToHimSelfDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToCustomer(dan, tokenIdWithOwner) {
        uint256 ownerInitialBalance = cut.balanceOf(dan);
        CallResult memory callTransfer = _tryCustomerTransferFrom(dan, dan, dan, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom from Alice to self.");
        assertEq(cut.balanceOf(dan), ownerInitialBalance, "Balance of a user has changed after sending a token to himself.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner to himself, balances changed.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByApprovedAddressToOwnerDoesNotUpdatesBalance()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(bob, alice, alice, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Approved address could not transferFrom from Alice to Alice.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after the approved address sent a token to his initial owner.");
    }

    //
 
    /// @notice A `transferFrom(address,address,uint256)` by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedEOAAddressToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(dan);
        CallResult memory callApprove = _tryAliceApprove(dan, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(dan, alice, dan, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: approved address could not transferFrom from Alice to him.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(dan), approvedInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedReceiverAddressToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobTransferFrom(alice, bob, tokenIdWithOwner);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not transferFrom from Alice to him.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(bob), bobInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedAddressToEOAUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: approve, transferFrom.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedAddressToReceiverUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the approved address, the balances of the tokenSender and tokenReceiver are correctly updated.
    function _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not transferFrom from Alice to Carol.");
        assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
        assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToEOAUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOperatorToSomeoneUpdatesBalances(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToReceiverUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the operator, the balances of the tokenSender and tokenReceiver are correctly updated.
    function _propertyTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobTransfersFromToSomeone(tokenId, to)) {
                assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
                assertEq(cut.balanceOf(to), toInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToSelfUpdatesBalances()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobTransfersFromToSelf(tokenIdWithOwner)) {
            assertEq(cut.balanceOf(alice), aliceInitialBalance - 1, "Balance of a user has not been decremented after sending a token.");
            assertEq(cut.balanceOf(bob), bobInitialBalance + 1, "Balance of a user has not been incremented after receiving a token.");
        }
    }

}
