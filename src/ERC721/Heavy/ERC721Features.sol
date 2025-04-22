// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC721Abstract.sol";

/// @notice Abstract contract that consists of testing functions with test for properties 
/// that are neither desirable nor undesirable but instead implementation choices.
abstract contract ERC721Features is ERC721Abstract {

    /***********************************************************************************
    * Glossary                                                                         *
    * -------------------------------------------------------------------------------- *
    * tokenSender   : address that sends tokens (usually in a transaction)             *
    * tokenReceiver : address that receives tokens (usually in a transaction)          *
    * tokenApprover : address that approves tokens (usually in an approval)            *
    * tokenApprovee : address that tokenApprover approves of (usually in an approval)  *
    ***********************************************************************************/


   /****************************
    *
    * isApprovedForAll feature tests.
    *
    ****************************/

    /// @notice Users without token are operators for themselves. Note: the zero address is not considered.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token does not have oneself as operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsApprovedForAllReflexiveForUsersWithoutTokens(address querier, address user) external
    withUsers() {
        vm.assume(user != address(0x0));
        vm.assume(cut.balanceOf(user) == 0);

        assertTrue(_propertyIsOperatorForSelf(querier, user));
    }

    /// @notice Users without token are not operators for themselves. Note: the zero address is not considered.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token has oneself as operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsNotApprovedForAllReflexiveForUsersWithoutTokens(address querier, address user) external
    withUsers() {
        vm.assume(user != address(0x0));
        vm.assume(cut.balanceOf(user) == 0);

        assertFalse(_propertyIsOperatorForSelf(querier, user));
    }

    /// @notice Users with tokens are operators for themselves.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token does not have oneself as operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsApprovedForAllReflexiveForUsersWithTokens(address querier, uint256 tokenId) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertTrue(_propertyIsOperatorForSelf(querier, alice));
    }

    /// @notice Users with tokens are not operators for themselves.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token has oneself as operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsNotApprovedForAllReflexiveForUsersWithTokens(address querier, uint256 tokenId) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        assertFalse(_propertyIsOperatorForSelf(querier, alice));
    }

    function _propertyIsOperatorForSelf(address querier, address user) internal returns (bool) {
        vm.assume(querier != address(0x0));
        
        (bool success, bool result) = _tryCustomerIsApprovedForAll(querier, user, user);
        conditionalSkip(!success, "Inconclusive test: Could not call isApprovedForAll.");
        return result;
    }

    /// @notice The zero address can query about whether some address is an operator.
    /// @notice This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible for the zero address to query whether some address is an operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testZeroAddressCanQueryWhetherAnyoneIsOperatorOfAnyone(address tokenOwner, address tokenOperator) external
    withUsers() {
        vm.assume(tokenOwner != address(0x0));
        vm.assume(tokenOperator != address(0x0));
        
        (bool success, ) = _tryCustomerIsApprovedForAll(address(0x0), tokenOwner, tokenOperator);
        assertTrue(success, "It was not possible for the zero address to query whether some address is an operator.");
    }

    /// @notice Any address can query about whether the zero address is an operator of some other address.
    /// @notice This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An address could not query whether the zero address is an operator of some other address.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnyoneCanQueryWhetherZeroAddressIsOperatorOfAnyone(address approvalQuerier, address approver) external
    withUsers() {
        vm.assume(approvalQuerier != address(0x0));
        vm.assume(approver != address(0x0));
        
        (bool success, ) = _tryCustomerIsApprovedForAll(approvalQuerier, approver, address(0x0));
        assertTrue(success, "An address could not query whether the zero address is an operator of some other address.");
    }

    /// @notice Any address can query about whether any address is an operator of the zero address.
    /// @notice This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An address could not query about whether some address is an operator of the zero address.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnyoneCanQueryWhetherAnyoneIsOperatorOfZeroAddress(address approvalQuerier, address operator) external
    withUsers() {
        vm.assume(approvalQuerier != address(0x0));
        vm.assume(operator != address(0x0));
        
        (bool success, ) = _tryCustomerIsApprovedForAll(approvalQuerier, address(0x0), operator);
        assertTrue(success, "An address could not query about whether some address is an operator of the zero address.");
    }

    /****************************
    *
    * setApprovalForAll feature tests.
    *
    ****************************/

    /// @notice Function `setApprovedForAll(address,bool)` does not throw when enabling a valid address as operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token threw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testEnablingAnyoneAsApprovedIsPossible(address approver, address approvee) external {
        vm.assume(approver != address(0x0));
        vm.assume(approvee != address(0x0));

        assertSuccess(_tryCustomerSetApprovalForAll(approver, approvee, true), "Call to setApprovedForall() on some address threw.");
    }

    /// @notice Function `setApprovedForAll(address,bool)` does not throw when disabling a valid address as operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token threw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testDisablingAnyoneAsApprovedIsPossible(address approver, address approvee) external {
        vm.assume(approver != address(0x0));
        vm.assume(approvee != address(0x0));
        
        assertSuccess(_tryCustomerSetApprovalForAll(approver, approvee, false), "Call to setApprovedForall() on some address threw.");
    }

    /// @notice Function setApprovalForAll(address,bool) can enable self as token operator for a user with tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSelfWithTokensAsOperator(uint256 tokenId) external 
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(alice, true);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertTrue(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to enable herself as operator, Alice is still not an operator for herself.");
    }

    /// @notice Function setApprovalForAll(address,bool) can disable self as token operator for a user with tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanDisableSelfWithTokensAsOperator(uint256 tokenId) external 
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(alice, false);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertFalse(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to disable herself as operator, Alice is still an operator for herself.");
    }

    /// @notice Function setApprovalForAll(address,bool) can enable self as token operator for a user without tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSelfWithoutTokensAsOperator(address user) external {
        vm.assume(user != address(0x0));
        vm.assume(cut.balanceOf(user) == 0);
        
        CallResult memory callApproval = _tryCustomerSetApprovalForAll(user, user, true);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertTrue(cut.isApprovedForAll(user, user), "Even with a successful setApprovalForAll to enable it as operator, some address is still not an operator for self.");
    }

    /// @notice Function setApprovalForAll(address,bool) can disable self as token operator for a user without tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanDisableSelfWithoutTokensAsOperator(address user) external {
        vm.assume(user != address(0x0));
        vm.assume(cut.balanceOf(user) == 0);
        
        CallResult memory callApproval = _tryCustomerSetApprovalForAll(user, user, false);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertFalse(cut.isApprovedForAll(user, user), "Even with a successful setApprovalForAll to disable it as operator, some address is still an operator for self.");
    }

    /// @notice An operator is approved for any token owned by the address which granted the operator via setApprovalForAll.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The operator of an address is not approved for a token owned by the address which granted the operator.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnOperatorIsApprovedForAnyTokenOfApprover(uint256 tokenId, address operator) external
    withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(operator != address(0x0));
        vm.assume(operator != alice); // msg.sender cannot approve herself in some contracts
        // Define operator
        CallResult memory callApproval = _tryAliceSetApprovalForAll(operator, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertEq(cut.getApproved(tokenId), operator);
    }

    // Transfer to non-ERC721Receiver

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsNotReceiverBySomeone(uint256 tokenId, address transferInitiator, bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        CallResult memory callApproval = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerSafeTransferFromWithData(transferInitiator, alice, dan, tokenId, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithoutDataToRecipientIsNotReceiverBySomeone(uint256 tokenId, address transferInitiator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        CallResult memory callApproval = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerSafeTransferFrom(transferInitiator, alice, dan, tokenId), "A `safeTransferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }

    /// @notice A `transferFrom(address,address,uint256)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenTransferFromToRecipientIsNotReceiverBySomeone(uint256 tokenId, address transferInitiator)
    external withUsers() dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(transferInitiator != address(0x0));
        vm.assume(transferInitiator != alice); // msg.sender cannot approve herself in some contracts
        CallResult memory callApproval = _tryAliceSetApprovalForAll(transferInitiator, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerTransferFrom(transferInitiator, alice, dan, tokenId), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }

    /****************************
    *
    * Metadata feature tests.
    *
    ****************************/


    /// @notice Function name() is implemented and provides a descriptive name for the NFTs in this contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function name() is not implemented or provides a non-descriptive name for the NFTs in the contract.
    /// @custom:ercx-categories name
    /// @custom:ercx-concerned-function name
    function testHasName() external {
        assertTrue(_isNotEmptyString(cut.name()));
    }

    /// @notice Function symbol() is implemented and provides an abbreviated name for the NFTs in this contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function name() is not implemented or does not provide an abbreviated name for the NFTs in the contract.
    /// @custom:ercx-categories name
    /// @custom:ercx-concerned-function name
    function testHasSymbol() external {
        assertTrue(_isNotEmptyString(cut.symbol()));
    }

    /// @notice Function tokenURI() is implemented and provides a Uniform Resource Identifier.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function tokenURI() is not implemented or does not provide a Uniform Resource Identifier.
    /// @custom:ercx-categories uri
    /// @custom:ercx-concerned-function tokenURI
    function testHasTokenURI(uint256 tokenId) external {
        vm.assume(_hasOwner(tokenId));
        assertTrue(_isNotEmptyString(cut.tokenURI(tokenId)));
    }

    /// @notice Function tokenURI() provides distrinct Uniform Resource Identifier for assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function tokenURI() does not provide a Uniform Resource Identifier.
    /// @custom:ercx-categories uri
    /// @custom:ercx-concerned-function tokenURI
    function testProvidesDistinctTokenURIs(uint256 tokenId1, uint256 tokenId2) external {
        vm.assume(_hasOwner(tokenId1));
        vm.assume(_hasOwner(tokenId2));
        vm.assume(tokenId1 != tokenId2);
        string memory uri1 = cut.tokenURI(tokenId1);
        string memory uri2 = cut.tokenURI(tokenId2);
        assertFalse(_compareStrings(uri1, uri2));
    }
}