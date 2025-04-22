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
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSeveralOperators(address allowingAddress, address[3] calldata allowedOperators) external {
        vm.assume(allowingAddress != address(0x0));
        
        for (uint8 i=0; i < allowedOperators.length;i++) {
            for (uint j=0; j < allowedOperators.length; j++) {
                if (j != i) {
                    vm.assume(allowedOperators[i] != allowedOperators[j]);
                }
            }
            vm.assume(allowedOperators[i] != allowingAddress);
            vm.assume(allowedOperators[i] != address(0x0));
        }
        // First setApproval
        CallResult memory callApproval1 = _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[0], true);
        conditionalSkip(!callApproval1.success, "Inconclusive test: Could not call setApprovalForAll a first time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[0]), "Could not allow one operator.");
        // Second setApproval
        CallResult memory callApproval2 = _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[1], true);
        conditionalSkip(!callApproval2.success, "Inconclusive test: Could not call setApprovalForAll a second time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[1]), "Could not allow a second operator.");
        // Third setApproval
        CallResult memory callApproval3 = _tryCustomerSetApprovalForAll(allowingAddress, allowedOperators[2], true);
        conditionalSkip(!callApproval3.success, "Inconclusive test: Could not call setApprovalForAll a third time.");
        assertTrue(cut.isApprovedForAll(allowingAddress, allowedOperators[2]), "Could not allow a third operator.");
    }


    /****************************
    *****************************
    *                           
    * Other checks on the standard.
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
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOwnerToEOA(uint256 tokenId, address tokenReceiver, bytes memory data) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOwner(tokenId, tokenReceiver, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOwnerToReceiver(uint256 tokenId, bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOwner(tokenId, bob, data);
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
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddressToEOA(uint256 tokenId, address approvedAddress, address tokenReceiver, bytes memory data) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(tokenId, approvedAddress, tokenReceiver, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address of the token.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddressToReceiver(uint256 tokenId, address approvedAddress, bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(tokenId, approvedAddress, bob, data);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (with data) by then approved address of the token.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithDataByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress, bytes memory data) internal {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        if (callApprove.success) {
            vm.expectEmit(true, true, true, false);
            emit Transfer(alice, toAddress, tokenId);
            _tryCustomerSafeTransferFromWithData(approvedAddress, alice, toAddress, tokenId, data);
        }
        else {
            emit log ("Inconclusive test: Alice could not define an approved address.");
        }
    }

    // -- By an operator

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOperatorToEOA(uint256 tokenId, address operator, address tokenReceiver, bytes memory data) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        vm.assume(operator != address(0x0));

        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(tokenId, operator, tokenReceiver, data);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenSafeTransferFromWithDataByOperatorToReceiver(uint256 tokenId, address operator, bytes memory data) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(tokenId, operator, bob, data);
    }

     /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (with data) by an operator.
   function _propertyEventTransferEmitsWhenSafeTransferFromWithDataByOperator(uint256 tokenId, address operator, address toAddress, bytes memory data) internal {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
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
    function testEventTransferEmitsWhenTransferFromWithoutDataByOwnerToEOA(uint256 tokenId, address tokenReceiver) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenId, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by token owner.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOwnerToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenId, bob);
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
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByApprovedAddressToEOA(uint256 tokenId, address approvedAddress, address tokenReceiver) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(tokenId, approvedAddress, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by the approved address of the token.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByApprovedAddressToReceiver(uint256 tokenId, address approvedAddress) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(tokenId, approvedAddress, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (without data) by the approved address.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress) internal {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
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
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOperatorToEOA(uint256 tokenId, address operator, address tokenReceiver)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(tokenId, operator, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `safeTransferFrom(address,address,uint256)` (without data) by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `safeTransferFrom(address,address,uint256)` (without data) by an operator.
    /// @custom:ercx-categories event, safeTranferFrom
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventTransferEmitsWhenTransferFromWithoutDataByOperatorToReceiver(uint256 tokenId, address operator) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(tokenId, operator, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with safeTransferFrom (without data) by an operator.
    function _propertyEventTransferEmitsWhenSafeTransferFromWithoutDataByOperator(uint256 tokenId, address operator, address toAddress) internal {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
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
    function testEventTransferEmitsWhenTransferFromByOwnerToEOA(uint256 tokenId, address tokenReceiver) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromWithoutDataByOwner(tokenId, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by token owner.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOwnerToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromByOwner(tokenId, bob);
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
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByApprovedAddressToEOA(uint256 tokenId, address approvedAddress, address tokenReceiver) 
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(tokenId, approvedAddress, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the approved address of the token to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by the approved address of the token.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByApprovedAddressToReceiver(uint256 tokenId, address approvedAddress) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(tokenId, approvedAddress, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by the approved address.
    function _propertyEventTransferEmitsWhenTransferFromByApprovedAddress(uint256 tokenId, address approvedAddress, address toAddress) internal {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
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
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOperatorToEOA(uint256 tokenId, address operator, address tokenReceiver)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertyEventTransferEmitsWhenTransferFromByOperator(tokenId, operator, tokenReceiver);
    }

    /// @notice Event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` without data by an operator to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback event Transfer was not emitted upon a change of ownership with `transferFrom(address,address,uint256)` by an operator.
    /// @custom:ercx-categories event, transferFrom
    /// @custom:ercx-concerned-function transferFrom
    function testEventTransferEmitsWhenTransferFromByOperatorToReceiver(uint256 tokenId, address operator) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyEventTransferEmitsWhenTransferFromByOperator(tokenId, operator, bob);
    }

    /// @notice Internal property-test checking that event Transfer emits when ownership of tokens changes with `transferFrom(address,address,uint256)` by an operator.
    function _propertyEventTransferEmitsWhenTransferFromByOperator(uint256 tokenId, address operator, address toAddress) internal {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
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
    function testEventApprovalEmitsWhenApprovedIsAffirmed(uint256 tokenId, address tokenApprovee) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenApprovee != address(0x0));
        vm.assume(tokenApprovee != alice); // msg.sender cannot approve herself in some contracts
        // Making sure the token has no approvee.
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, tokenApprovee, tokenId);
        _tryAliceApprove(tokenApprovee, tokenId);
    }

    /// @notice Event Approval emits when approval is reaffirmed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event Approval was not emitted when an approvas was reaffirmed.
    /// @custom:ercx-categories event
    /// @custom:ercx-concerned-function safeTranferFrom
    function testEventApprovalEmitsWhenApprovedIsReAffirmed(uint256 tokenId, address tokenApprovee) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenApprovee != address(0x0));
        vm.assume(tokenApprovee != alice); // msg.sender cannot approve herself in some contracts
        // Affirming approval.
        _tryAliceApprove(tokenApprovee, tokenId);
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, tokenApprovee, tokenId);
        // Reaffirming approval
        _tryAliceApprove(tokenApprovee, tokenId);
    }

    /// @notice Event Approval emits when approval is changed.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event Approval was not emitted when an approvas was changed.
    /// @custom:ercx-categories event
    /// @custom:ercx-concerned-function approve
    function testEventApprovalEmitsWhenApprovedIsChanged(uint256 tokenId, address tokenApprovee) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenApprovee != address(0x0));
        vm.assume(tokenApprovee != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(bob != tokenApprovee);
        // Affirming approval to Bob.
        _tryAliceApprove(bob, tokenId);
        vm.expectEmit(true, true, true, false);
        emit Approval(alice, tokenApprovee, tokenId);
        // Changing approval
        _tryAliceApprove(tokenApprovee, tokenId);
    }

    /* ApprovalForAll event */

    /// @notice Event ApprovalForAll emits when an operator is enabled.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event ApprovalForAll was not emitted when an operator was enabled.
    /// @custom:ercx-categories event, approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testEventApprovalForAllEmitsWhenOperatorIsEnabled(uint256 tokenId, address operator) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        vm.expectEmit(true, true, true, false);
        emit ApprovalForAll(alice, operator, true);
        _tryAliceSetApprovalForAll(operator, true);
    }

    /// @notice Event ApprovalForAll emits when an operator is disabled.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Event ApprovalForAll was not emitted when an operator was disabled.
    /// @custom:ercx-categories event, approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testEventApprovalForAllEmitsWhenOperatorIsDisabled(uint256 tokenId, address operator) 
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        vm.expectEmit(true, true, true, false);
        emit ApprovalForAll(alice, operator, false);
        _tryAliceSetApprovalForAll(operator, false);
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
    function testQueryBalanceIsPossible(address customer, address account) external {
        vm.assume(account != address(0x0));
        vm.assume(customer != address(0x0));
        (bool success, ) = _tryCustomerBalanceOf(customer, account);
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
    function testUserBalanceIncrementedAfterReceivingAnOwnedToken(uint256 tokenId)
    external withUsers() {
        uint256 initialAliceBalance = cut.balanceOf(alice);
        _dealAnOwnedTokenToAlice(tokenId);
        assertEq(cut.balanceOf(alice), initialAliceBalance + 1, "The value of `balanceOf(alice)` has not been incremented after a token was given to her.");
    }

    /// @notice A successful `balanceOf(account)` returns the updated balance of an `account` correctly when the user receives some tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A successful `balanceOf(account)` call does NOT return balance of `account` correctly.
    /// @custom:ercx-categories balance
    /// @custom:ercx-concerned-function balanceOf
    function testUserBalanceCorrectAfterReceivingSeveralTokens(uint256[3] calldata tokenIds)
    external withUsers() {
        uint256 initiaAlicelBalance = cut.balanceOf(alice);
        _dealSeveralOwnedTokensToAlice(tokenIds);
        assertEq(cut.balanceOf(alice), initiaAlicelBalance + tokenIds.length, "The value of balanceOf(alice) does not equate the amount of tokens given to her.");
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
    function testOwnerOfUpdated(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertEq(cut.ownerOf(tokenId), alice, "The value of `ownerOf(tokenId)` does not equate the owner of the token.");
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
    function testQueryIsApprovedForAllAddressIsPossible(address customer, address owner, address operator) external {
        vm.assume(customer != address(0x0));
        vm.assume(owner != address(0x0));
        vm.assume(operator != address(0x0));
        vm.assume(operator != customer);
        (bool success, ) = _tryCustomerIsApprovedForAll(customer, owner, operator);
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
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToEOA(address fromAddress, address toAddress, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(fromAddress, toAddress, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(address fromAddress, uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(fromAddress, bob, tokenId, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        vm.assume(fromAddress != alice);
        vm.assume(fromAddress != address(0x0));
        vm.assume(toAddress != address(0x0));
        
        assertFail(_tryAliceSafeTransferFromWithData(fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithDataToEOA(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(transferInitiator, fromAddress, toAddress, tokenId, data);
   }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithDataToReceiver(address transferInitiator, address fromAddress, uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(transferInitiator, fromAddress, bob, tokenId, data);
   }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by someone throws if `_from` (the first address) is not the token owner.
   function _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromWithData(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(fromAddress != alice);
        vm.assume(transferInitiator != address(0x0));
        vm.assume(fromAddress != address(0x0));
        vm.assume(toAddress != address(0x0));

        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll ");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
   }

   //

   /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsSafeTransferFromWithDataToEOAWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data)
   external withUsers() ensureNotATokenReceiver(toAddress) {
        _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(transferInitiator, fromAddress, toAddress, tokenId, data);
   }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsSafeTransferFromWithDataToReceiverWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, uint256 tokenId, bytes memory data)
   external withUsers() {
        _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(transferInitiator, fromAddress, bob, tokenId, data);
   }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) throws if `tokenID` (uint256) is not a valid token id.
    function _propertyRevertsSafeTransferFromWithDataWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId, bytes memory data) internal {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(fromAddress != address(0x0));
        vm.assume(toAddress != address(0x0));
        vm.assume(!_hasOwner(tokenId));
        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll.");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, fromAddress, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` (with data) did not throw while `tokenID` (uint256) is not a valid id.");
   }

   //

   /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsWhenOwnerSafeTransferFromWithDataToZeroAddress(uint256 tokenId, bytes memory data)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertFail(_tryAliceSafeTransferFromWithData(alice, address(0x0), tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.");
   }

   /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the approved address to the zero address.
   /// @custom:ercx-categories transfer, zero address, approval
   /// @custom:ercx-concerned-function safeTransferFrom, approve
   function testRevertsWhenApprovedAddressSafeTransferFromWithDataToZeroAddress(uint256 tokenId, bytes memory data)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve some address."); 
        assertFail(_tryBobSafeTransferFromWithData(alice, address(0x0), tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the approved address to the zero address.");
   }

   /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by some address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsWhenSomeoneSafeTransferFromWithDataToZeroAddress(uint256 tokenId, address transferInitiator, bytes memory data)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, alice, address(0x0), tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to the zero address.");
   }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsIncorrectReceiverByOwner(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        // eve is an incorrect receiver
        assertFail(_tryAliceSafeTransferFromWithData(alice, eve, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsIncorrectReceiverBySomeone(uint256 tokenId, address transferInitiator, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, alice, eve, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromWithDataToEOA(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyOwnerCanSafeTransferFromWithData(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromWithDataToReceiver(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOwnerCanSafeTransferFromWithData(bob, tokenId, data);
    }


    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) can be initiated by the token owner.
    function _propertyOwnerCanSafeTransferFromWithData(address toAddress, uint256 tokenId, bytes memory data) internal {
        assertSuccess(_tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToReceiverUpdatesOwnership(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(bob, tokenId, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner updates the ownership.
    function _propertySafeTransferFromWithDataByOwnerUpdatesOwnership(address toAddress, uint256 tokenId, bytes memory data) internal {
        vm.assume(toAddress != address(0x0));
        CallResult memory callTransfer = _tryAliceSafeTransferFromWithData(alice, toAddress, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(cut.ownerOf(tokenId), toAddress, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToEOAResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByOwnerToReceiverResetsApprovedAddress(uint256 tokenId, address initialApprovee, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(bob, tokenId, initialApprovee, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner correctly resets the approved address for that token.
    function _propertySafeTransferFromWithDataByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee, bytes memory data) internal {
        vm.assume(initialApprovee != address(0x0));
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToEOA(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanSafeTransferFromWithDataToSomeone(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToReceiver(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanSafeTransferFromWithDataToSomeone(carol, tokenId, data);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToEOAFromToSelf(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanSafeTransferFromWithDataFromToSelf(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to itself.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromWithDataToReceiverFromToSelf(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanSafeTransferFromWithDataFromToSelf(bob, tokenId, data);
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
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByApprovedEOAAddressToSelfUpdatesOwnership(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesOwnership(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, ownership was not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByApprovedReceiverAddressToSelfUpdatesOwnership(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesOwnership(bob, tokenId, data);
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
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByApprovedEOAAddressResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataByApprovedReceiverAddressResetsApprovedAddress(uint256 tokenId, address initialApprovee, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(bob, tokenId, initialApprovee, data);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address correctly resets the approved address for that token.
    function _propertySafeTransferFromWithDataByApprovedAddressResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee, bytes memory data) internal {
        vm.assume(toAddress != address(0x0));
        vm.assume(initialApprovee != address(0x0));

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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToEOA(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanSafeTransferFromWithDataToSomeone(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToReceiver(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanSafeTransferFromWithDataToSomeone(carol, tokenId, data);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromWithDataToSelf(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenId, data), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToSelfUpdatesOwnership(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenId, data)) {
            assertEq(cut.ownerOf(tokenId), bob, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        } 
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertySafeTransferFromWithDataByOperatorToSomeoneUpdatesOwnership(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromWithDataByOperatorToReceiverUpdatesOwnership(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByOperatorToSomeoneUpdatesOwnership(carol, tokenId, data);
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
    function testSafeTransferFromWithDataToEOAByOperatorResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address operator, bytes memory data)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(tokenId, data, operator, tokenReceiver)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromWithDataToReceiverByOperatorResetsApprovedAddress(uint256 tokenId, address operator, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromWithDataToSomeone(tokenId, data, operator, bob)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
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
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToEOA(address fromAddress, address toAddress, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(fromAddress, toAddress, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(address fromAddress, uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(fromAddress, bob, tokenId);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by the owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInSafeTransferFromToReceiver(address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(fromAddress != alice);
        vm.assume(fromAddress != address(0x0));
        
        assertFail(_tryAliceSafeTransferFrom(fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromToEOA(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(transferInitiator, fromAddress, toAddress, tokenId);
   }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFromToReceiver(address transferInitiator, address fromAddress, uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(transferInitiator, fromAddress, bob, tokenId);
   }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by someone throws if `_from` (the first address) is not the token owner.
   function _propertyRevertsBySomeoneWhenOwnerIsNotFromInSafeTransferFrom(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(fromAddress != alice);
        vm.assume(fromAddress != address(0x0));

        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
   }

   //

   /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsSafeTransferFromToEOAWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId)
   external withUsers() ensureNotATokenReceiver(toAddress) {
        _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(transferInitiator, fromAddress, toAddress, tokenId);
   }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsSafeTransferFromToReceiverWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, uint256 tokenId)
   external withUsers() {
        _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(transferInitiator, fromAddress, bob, tokenId);
   }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) throws if `tokenId` (uint256) is not a valid token id.
   function _propertyRevertsSafeTransferFromWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(fromAddress != address(0x0));
        vm.assume(!_hasOwner(tokenId));

        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.");
   }

   //

   /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsWhenOwnerSafeTransferFromToZeroAddress(uint256 tokenId)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertFail(_tryAliceSafeTransferFrom(alice, address(0x0), tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.");
   }

   /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the approved address to the zero address.
   /// @custom:ercx-categories transfer, zero address, approval
   /// @custom:ercx-concerned-function safeTransferFrom, approve
   function testRevertsWhenApprovedAddressSafeTransferFromToZeroAddress(uint256 tokenId)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve some address.");
        assertFail(_tryBobSafeTransferFrom(alice, address(0x0), tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the approved address to the zero address.");
   }

   /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by some address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function safeTransferFrom
   function testRevertsWhenSomeoneSafeTransferFromToZeroAddress(uint256 tokenId, address transferInitiator)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, alice, address(0x0), tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated by the token owner to the zero address.");
   }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromToRecipientIsIncorrectReceiverByOwner(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        // eve is an incorrect receiver
        assertFail(_tryAliceSafeTransferFrom(alice, eve, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromToRecipientIsIncorrectReceiverBySomeone(uint256 tokenId, address transferInitiator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, alice, eve, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received."); 
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyOwnerCanSafeTransferFrom(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testOwnerCanSafeTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOwnerCanSafeTransferFrom(bob, tokenId);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by token owner.
    function _propertyOwnerCanSafeTransferFrom(address toAddress, uint256 tokenId) internal {
        assertSuccess(_tryAliceSafeTransferFrom(alice, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the token owner");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByOwnerUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToReceiverUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByOwnerUpdatesOwnership(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToEOAResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertySafeTransferFromByOwnerResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByOwnerToReceiverResetsApprovedAddress(uint256 tokenId, address initialApprovee)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByOwnerResetsApprovedAddress(bob, tokenId, initialApprovee);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) by token owner correctly resets the approved address for that token.
    function _propertySafeTransferFromByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        vm.assume(initialApprovee != address(0x0));
        
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanSafeTransferFromToSomeone(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanSafeTransferFromToSomeone(carol, tokenId);
    }

    /// @notice Internal property-test checking that a `safeTransferFrom(address,address,uint256)` (without data) can be initiated by the approved address to some other token receiver.
    function _propertyApprovedAddressCanSafeTransferFromToSomeone(address toAddress, uint256 tokenId) internal {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip (!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        assertSuccess(_tryBobSafeTransferFrom(alice, toAddress, tokenId), "A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address to itself.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToEOAFromToSelf(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanSafeTransferFromToSelf(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` (without data) could not be initiated by the approved address to itself.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testApprovedAddressCanSafeTransferFromToReceiverFromToSelf(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanSafeTransferFromToSelf(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByApprovedEOAAddressToSelfUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByApprovedAddressToSelfUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByApprovedReceiverAddressToSelfUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByApprovedAddressToSelfUpdatesOwnership(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByApprovedEOAAddressResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByApprovedAddressResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromByApprovedReceiverAddressResetsApprovedAddress(uint256 tokenId, address initialApprovee)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByApprovedAddressResetsApprovedAddress(bob, tokenId, initialApprovee);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanSafeTransferFromToSomeone(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by an operator.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanSafeTransferFromToSomeone(carol, tokenId);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function safeTransferFrom, approve
    function testOperatorCanSafeTransferFromToSelf(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenId), "A safeTransferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToSelfUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenId)) {
            assertEq(cut.ownerOf(tokenId), bob, "Ownership of token has not been transferred after a safeTransferFrom by token owner.");
        } 
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertySafeTransferFromByOperatorToSomeoneUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an operator to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf, approve
    function testSafeTransferFromByOperatorToReceiverUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesOwnership(carol, tokenId);
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
    function testSafeTransferFromToEOAByOperatorResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address operator)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, operator, tokenReceiver)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
        }
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function safeTransferFrom, ownerOf
    function testSafeTransferFromToReceiverByOperatorResetsApprovedAddress(uint256 tokenId, address operator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, operator, bob)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a safeTransferFrom by operator.");
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
    function testRevertsByOwnerWhenOwnerIsNotFromInTransferFromToEOA(address fromAddress, address toAddress, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(fromAddress, toAddress, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface by the owner throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(address fromAddress, uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(fromAddress, bob, tokenId);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the owner throws if `_from` (the first address) is not the token owner.
    function _propertyRevertsByOwnerWhenOwnerIsNotFromInTransferFromToReceiver(address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(fromAddress != alice);
        vm.assume(fromAddress != address(0x0));
        
        assertFail(_tryAliceTransferFrom(fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` (with data) did not throw while the `_from` (the first address) is not the token owner and the `_from`initiated the transfer.");
    }

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to an EOA did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInTransferFromToEOA(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(toAddress) dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(transferInitiator, fromAddress, toAddress, tokenId);
   }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by someone throws if `_from` (the first address) is not the token owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testRevertsBySomeoneWhenOwnerIsNotFromInTransferFromToReceiver(address transferInitiator, address fromAddress, uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(transferInitiator, fromAddress, bob, tokenId);
   }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by someone throws if `_from` (the first address) is not the token owner.
   function _propertyRevertsBySomeoneWhenOwnerIsNotFromInTransferFrom(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(transferInitiator != address(0x0));
        vm.assume(fromAddress != alice);
        vm.assume(fromAddress != address(0x0));

        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll.");
        assertFail(_tryCustomerTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` did not throw while the `_from` (the first address) is not the token owner and someone initiated the transfer.");
   }

   //

   /// @notice A `transferFrom(address,address,uint256)` to an EOA throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function transferFrom
   function testRevertsTransferFromToEOAWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId)
   external withUsers() ensureNotATokenReceiver(toAddress) {
        _propertyRevertsTransferFromWhenTokenIDIsNotValid(transferInitiator, fromAddress, toAddress, tokenId);
   }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface throws if `tokenID` (uint256) is not a valid token id.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver did not throw while `tokenID` (uint256) is not a valid id.
   /// @custom:ercx-categories transfer
   /// @custom:ercx-concerned-function transferFrom
   function testRevertsTransferFromToReceiverWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, uint256 tokenId)
   external withUsers() {
        _propertyRevertsTransferFromWhenTokenIDIsNotValid(transferInitiator, fromAddress, bob, tokenId);
   }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` throws if `tokenID` (uin256) is not a valid token id.
    function _propertyRevertsTransferFromWhenTokenIDIsNotValid(address transferInitiator, address fromAddress, address toAddress, uint256 tokenId) internal {
        vm.assume(!_hasOwner(tokenId));
        vm.assume(transferInitiator != address(0x0));
        vm.assume(fromAddress != address(0x0));

        CallResult memory callApprove = _tryCustomerApprove(fromAddress, transferInitiator, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Could not setApprovalForAll.");
        assertFail(_tryCustomerTransferFrom(transferInitiator, fromAddress, toAddress, tokenId), "A `transferFrom(address,address,uint256)` did not throw while `tokenID` (uint256) is not a valid id.");
   }

   //

   /// @notice A `transferFrom(address,address,uint256)` by the token owner to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function transferFrom
   function testRevertsWhenOwnerTransferFromToZeroAddress(uint256 tokenId)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertFail(_tryAliceTransferFrom(alice, address(0x0), tokenId), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.");
   }

   /// @notice A `transferFrom(address,address,uint256)` by the approved address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the approved address to the zero address.
   /// @custom:ercx-categories transfer, zero address, approval
   /// @custom:ercx-concerned-function transferFrom, approve
   function testRevertsWhenApprovedAddressTransferFromToZeroAddress(uint256 tokenId)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: could not approve some address.");
        assertFail(_tryBobTransferFrom(alice, address(0x0), tokenId), "A `transferFrom(address,address,uint256)` could be initiated by the approved address to the zero address.");
   }

   /// @notice A `transferFrom(address,address,uint256)` by some address to the zero address throws.
   /// @custom:ercx-expected pass
   /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.
   /// @custom:ercx-categories transfer, zero address
   /// @custom:ercx-concerned-function transferFrom
   function testRevertsWhenSomeoneTransferFromToZeroAddress(uint256 tokenId, address transferInitiator)
   external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
            assertFail(_tryCustomerTransferFrom(transferInitiator, alice, address(0x0), tokenId), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to the zero address.");
   }

    /// @notice A `transferFrom(address,address,uint256)` by token owner throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenTransferFromToRecipientIsIncorrectReceiverByOwner(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        // eve is an incorrect receiver
        assertFail(_tryAliceTransferFrom(alice, eve, tokenId), "A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received.");
    }

    /// @notice A `transferFrom(address,address,uint256)` by someone throws if the recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) when calling onERC721Received.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenTransferFromToRecipientIsIncorrectReceiverBySomeone(uint256 tokenId, address transferInitiator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        CallResult memory callApprove = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve the initiator of the transfer.");
        // eve is an incorrect receiver
        assertFail(_tryCustomerTransferFrom(transferInitiator, alice, eve, tokenId), "A `transferFrom(address,address,uint256)` could be initiated when recipient does not return bytes4(keccak256(...)) when calling onERC721Received."); 
    }

    /*
    Transfer performed by the token owner.
    */

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by the token owner to an EOA.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testOwnerCanTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyOwnerCanTransferFrom(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by the token owner to a contract implementing the ERC721Receiver interface.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the token owner.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testOwnerCanTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOwnerCanTransferFrom(bob, tokenId);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` can be initiated by the token owner.
    function _propertyOwnerCanTransferFrom(address toAddress, uint256 tokenId) internal {
        assertSuccess(_tryAliceTransferFrom(alice, toAddress, tokenId), "A `transferFrom(address,address,uint256)` could not be initiated by the token owner");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the token owner to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByOwnerUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the token owner to a contract implementing the ERC721Receiver correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToReceiverUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByOwnerUpdatesOwnership(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToEOAResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertyTransferFromByOwnerResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the token owner correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByOwnerToReceiverResetsApprovedAddress(uint256 tokenId, address initialApprovee)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByOwnerResetsApprovedAddress(bob, tokenId, initialApprovee);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the token owner correctly resets the approved address for that token.
    function _propertyTransferFromByOwnerResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        vm.assume(initialApprovee != address(0x0));
        
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanTransferFromToSomeone(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface can be initiated by the approved address to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanTransferFromToSomeone(carol, tokenId);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToEOAFromToSelf(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertyApprovedAddressCanTransferFromToSelf(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver can be initiated by the approved address to self.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could not be initiated by the approved address to itself.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testApprovedAddressCanTransferFromToReceiverFromToSelf(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyApprovedAddressCanTransferFromToSelf(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByApprovedEOAAddressToSelfUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByApprovedAddressToSelfUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved Receiver address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, ownership was not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByApprovedReceiverAddressToSelfUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByApprovedAddressToSelfUpdatesOwnership(bob, tokenId);
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
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByApprovedEOAAddressResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address initialApprovee)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByApprovedAddressResetsApprovedAddress(tokenReceiver, tokenId, initialApprovee);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver interface by the approved address correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromByApprovedReceiverAddressResetsApprovedAddress(uint256 tokenId, address initialApprovee)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByApprovedAddressResetsApprovedAddress(bob, tokenId, initialApprovee);
    }

    /// @notice Internal property-test checking that a `transferFrom(address,address,uint256)` by the approved address correctly resets the approved address for that token.
    function _propertyTransferFromByApprovedAddressResetsApprovedAddress(address toAddress, uint256 tokenId, address initialApprovee) internal {
        vm.assume(initialApprovee != address(0x0));

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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToEOA(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanTransferFromToSomeone(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` can be initiated by an operator to some other token receiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address.
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToReceiver(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyOperatorCanTransferFromToSomeone(carol, tokenId);
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
    /// @custom:ercx-categories transfer approval
    /// @custom:ercx-concerned-function transferFrom, approve
    function testOperatorCanTransferFromToSelf(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertTrue(_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenId), "A transferFrom(address,address,uint256,bytes)` could not be initiated by the approved address to himself.");
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to self correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToSelfUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenId)) {
            assertEq(cut.ownerOf(tokenId), bob, "Ownership of token has not been transferred after a transferFrom by token owner.");
        } 
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to an EOA correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToEOAUpdatesOwnership(address tokenReceiver, uint256 tokenId)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));

        _propertyTransferFromByOperatorToSomeoneUpdatesOwnership(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some contract implementing the ERC721Receiver interface correctly updates the ownership.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, ownership, approval
    /// @custom:ercx-concerned-function transferFrom, ownerOf, approve
    function testTransferFromByOperatorToReceiverUpdatesOwnership(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        _propertyTransferFromByOperatorToSomeoneUpdatesOwnership(carol, tokenId);
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
    function testTransferFromToEOAByOperatorResetsApprovedAddress(address tokenReceiver, uint256 tokenId, address operator)
    external withUsers() ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, operator, tokenReceiver)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a transferFrom by operator.");
        }
    }

    /// @notice A `transferFrom(address,address,uint256)` contract implementing the ERC721Receiver interface by an operator correctly resets the approved address for that token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, the approved address was not reset.
    /// @custom:ercx-categories transfer, ownership
    /// @custom:ercx-concerned-function transferFrom, ownerOf
    function testTransferFromToReceiverByOperatorResetsApprovedAddress(uint256 tokenId, address operator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
       if (_AliceSetApprovedForAllCustomerAndCustomerSafeTransfersFromToSomeone(tokenId, operator, bob)) {
            assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been reset after a transferFrom by operator.");
        }
    }


    /****************************
    *
    * approve(address,uint256) desirable checks.
    *
    ****************************/

    /// @notice Function approve(address,uint256) defines the approved address for an NFT.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesDefinesApprovedAddress(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        if (callApprove.success) {
            assertEq(cut.getApproved(tokenId), bob, "Approved address has not been set correctly.");
        }
    }

    /// @notice Function approve(address,uint256) can change the approved address for an NFT.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesCanChangeApprovedAddress(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!(callApprove.success && cut.getApproved(tokenId) ==  bob), "Inconclusive test: It was not possible to define the approved address for a token.");
        CallResult memory callApprove2 = _tryAliceApprove(carol, tokenId);
        conditionalSkip(!callApprove2.success, "Inconclusive test: It was not possible to redefine the approved address for a token.");
        assertEq(cut.getApproved(tokenId), carol, "Approved address has not been redefined correctly.");
    }

    /// @notice Function approve(address,uint256) can define no approved address by approving the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a call to `approve(address,uint256)`, the address was not set as the approved address for the NFT.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testApprovesCanDefineZeroAddressAsApprovedAddress(uint256 tokenId)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        CallResult memory callApprove = _tryAliceApprove(address(0x0), tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: It was not possible to approve the zero address for a token.");
        assertEq(cut.getApproved(tokenId), address(0x0), "Approved address has not been set correctly.");
    }

    /// @notice If the zero address is the approved address, then the token owner can transfer the token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the approved address is the zero address, the token owner could not transfer the token.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedTokenOwnerCanTransfer(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        assertSuccess(_tryAliceSafeTransferFromWithData(alice, bob, tokenId, data));
    }

    /// @notice If the zero address is the approved address, then the operator can transfer the token.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the approved address is the zero address, the operator could not transfer the token.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedOperatorCanTransfer(uint256 tokenId, address tokenOperator, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenOperator != address(0x0));
        vm.assume(tokenOperator != alice); // msg.sender cannot approve herself in some contracts
        CallResult memory approvalCall = _tryAliceSetApprovalForAll(tokenOperator, true);
        conditionalSkip(!(approvalCall.success && cut.getApproved(tokenId) == address(0x0)), "Inconclusive test: Alice could not approve some operator or approved address is not zero address.");
        assertSuccess(_tryCustomerSafeTransferFromWithData(tokenOperator, alice, bob, tokenId, data));
    }

    /// @notice If the zero address is the approved address, then one cannot transfer token to self if not an operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Even when the zero address is the zero address, someone (beyond the owner and operator) could transfer the token.
    /// @custom:ercx-categories approval, zero address
    /// @custom:ercx-concerned-function approve, getApproved
    function testWhenZeroAddressIsApprovedOneCannotTransferToSelfIfNotOperator(uint256 tokenId, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(cut.getApproved(tokenId) == address(0x0));
        vm.assume(!cut.isApprovedForAll(alice, bob));
  
        assertFail(_tryBobSafeTransferFromWithData(alice, bob, tokenId, data));
    }

    /// @notice Function approve(address,uint256) throws if msg.sender is not the token owner. This test assumes the approve function is payable and some ether are sent when calling approve().
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While msg.sender was not the token owner, approving some address was possible by the msg.sender.
    /// @custom:ercx-categories approval, 
    /// @custom:ercx-concerned-function approve
    function testApproveRevertsWhenMsgSenderIsNotOwner(uint256 tokenId, address tokenApprover, uint256 amountPaid) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenApprover != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(tokenApprover != address(0x0));
        vm.assume(!cut.isApprovedForAll(alice, tokenApprover));
        vm.deal(tokenApprover, amountPaid);

        vm.startPrank(tokenApprover);
        vm.expectRevert();
        cut.approve{value: amountPaid}(bob, tokenId);
    }

    /****************************
    *
    * setApprovalForAll(address,bool) and isApprovedForAll(address,address) checks.
    *
    ****************************/

    /// @notice Function setApprovalForAll(address,bool) can enable an operator to manage all of msg.sender's assets. The operator can transfer all assets of the owner.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While approving some address as operator, the operator could not manage the assets of msg.sender.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSomeOneAsOperator(address tokenOperator, uint256 tokenId) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenOperator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(tokenOperator != address(0x0));

        CallResult memory approvalCall = _tryAliceSetApprovalForAll(tokenOperator, true);
        conditionalSkip(!approvalCall.success, "Inconclusive test: Alice could not approve some operator.");
        assertTrue(cut.isApprovedForAll(alice, tokenOperator));
    }

    /// @notice Function setApprovalForAll(address,bool) can enable and disable an operator to manage all of msg.sender's assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback While approving some address as operator, the address remained as an operator even after being disabled.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableAndDisableSomeOneAsOperator(address tokenOperator, uint256 tokenId) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenOperator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(tokenOperator != address(0x0));

        CallResult memory approvalCall = _tryAliceSetApprovalForAll(tokenOperator, true);
        conditionalSkip(!(approvalCall.success && cut.isApprovedForAll(alice, tokenOperator)), "Inconclusive test: it was not possible to set the operator in the first place.");
        CallResult memory approvalCall2 = _tryAliceSetApprovalForAll(tokenOperator, false);
        conditionalSkip(!approvalCall2.success, "Inconclusive test: Alice could not call.");
        assertFalse(cut.isApprovedForAll(alice, tokenOperator));
    }

    /// @notice An operator can set any address as approved address for a token owned by the address which granted the operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The operator of an address could not define some address as approved for a token owned by the address which granted the operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanApproveAnyAddressWhenOperator(uint256 tokenId, address operator, address tokenApprovee) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        vm.assume(tokenApprovee != address(0x0));
        vm.assume(tokenApprovee != alice); // msg.sender cannot approve herself in some contracts
        // Define operator
        CallResult memory callApprove = _tryAliceSetApprovalForAll(operator, true);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        vm.prank(operator);
        cut.approve(tokenApprovee, tokenId);
        assertEq(cut.getApproved(tokenId), tokenApprovee);
    }

    /****************************
    *
    * getApproved(uint256) checks.
    *
    ****************************/

    /// @notice Function getApprove(uint256) throws if the parameter is not a valid token id.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function getApprove(uint256) did not revert on an invalid token id.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function getApprove, ownerOf
    function testGetApproveRevertsOnInvalidTokenId(uint256 tokenId) external {
        vm.assume(!_hasOwner(tokenId));
        vm.expectRevert();

        cut.getApproved(tokenId);
    }

    /// @notice Function `getApproved(address)` does not throw when queried about a valid token id by anyone.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token did throw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testQueryApprovedAddressIsPossible(address customer, uint256 tokenId) external {
        vm.assume(customer != address(0x0));
        vm.assume(tokenId != 0);
        vm.assume(_hasOwner(tokenId));

        (bool success, ) = _tryCustomerGetApproved(customer, tokenId);
        assertTrue(success, "Call to getApproved() on some token threw.");
    }

}