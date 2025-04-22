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
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: isApprovedForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsApprovedForAllReflexiveForUsersWithoutTokens() external
    withUsers() {
        vm.assume(cut.balanceOf(bob) == 0);

        assertTrue(_propertyIsOperatorForSelf(alice, bob));
    }

    /// @notice Users without token are not operators for themselves. Note: the zero address is not considered.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token has oneself as operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: isApprovedForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsNotApprovedForAllReflexiveForUsersWithoutTokens() external
    withUsers() {
        vm.assume(cut.balanceOf(bob) == 0);

        assertFalse(_propertyIsOperatorForSelf(alice, bob));
    }

    /// @notice Users with tokens are operators for themselves.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token does not have oneself as operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: isApprovedForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsApprovedForAllReflexiveForUsersWithTokens() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertTrue(_propertyIsOperatorForSelf(bob, alice));
    }

    /// @notice Users with tokens are not operators for themselves.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A user without token has oneself as operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: isApprovedForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function isApprovedForall
    function testIsNotApprovedForAllReflexiveForUsersWithTokens() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        assertFalse(_propertyIsOperatorForSelf(bob, alice));
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
    function testZeroAddressCanQueryWhetherAnyoneIsOperatorOfAnyone() external
    withUsers() {
        (bool success, ) = _tryCustomerIsApprovedForAll(address(0x0), alice, bob);
        assertTrue(success, "It was not possible for the zero address to query whether Alice is an operator for Bob.");
    }

    /// @notice Any address can query about whether the zero address is an operator of some other address.
    /// @notice This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An address could not query whether the zero address is an operator of some other address.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnyoneCanQueryWhetherZeroAddressIsOperatorOfAnyone() external
    withUsers() {
        (bool success, ) = _tryCustomerIsApprovedForAll(alice, bob, address(0x0));
        assertTrue(success, "An address could not query whether the zero address is an operator of some other address.");
    }

    /// @notice Any address can query about whether any address is an operator of the zero address.
    /// @notice This test excludes the zero address.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback An address could not query about whether some address is an operator of the zero address.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnyoneCanQueryWhetherAnyoneIsOperatorOfZeroAddress() external
    withUsers() {
        (bool success, ) = _tryCustomerIsApprovedForAll(alice, address(0x0), bob);
        assertTrue(success, "An address could not query about whether some address is an operator of the zero address.");
    }

    /****************************
    *
    * setApprovalForAll feature tests.
    *
    ****************************/

    /// @notice Function `setApprovedForAll(address,bool)` does not throw when enabling a valid address as operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token did throw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testEnablingAnyoneAsApprovedIsPossible() external {
        assertSuccess(_tryCustomerSetApprovalForAll(alice, bob, true), "Call to setApprovedForall() on some address threw.");
    }

    /// @notice Function `setApprovedForAll(address,bool)` does not throw when disabling a valid address as operator.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A call to `getApproved()` on some token did throw.
    /// @custom:ercx-categories getApproved
    /// @custom:ercx-concerned-function getApproved
    function testDisablingAnyoneAsApprovedIsPossible() external {        
        assertSuccess(_tryCustomerSetApprovalForAll(alice, bob, false), "Call to setApprovedForall() on some address threw.");
    }

    /// @notice Function setApprovalForAll(address,bool) can enable self as token operator for a user with tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSelfWithTokensAsOperator() external 
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(alice, true);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertTrue(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to enable herself as operator, Alice is still not an operator for herself.");
    }

    /// @notice Function setApprovalForAll(address,bool) can disable self as token operator for a user with tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanDisableSelfWithTokensAsOperator() external 
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(alice, false);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertFalse(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to disable herself as operator, Alice is still an operator for herself.");
    }

    /// @notice Function setApprovalForAll(address,bool) can enable self as token operator for a user without tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanEnableSelfWithoutTokensAsOperator() external {
        vm.assume(cut.balanceOf(alice) == 0);
        
        CallResult memory callApproval = _tryCustomerSetApprovalForAll(alice, alice, true);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertTrue(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to enable it as operator, some address is still not an operator for self.");
    }

    /// @notice Function setApprovalForAll(address,bool) can disable self as token operator for a user without tokens.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback It was not possible to define oneself as operator of one's assets.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testCanDisableSelfWithoutTokensAsOperator() external {
        vm.assume(cut.balanceOf(alice) == 0);
        
        CallResult memory callApproval = _tryCustomerSetApprovalForAll(alice, alice, false);
        assertTrue(callApproval.success, "Calling setApprovalForAll reverted.");
        assertFalse(cut.isApprovedForAll(alice, alice), "Even with a successful setApprovalForAll to disable it as operator, some address is still an operator for self.");
    }

    /// @notice An operator is approved for any token owned by the address which granted the operator via setApprovalForAll.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback The operator of an address is not approved for a token owned by the address which granted the operator.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories approval
    /// @custom:ercx-concerned-function setApprovalForAll
    function testAnOperatorIsApprovedForAnyTokenOfApprover() external
    withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {       
        // Define operator
        CallResult memory callApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertEq(cut.getApproved(tokenIdWithOwner), bob);
    }

    // Transfer to non-ERC721Receiver

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithDataToRecipientIsNotReceiverBySomeone(bytes memory data)
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerSafeTransferFromWithData(bob, alice, dan, tokenIdWithOwner, data), "A `safeTransferFrom(address,address,uint256,bytes)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `safeTransferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function safeTransferFrom
    function testRevertsWhenSafeTransferFromWithoutDataToRecipientIsNotReceiverBySomeone()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerSafeTransferFrom(bob, alice, dan, tokenIdWithOwner), "A `safeTransferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }

    /// @notice A `transferFrom(address,address,uint256)` by someone throws if the recipient is not a TokenReceiver.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback A `transferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver.
    /// @custom:ercx-inconclusive The test is skipped as there is an issue when calling the following functions: setApprovalForAll.
    /// @custom:ercx-categories transfer
    /// @custom:ercx-concerned-function transferFrom
    function testRevertsWhenTransferFromToRecipientIsNotReceiverBySomeone()
    external withUsers() dealAnOwnedTokenToAlice(tokenIdWithOwner) {
        CallResult memory callApproval = _tryAliceSetApprovalForAll(bob, true);
        conditionalSkip(!callApproval.success, "Inconclusive test: Alice could not define an operator.");
        assertFail(_tryCustomerTransferFrom(bob, alice, dan, tokenIdWithOwner), "A `transferFrom(address,address,uint256)` could be initiated by the token owner to a non-TokenReceiver."); // dan is not TokenReceiver
    }
    

    /****************************
    *
    * Metadata feature tests.
    *
    ****************************/


    /// @notice Function name() is implemented and provides a descriptive name for the NFTs in this contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function name() is not implemented or provides a non-descriptive name for the NFTs in the contract.
    /// @custom:ercx-categories metadata
    /// @custom:ercx-concerned-function name
    function testHasName() external {
        assertTrue(_isNotEmptyString(cut.name()));
    }

    /// @notice Function symbol() is implemented and provides an abbreviated name for the NFTs in this contract.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function symbol() is not implemented or does not provide an abbreviated name for the NFTs in the contract.
    /// @custom:ercx-categories metadata
    /// @custom:ercx-concerned-function symbol
    function testHasSymbol() external {
        assertTrue(_isNotEmptyString(cut.symbol()));
    }

    /// @notice Function tokenURI() is implemented and provides a Uniform Resource Identifier.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function tokenURI() is not implemented or does not provide a Uniform Resource Identifier.
    /// @custom:ercx-categories uri
    /// @custom:ercx-concerned-function tokenURI
    function testHasTokenURI() external {
        assertTrue(_isNotEmptyString(cut.tokenURI(tokenIdWithOwner)));
    }

    /// @notice Function tokenURI() provides distrinct Uniform Resource Identifier for assets.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback Function tokenURI() does not provide a Uniform Resource Identifier.
    /// @custom:ercx-categories uri
    /// @custom:ercx-concerned-function tokenURI
    function testProvidesDistinctTokenURIs() external {
        string memory uri1 = cut.tokenURI(tokenIdsWithOwners[0]);
        string memory uri2 = cut.tokenURI(tokenIdsWithOwners[1]);
        assertFalse(_compareStrings(uri1, uri2));
    }

}