// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC721Abstract.sol";

/// @notice Abstract contract that consists of testing functions which test for 
/// properties from the standard stated in the official EIP721 specification.
abstract contract ERC721Standard is ERC721Abstract {

    /***********************************************************************************
    * Glossary                                                                         *
    * -------------------------------------------------------------------------------- *
    * tokenSender   : address that sends tokens (usually in a transaction)             *
    * tokenReceiver : address that receives tokens (usually in a transaction)          *
    * tokenApprover : address that approves tokens (usually in an approval)            *
    * tokenApprovee : address that tokenApprover approves of (usually in an approval)  *
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
    * setApprovalForAll(address,bool) mandatory checks.
    *
    ****************************/

    /// @notice Function setApprovalForAll(address,bool) MUST allow multiple operators per owner.
    /// @notice This test takes quite some time to execute.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function setApprovalForAll(address,bool) does not allow several operators.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
     function testCanEnableSeveralOperators() external {
        address allowingAddress = alice;
        address[3] memory allowedOperators = [bob, carol, dan];

        CallResult memory callApproval1 = _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[0], true);
        conditionalSkip(!callApproval1.success, "Inconclusive test: Could not call setApprovalForAll a first time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[0]), "Could not allow one operator.");
        CallResult memory callApproval2 = _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[1], true);
        conditionalSkip(!callApproval2.success, "Inconclusive test: Could not call setApprovalForAll a second time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[1]), "Could not allow a second operator.");
        CallResult memory callApproval3= _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[2], true);
        conditionalSkip(!callApproval3.success, "Inconclusive test: Could not call setApprovalForAll a third time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[2]), "Could not allow a third operator.");
    }


    /****************************
    *****************************
    *                           
    * Other checks from the standards.
    *
    *****************************
    ****************************/

    /****************************
    *
    * Event emission checks.
    *
    ****************************/

    /* Transfer event */

    // Using safeTransferFrom with data

    // -- By token owner

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOwnerToEOA(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOwner(tokenIdWithOwner, dan, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOwnerToReceiver(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOwner(tokenIdWithOwner, bob, data);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOwner(uint256 tokenId, address toAddress, bytes memory data) internal {
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data);
    }

    // -- By the approved address

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddressToEOA(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(tokenIdWithOwner, bob, dan, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddressToReceiver(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(tokenIdWithOwner, bob, carol, data);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (with data) by then approved address of the token.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress, bytes memory data) internal {
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not define an approved address.");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerSafeTransferFromWithData(approvedAddress, alice, toAddress, tokenId, data);
    }

    // -- By an operator

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApproveForAll.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOperatorToEOA(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(tokenIdWithOwner, bob, dan, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApproveForAll.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOperatorToReceiver(bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(tokenIdWithOwner, bob, carol, data);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (with data) by an operator.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(uint256 tokenId, address operator, address toAddress, bytes memory data) internal {
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(operator, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not define an operator (setApprovalForAll).");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerSafeTransferFromWithData(operator, alice, toAddress, tokenId, data);
    }

    // Using safeTransferFrom without data

    // -- By token owner

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOwnerToEOA() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenIdWithOwner, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOwnerToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (without data) by token owner.
    function _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(uint256 tokenId, address toAddress) internal {
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryAliceSafeTransferFrom(alice, toAddress, tokenId);
    }

    // -- By the approved address

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByApprovedAddressToEOA() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(tokenIdWithOwner, bob, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByApprovedAddressToReceiver() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(tokenIdWithOwner, bob, carol);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (without data) by the approved address.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress) internal {
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not define an approved address.");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerSafeTransferFrom(approvedAddress, alice, toAddress, tokenId);
    }

    // -- By an operator

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOperatorToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(tokenIdWithOwner, bob, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOperatorToReceiver() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(tokenIdWithOwner, bob, carol);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (without data) by an operator.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(uint256 tokenId, address operator, address toAddress) internal {
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(operator, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not define an operator (setApprovalForAll).");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerSafeTransferFrom(operator, alice, toAddress, tokenId);
    }

    // Using transferFrom

    // -- By token owner

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by token owner.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOwnerToEOA() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenIdWithOwner, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by token owner.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOwnerToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromByOwner(tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the token owner.
    function _propertyEventTransferEmitsWhenTransferFromByOwner(uint256 tokenId, address toAddress) internal {
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryAliceTransferFrom(alice, toAddress, tokenId);
    }

    // -- By the approved address

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the approved address of the token to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByApprovedAddressToEOA() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(tokenIdWithOwner, bob, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by the approved address of the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByApprovedAddressToReceiver() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(tokenIdWithOwner, bob, carol);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the approved address.
    function _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress) internal {
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not define an approved address.");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerTransferFrom(approvedAddress, alice, toAddress, tokenId);
    }

    // -- By an operator

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOperatorToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromByOperator(tokenIdWithOwner, bob, dan);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` without data by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOperatorToReceiver() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyEventTransferEmitsWhenTransferFromByOperator(tokenIdWithOwner, bob, carol);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by an operator.
    function _propertyEventTransferEmitsWhenTransferFromByOperator(uint256 tokenId, address operator, address toAddress) internal {
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(operator, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not define an operator (setApprovalForAll).");
        vm.expectEmit(true, true, true, false);
        emit Transfer(alice, toAddress, tokenId);
        _tryCustomerSafeTransferFrom(operator, alice, toAddress, tokenId);
    }

    /* Approval event */


    /// @notice Event Approval emits when approval is affirmed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event Approval was not emitted when an approvas was affirmed.
    /// @custom:ercx-categories event
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventApprovalEmitsWhenApprovedIsAffirmed() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // Making sure the token has no approvee.
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, bob, tokenIdWithOwner);
        _tryAliceApprove(bob, tokenIdWithOwner);
    }

    /// @notice Event Approval emits when approval is reaffirmed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event Approval was not emitted when an approvas was reaffirmed.
    /// @custom:ercx-categories event
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventApprovalEmitsWhenApprovedIsReAffirmed() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // Affirming approval.
        _tryAliceApprove(bob, tokenIdWithOwner);
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, bob, tokenIdWithOwner);
        // Reaffirming approval
        _tryAliceApprove(bob, tokenIdWithOwner);
    }

    /// @notice Event Approval emits when approval is changed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event Approval was not emitted when an approvas was changed.
    /// @custom:ercx-categories event
    /// @custom:ercx-concerned-function approve
    function testEventApprovalEmitsWhenApprovedIsChanged() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // Affirming approval to Bob.
        _tryAliceApprove(bob, tokenIdWithOwner);
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, carol, tokenIdWithOwner);
        // Changing approval
        _tryAliceApprove(carol, tokenIdWithOwner);
    }

    /* ApprovalForAll event */

    /// @notice Event ApprovalForAll emits when an operator is enabled.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event ApprovalForAll was not emitted when an operator was enabled.
    /// @custom:ercx-categories event, approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testEventApprovalForAllEmitsWhenOperatorIsEnabled() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.expectEmit(true, true, true, false);
        emit ApprovalForAll(alice, bob, true);
        _tryAliceSetApprovalForAll(bob, true);
    }

    /// @notice Event ApprovalForAll emits when an operator is disabled.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event ApprovalForAll was not emitted when an operator was disabled.
    /// @custom:ercx-categories event, approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testEventApprovalForAllEmitsWhenOperatorIsDisabled() 
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.expectEmit(true, true, true, false);
        emit ApprovalForAll(alice, bob, false);
        _tryAliceSetApprovalForAll(bob, false);
    }

   /****************************
    *
    * balanceOf() checks.
    *
    ****************************/

    /// @notice Function `balanceOf(address)` does not throw when queried about a valid address by anyone.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `balanceOf()` on some account did throw.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testQueryBalanceIsPossible() external {
        (bool success, ) = _tryCustomerBalanceOf(alice, bob);
        assertTrue(success,  "Call to `balanceOf()` on some account threw.");
    }

    /// @notice Function `balanceOf(address)` throws when queried about the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `balanceOf(0x0)` did not throw.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testThrowsQueryBalanceOfZeroAddress() external {
        (bool success, ) = _tryBalanceOf(address(0x0));
        assertFalse(success, "Call to `balanceOf()` on the zero address did not throw.");
    }

    /// @notice A successful `balanceOf(account)` call MUST return the updated balance of an `account` correctly when it gets updated with a new token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf(account)` call does NOT return balance of `account` correctly.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testUserBalanceIncrementedAfterReceivingAnOwnedToken()
    external withUsers() {
        uint256 initialAliceBalance = cut.balanceOf(alice);
        _dealAnOwnedTokenToAlice(tokenIdWithOwner);
        assertEq(cut.balanceOf(alice), initialAliceBalance + 1, "The value of `balanceOf(alice)` has not been incremented after a token was given to her.");
    }

    /// @notice A successful `balanceOf(account)` returns the updated balance of an `account` correctly when the user receives some tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf(account)` call does NOT return balance of `account` correctly.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testUserBalanceCorrectAfterReceivingSeveralTokens()
    external withUsers() {
        uint256 initiaAlicelBalance = cut.balanceOf(alice);
        _dealSeveralOwnedTokensToAlice(tokenIdsWithOwners);
        assertEq(cut.balanceOf(alice), initiaAlicelBalance + tokenIdsWithOwners.length, "The value of balanceOf(alice) does not equate the amount of tokens given to her.");
    }

    /// @notice A successful `balanceOf(account)` call returns 0 for users without tokens.
    /// @notice This test may fail in case Bob is an addressed used in this contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf(account)` call does NOT return balance of `account` correctly after two dummy users' balances are initialized.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testUserBalanceInitializedToZero()
    external withUsers() {
        assertEq(cut.balanceOf(bob), 0, "The value of `balanceOf(bob)` does not equate to 0 while no token were provided to him.");
    }
    
    /****************************
    *
    * ownerOf() checks.
    *
    ****************************/

    /// @notice A successful `ownerOf(tokenId)` call returns the owner of `tokenId` correctly after a user is provided this token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `ownerOf(tokenId)` call does NOT return owner of `tokenId` correctly after a user is provided this token.
    /// @custom:ercx-categories ownerOf
    /// @custom:ercx-concerned-function ownerOf
    function testOwnerOfUpdated()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertEq(cut.ownerOf(tokenIdWithOwner), alice, "The value of `ownerOf(tokenId)` does not equate the owner of the token.");
    }

    /// @notice A call `ownerOf(tokenId)` for a non-owned token must throw.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `ownerOf(tokenId)` did NOT throw for a `tokenId` that is not owned.
    /// @custom:ercx-categories ownerOf
    /// @custom:ercx-concerned-function ownerOf
    function testOwnerOfThrowsForNotOwnedToken(uint256 tokenId) external{
        vm.assume(!_hasOwner(tokenId));
        vm.expectRevert();
        cut.ownerOf(tokenId);
    }

    /****************************
    *
    * isApprovedForAll() checks.
    *
    ****************************/

    /// @notice Function `isApprovedForAll(address,address)` does not throw when queried about whether some address is an operator of some owner address, by anyone. This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `isApprovedForAll()` on some token did throw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testQueryIsApprovedForAllAddressIsPossible() external {
        (bool success, ) = _tryCustomerIsApprovedForAll(alice, bob, carol);
        assertTrue(success, "Call to `isApprovedForAll()` on some account threw.");
    }
    
    /****************************
    *
    * safeTransferFrom(address,address,uint256,bytes) (with data) checks.
    *
    ****************************/

    /*
    Throwing cases.
    */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToEOA(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(bob, dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(bob, carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        assertFail(_tryAliceSafeTransferFromWithData(fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithDataToEOA(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(carol, bob, dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(carol, bob, carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by someone throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not approve ");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
    }

   //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsSafeTransferFromWithDataToEOAWhenTokenIDIsNotValid(uint256 tokenId, bytes memory data)
    external withUsers() {
        _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(carol, bob, dan, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsSafeTransferFromWithDataToReceiverWhenTokenIDIsNotValid(uint256 tokenId, bytes memory data)
    external withUsers() {
        _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(carol, bob, carol, tokenId, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) throws if `tokenID` (uint256) is not a valid token id.
    function _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        vm.assume(!_hasOwner(tokenId));
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not approve.");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while `tokenID` (uint256) is not a valid id.");
    }

   //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenOwnerSafeTransferFromWithDataToZeroAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertFail(_tryAliceSafeTransferFromWithData(alice, address(0x0), tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the approved address to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, zero address, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testRevertsWhenApprovedAddressSafeTransferFromWithDataToZeroAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve some address.");
        assertFail(_tryBobSafeTransferFromWithData(alice, address(0x0), tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the approved address to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the operator of the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the operator of the token owner to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSomeoneSafeTransferFromWithDataToZeroAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll the initiator of the transfer.");
        assertFail(_tryCustomerSafeTransferFromWithData(bob, alice, address(0x0), tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the operator of the token owner to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsIncorrectReceiverByOwner(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // eve is an incorrect receiver
        assertFail(_tryAliceSafeTransferFromWithData(alice, eve, tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsIncorrectReceiverBySomeone(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerSafeTransferFromWithData(bob, alice, eve, tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received."); 
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromWithDataToEOA(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanSafeTransferFromWithData(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromWithDataToReceiver(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanSafeTransferFromWithData(bob, tokenIdWithOwner, data);
    }


    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) can be initiated by the token owner.
    function _propertyOwnerCanSafeTransferFromWithData(address toAddress, uint256 tokenId, bytes memory data) internal {
        assertSuccess(_tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToEOAUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToReceiverUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(bob, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner updates the ownership.
    function _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(address toAddress, uint256 tokenId, bytes memory data) internal {
        CallResult memory callTransfer = _tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToEOAResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(dan, tokenIdWithOwner, carol, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToReceiverResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(bob, tokenIdWithOwner, carol, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner correctly resets the approved address for that token.
    function _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee, bytes memory data) internal {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Alice could not safeTransferFrom.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by token owner.");
    }

    /*
    Transfer performed by the approved address.
    */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToEOA(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromWithDataToSomeone(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToReceiver(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromWithDataToSomeone(carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) can be initiated by the approved address to some other token receiver.
    function _propertyApprovedAddressCanSafeTransferFromWithDataToSomeone(address toAddress, uint256 tokenId, bytes memory data) internal {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobSafeTransferFromWithData(alice, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToEOAFromToSelf(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromWithDataFromToSelf(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToReceiverFromToSelf(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromWithDataFromToSelf(bob, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) can be initiated by the approved address to self.
    function _propertyApprovedAddressCanSafeTransferFromWithDataFromToSelf(address toAddress, uint256 tokenId, bytes memory data) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryCustomerSafeTransferFromWithData(toAddress, alice, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to itself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved EOA address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByApprovedEOAAddressToSelfUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesOwnership(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByApprovedReceiverAddressToSelfUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesOwnership(bob, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to self correctly updates the ownership.
    function _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesOwnership(address toAddress, uint256 tokenId, bytes memory data) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(toAddress, alice, toAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: the approved address could not safeTransferFrom from Alice to itself.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByApprovedEOAAddressResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(dan, tokenIdWithOwner, carol, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom (with data).
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByApprovedReceiverAddressResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(bob, tokenIdWithOwner, carol, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address correctly resets the approved address for that token.
    function _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee, bytes memory data) internal {
        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve some initial approvee.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(initialApprovee, alice, toAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: initial approvee could not safeTransferFrom from Alice to Bob.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by approved address.");
    }

    /*
    Transfer performed by an operator.
    */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToEOA(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanSafeTransferFromWithDataToSomeone(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToReceiver(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanSafeTransferFromWithDataToSomeone(carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) can be initiated by an operator.
    function _propertyOperatorCanSafeTransferFromWithDataToSomeone(address toAddress, uint256 tokenId, bytes memory data) internal {        
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll.");
        assertSuccess(_tryBobSafeTransferFromWithData(alice, toAddress, tokenId, data), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by an operator to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToSelf(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenIdWithOwner, data), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToSelfUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenIdWithOwner, data)) {
            assertEq(cut.ownerOf(tokenIdWithOwner), bob, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        } 
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToEOAUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOperatorToSomeoneUpdatesOwnership(dan, tokenIdWithOwner, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToReceiverUpdatesOwnership(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromWithDataByOperatorToSomeoneUpdatesOwnership(carol, tokenIdWithOwner, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address correctly updates the ownership.
    function _propertySafeTransferFromWithDataByOperatorToSomeoneUpdatesOwnership(address toAddress, uint256 tokenId, bytes memory data) internal {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(tokenId, data, toAddress)) {
            assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataToEOAByOperatorResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(tokenIdWithOwner, data, bob, dan)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataToReceiverByOperatorResetsApprovedAddress(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(tokenIdWithOwner, data, bob, carol)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /****************************
    *
    * safeTransferFrom(address,address,uint256) checks.
    *
    ****************************/

    /*
    Throwing cases.
    */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(bob, dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(bob, carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by the owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(address fromAddress, address toAddress, uint256 tokenId) internal {
        assertFail(_tryAliceSafeTransferFrom(fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(bob, carol, dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(bob, carol, bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by someone throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not approve.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
    }

   //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsSafeTransferFromToEOAWhenTokenIDIsNotValid(uint256 tokenId)
    external withUsers() {
        _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(bob, carol, dan, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsSafeTransferFromToReceiverWhenTokenIDIsNotValid(uint256 tokenId)
    external withUsers() {
        _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(bob, carol, bob, tokenId);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) throws if `tokenId` (uint256) is not a valid token id.
    function _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(!_hasOwner(tokenId));
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.");
    }

   //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenOwnerSafeTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertFail(_tryAliceSafeTransferFrom(alice, address(0x0), tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the approved address to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, zero address, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testRevertsWhenApprovedAddressSafeTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve some address.");
        assertFail(_tryBobSafeTransferFrom(alice, address(0x0), tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the approved address to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the operator of the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the operator of the token owner to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSomeoneSafeTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll the initiator of the transfer.");
        assertFail(_tryCustomerSafeTransferFrom(bob, alice, address(0x0), tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the operator of the token owner to the zero address.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromToRecipientIsIncorrectReceiverByOwner()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // eve is an incorrect receiver
        assertFail(_tryAliceSafeTransferFrom(alice, eve, tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromToRecipientIsIncorrectReceiverBySomeone()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerSafeTransferFrom(bob, alice, eve, tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received."); 
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanSafeTransferFrom(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanSafeTransferFrom(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by token owner.
    function _propertyOwnerCanSafeTransferFrom(address toAddress, uint256 tokenId) internal {
        assertSuccess(_tryAliceSafeTransferFrom(alice, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToEOAUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToReceiverUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerUpdatesOwnership(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by token owner correctly updates the ownership.
    function _propertySafeTransferFromByOwnerUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToEOAResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerResetsApprovedAddress(dan, tokenIdWithOwner, bob);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToReceiverResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOwnerResetsApprovedAddress(carol, tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by token owner correctly resets the approved address for that token.
    function _propertySafeTransferFromByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Alice could not safeTransferFrom.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by token owner.");
    }

    /*
    Transfer performed by the approved address.
    */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromToSomeone(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromToSomeone(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the approved address to some other token receiver.
    function _propertyApprovedAddressCanSafeTransferFromToSomeone(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobSafeTransferFrom(alice, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToEOAFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromToSelf(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToReceiverFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanSafeTransferFromToSelf(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the approved address to self.
    function _propertyApprovedAddressCanSafeTransferFromToSelf(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryCustomerSafeTransferFrom(toAddress, alice, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address to itself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved EOA address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByApprovedEOAAddressToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSelfUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByApprovedReceiverAddressToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressToSelfUpdatesOwnership(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by the approved address to self correctly updates the ownership.
    function _propertySafeTransferFromByApprovedAddressToSelfUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(toAddress, alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: the approved address could not safeTransferFrom from Alice to itself.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByApprovedEOAAddressResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressResetsApprovedAddress(dan, tokenIdWithOwner, bob);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, safeTransferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByApprovedReceiverAddressResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByApprovedAddressResetsApprovedAddress(carol, tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by the approved address to self correctly resets the approved address for that token.
    function _propertySafeTransferFromByApprovedAddressResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        vm.assume(initialApprovee != address(0x0));

        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve some initial approvee.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(initialApprovee, alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: initial approvee could not safeTransferFrom from Alice to Bob.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by approved address.");
    }

    /*
    Transfer performed by an operator.
    */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanSafeTransferFromToSomeone(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by an operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanSafeTransferFromToSomeone(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by an operator .
    function _propertyOperatorCanSafeTransferFromToSomeone(address toAddress, uint256 tokenId) internal {
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll.");
        assertSuccess(_tryBobSafeTransferFrom(alice, toAddress, tokenId), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by an operator to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenIdWithOwner), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenIdWithOwner)) {
            assertEq(cut.ownerOf(tokenIdWithOwner), bob, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        } 
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToEOAUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToReceiverUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesOwnership(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by an operator correctly updates the ownership.
    function _propertySafeTransferFromByOperatorToSomeoneUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(tokenId, toAddress)) {
            assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromToEOAByOperatorResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenIdWithOwner, bob, dan)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromToReceiverByOperatorResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // The following function call skips the test if the approve or the transferFrom fails
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenIdWithOwner, bob, carol)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /****************************
    *
    * transferFrom(address,address,uint256) checks.
    *
    ****************************/
    

    /*
    Throwing cases.
    */

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(bob, dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(bob, carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(address fromAddress, address toAddress, uint256 tokenId) internal {
       assertFail(_tryAliceTransferFrom(fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(bob, carol, dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(bob, carol, bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by someone throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not approve.");
        assertFail(_tryCustomerTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
    }

   //

    /// @notice A `transferFrom(address,address,uint256)` to an EOA throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsTransferFromToEOAWhenTokenIDIsNotValid(uint256 tokenId)
    external withUsers() {
        _propertyRevertsTransferFromWhenTokenIDIsNotValid(bob, carol, dan, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsTransferFromToReceiverWhenTokenIDIsNotValid(uint256 tokenId)
    external withUsers() {
        _propertyRevertsTransferFromWhenTokenIDIsNotValid(bob, carol, bob, tokenId);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` throws if `tokenID` (uin256) is not a valid token id.
    function _propertyRevertsTransferFromWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(!_hasOwner(tokenId));
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not approve.");
        assertFail(_tryCustomerTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.");
    }

   //

    /// @notice A `transferFrom(address,address,uint256)` by the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenOwnerTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertFail(_tryAliceTransferFrom(alice, address(0x0), tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the approved address to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, zero address, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testRevertsWhenApprovedAddressTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve some address.");
        assertFail(_tryBobTransferFrom(alice, address(0x0), tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated by the approved address to the zero address.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by the operator of the token owner to the zero address throws.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the operator of the token owner to the zero address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, zero address
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenSomeoneTransferFromToZeroAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll the initiator of the transfer.");
        assertFail(_tryCustomerTransferFrom(bob, alice, address(0x0), tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.");
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testOwnerCanTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanTransferFrom(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testOwnerCanTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOwnerCanTransferFrom(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` can be initiated by the token owner.
    function _propertyOwnerCanTransferFrom(address toAddress, uint256 tokenId) internal {
        assertSuccess(_tryAliceTransferFrom(alice, toAddress, tokenId), "A `transferFrom(address,address,uint256)` could not be initiated by the token owner");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToEOAUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToReceiverUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerUpdatesOwnership(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the token owner correctly updates the ownership.
    function _propertyTransferFromByOwnerUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a transferFrom by token owner.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToEOAResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerResetsApprovedAddress(dan, tokenIdWithOwner, bob);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToReceiverResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOwnerResetsApprovedAddress(carol, tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the token owner correctly resets the approved address for that token.
    function _propertyTransferFromByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Alice could not transferFrom.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a transferFrom by token owner.");
    }

    /*
    Transfer performed by the approved address.
    */

    /// @notice A `transferFrom(address,address,uint256)` to an EOA can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanTransferFromToSomeone(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanTransferFromToSomeone(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` can be initiated by the approved address to some other token receiver.
    function _propertyApprovedAddressCanTransferFromToSomeone(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobTransferFrom(alice, toAddress, tokenId), "A `transferFrom(address,address,uint256)` could not be initiated by the approved address.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` to an EOA can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToEOAFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanTransferFromToSelf(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address to itself.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToReceiverFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyApprovedAddressCanTransferFromToSelf(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` can be initiated by the approved address to self.
    function _propertyApprovedAddressCanTransferFromToSelf(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryCustomerTransferFrom(toAddress, alice, toAddress, tokenId), "A `transferFrom(address,address,uint256)` could not be initiated by the approved address to itself.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved EOA address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByApprovedEOAAddressToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressToSelfUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByApprovedReceiverAddressToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressToSelfUpdatesOwnership(bob, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the approved address correctly updates the ownership.
    function _propertyTransferFromByApprovedAddressToSelfUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(toAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(toAddress, alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: the approved address could not transferFrom from Alice to itself.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a transferFrom by token owner.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByApprovedEOAAddressResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressResetsApprovedAddress(dan, tokenIdWithOwner, bob);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve, transferFrom.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByApprovedReceiverAddressResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByApprovedAddressResetsApprovedAddress(carol, tokenIdWithOwner, bob);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the approved address correctly resets the approved address for that token.
    function _propertyTransferFromByApprovedAddressResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        CallResult memory callApprove = _tryAliceApprove(initialApprovee, tokenId);
        // We make sure there was some approvee before the transfer so that the check focuses on the contract resetting the approvee.
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve some initial approvee.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(initialApprovee, alice, toAddress, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: initial approvee could not transferFrom from Alice to Bob.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a transferFrom by approved address.");
    }

    /*
    Transfer performed by an operator.
    */

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToEOA()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanTransferFromToSomeone(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToReceiver()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyOperatorCanTransferFromToSomeone(carol, tokenIdWithOwner);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` can be initiated by an operator.
    function _propertyOperatorCanTransferFromToSomeone(address toAddress, uint256 tokenId) internal {
        CallResult memory callSetApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callSetApproval.success, "Inconclusive test: Alice could not setApprovalForAll.");
        assertSuccess(_tryBobTransferFrom(alice, toAddress, tokenId), "A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by an operator to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.
    /// @custom:ercx-categories transfer, approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToSelf()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenIdWithOwner), "A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToSelfUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenIdWithOwner)) {
            assertEq(cut.ownerOf(tokenIdWithOwner), bob, "Ownership of token has not been transferred after a transferFrom by token owner.");
        } 
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToEOAUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOperatorToSomeoneUpdatesOwnership(dan, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToReceiverUpdatesOwnership()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        _propertyTransferFromByOperatorToSomeoneUpdatesOwnership(carol, tokenIdWithOwner);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some token receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function _propertyTransferFromByOperatorToSomeoneUpdatesOwnership(address toAddress, uint256 tokenId) internal {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(tokenId, toAddress)) {
            assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a transferFrom by token owner.");
        }
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromToEOAByOperatorResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenIdWithOwner, bob, dan)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a transferFrom by operator.");
        }
    }

    /// @notice A `transferFrom(address,address,uint256)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromToReceiverByOperatorResetsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
       if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenIdWithOwner, bob, carol)) {
            assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been reset after a transferFrom by operator.");
        }
    }


    /****************************
    *
    * approve(address,uint256) desirable checks.
    *
    ****************************/

    /// @notice Function `approve(address,uint256)` defines the approved address for an NFT.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesDefinesApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        if (callApprove.success) {
            assertEq(cut.getApproved(tokenIdWithOwner), bob, "Approved address has not been set correctly.");
        }
    }

    /// @notice Function `approve(address,uint256)` can change the approved address for an NFT.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesCanChangeApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(bob, tokenIdWithOwner);
        conditionalSkip(!(callApprove.success && cut.getApproved(tokenIdWithOwner) ==  bob), "Inconclusive test: It was not possible to define the approved address for a token.");
        CallResult memory callApprove2 = _tryAliceApprove(carol, tokenIdWithOwner);
        conditionalSkip(!callApprove2.success, "Inconclusive test: It was not possible to redefine the approved address for a token.");
        assertEq(cut.getApproved(tokenIdWithOwner), carol, "Approved address has not been redefined correctly.");
    }

    /// @notice Function `approve(address,uint256)` can define no approved address by approving the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): approve.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesCanDefineZeroAddressAsApprovedAddress()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(address(0x0), tokenIdWithOwner);
        conditionalSkip(!callApprove.success, "Inconclusive test: It was not possible to approve the zero address for a token.");
        assertEq(cut.getApproved(tokenIdWithOwner), address(0x0), "Approved address has not been set correctly.");
    }

    /// @notice If the zero address is the approved address, then the token owner can transfer the token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the approved address is the zero address, the token owner could not transfer the token.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedTokenOwnerCanTransfer(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        assertSuccess(_tryAliceSafeTransferFromWithData(alice, bob, tokenIdWithOwner, data));
    }

    /// @notice If the zero address is the approved address, then the operator can transfer the token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the approved address is the zero address, the operator could not transfer the token.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedOperatorCanTransfer(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory approvalCall = _tryAliceSetApprovalForAll(carol, true);
        conditionalSkip(!(approvalCall.success && cut.getApproved(tokenIdWithOwner) == address(0x0)), "Inconclusive test: Alice could not approve some operator or approved address is not zero address.");
        assertSuccess(_tryCustomerSafeTransferFromWithData(carol, alice, bob, tokenIdWithOwner, data));
    }

    /// @notice If the zero address is the approved address, then one cannot transfer token to self if not an operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the zero address is the zero address, someone (beyond the owner and operator) could transfer the token.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedOneCannotTransferToSelfIfNotOperator(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(cut.getApproved(tokenIdWithOwner) == address(0x0));
        vm.assume(!cut.isApprovedForAll(alice, bob));
  
        assertFail(_tryBobSafeTransferFromWithData(alice, bob, tokenIdWithOwner, data));
    }

    /// @notice Function `approve(address,uint256)` throws if msg.sender is not the token owner. This test assumes the approve function is payable and some ether are sent when calling approve().
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While msg.sender was not the token owner, approving some address was possible by the msg.sender.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve
    function testApproveRevertsWhenMsgSenderIsNotOwner(uint256 amountPaid) external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        vm.assume(!cut.isApprovedForAll(alice, bob));
        vm.deal(bob, amountPaid);

        vm.startPrank(bob);
        vm.expectRevert();
        cut.approve{value: amountPaid}(carol, tokenIdWithOwner);
    }

    /****************************
    *
    * setApprovalForAll(address,bool) and isApprovedForAll(address,address) checks.
    *
    ****************************/

    /// @notice Function setApprovalForAll(address,bool) can enable an operator to manage all of msg.sender's assets. The operator can transfer all assets of the owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While approving some address as operator, the operator could not manage the assets of msg.sender.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSomeOneAsOperator() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory approvalCall = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!approvalCall.success, "Inconclusive test: Alice could not approve some operator.");
        assertTrue(cut.isApprovedForAll(alice, bob));
    }

    /// @notice Function setApprovalForAll(address,bool) can enable and disable an operator to manage all of msg.sender's assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While approving some address as operator, the address remained as an operator even after being disabled.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableAndDisableSomeOneAsOperator() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory approvalCall = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!(approvalCall.success && cut.isApprovedForAll(alice, bob)), "Inconclusive test: it was not possible to set the operator in the first place.");
        CallResult memory approvalCall2 = _tryAliceSetApprovalForAll(bob, false);
        conditionalSkip(!approvalCall2.success, "Inconclusive test: Alice could not call.");
        assertFalse(cut.isApprovedForAll(alice, bob));
    }

    /// @notice An operator can set any address as approved address for a token owned by the address which granted the operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The operator of an address could not define some address as approved for a token owned by the address which granted the operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following function(s): setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanApproveAnyAddressWhenOperator() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        // Define operator
        CallResult memory callApprove = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not setApprovalForAll.");
        vm.prank(bob);
        cut.approve(carol, tokenIdWithOwner);
        assertEq(cut.getApproved(tokenIdWithOwner), carol);
    }

    /****************************
    *
    * getApproved(uint256) checks.
    *
    ****************************/

    /// @notice Function getApproved(uint256) throws if the parameter is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function getApproved(uint256) did not revert on an invalid token id.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function getApproved, ownerOf
    function testGetApprovedRevertsOnInvalidTokenId(uint256 tokenId) external {
        vm.assume(!_hasOwner(tokenId));
        vm.expectRevert();

        cut.getApproved(tokenId);
    }

    /// @notice Function `getApproved(address)` does not throw when queried about a valid token id by anyone.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token did throw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testQueryApprovedAddressIsPossible() external {
        (bool success, ) = _tryCustomerGetApproved(bob, tokenIdWithOwner);
        assertTrue(success, "Call to getApproved() on some token threw.");
    }

}