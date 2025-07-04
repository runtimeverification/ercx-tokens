// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "../ERC721Abstract.sol";

/// @notice Abstract contract that consists of the security properties, including desirable properties for the sane functioning of the token and properties
/// of add-on functions commonly created and used by ERC721 developers.
abstract contract ERC721Security is ERC721Abstract {
    /**
     *
     * Glossary                                                                         *
     * -------------------------------------------------------------------------------- *
     * tokenSender   : address that sends tokens (usually in a transaction)             *
     * tokenReceiver : address that receives tokens (usually in a transaction)          *
     * tokenApprover : address that approves tokens (usually in an approval)            *
     * tokenApprovee : address that tokenApprover approves of (usually in an approval)  *
     *
     */

    /**
     *
     */
    /**
     *
     */
    /* Tests related to desirable properties. */
    /**
     *
     */
    /**
     *
     */

    /**
     *
     *
     * safeTransferFrom(address,address,uint256,bytes) desirable checks.
     *
     *
     */

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataToEOAByOwnerUpdatesBalances(
        address tokenReceiver,
        uint256 tokenId,
        bytes memory data
    ) external withUsers ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByOwnerUpdatesBalances(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataToReceiverByOwnerUpdatesBalances(uint256 tokenId, bytes memory data)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByOwnerUpdatesBalances(bob, tokenId, data);
    }

    /// @notice Internal property-test checking that upon a safeTransferFrom with data, the balance of the tokenSender and the tokenReceiver are updated correctly.
    function _propertySafeTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId, bytes memory data) internal {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceSafeTransferFromWithData(alice, to, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByReceiverOwnerToHimSelfDoesNotUpdatesBalance(
        uint256 tokenId,
        bytes memory data
    ) external withUsers dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(alice, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the EOA token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByEOAOwnerToHimSelfDoesNotUpdatesBalance(
        address owner,
        uint256 tokenId,
        bytes memory data
    ) public withUsers ensureNotATokenReceiver(owner) dealAnOwnedTokenToCustomer(owner, tokenId) {
        vm.assume(owner != address(0x0));
        _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(owner, tokenId, data);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom by the owner, the balance of the owner does not update.
    function _propertySafeTransferFromWithDataByOwnerToHimselfDoesNotUpdatesBalances(
        address owner,
        uint256 tokenId,
        bytes memory data
    ) internal {
        uint256 ownerInitialBalance = cut.balanceOf(owner);
        CallResult memory callTransfer = _tryCustomerSafeTransferFromWithData(owner, owner, owner, tokenId, data);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from the owner to self."
        );
        assertEq(
            cut.balanceOf(owner),
            ownerInitialBalance,
            "Balance of the owner has changed after sending a token to himself."
        );
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromWithDataByApprovedAddressToOwnerDoesNotUpdatesBalance(
        address approvedAddress,
        uint256 tokenId,
        bytes memory data
    ) external withUsers dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer =
            _tryCustomerSafeTransferFromWithData(approvedAddress, alice, alice, tokenId, data);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Approved address could not safeTransferFrom from Alice to Alice."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance,
            "Balance of a user has changed after the approved address sent a token to his initial owner."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not correctly updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedEOAAddressToSelfUpdatesBalances(
        address approved,
        uint256 tokenId,
        bytes memory data
    ) external withUsers ensureNotATokenReceiver(approved) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(approved != address(0x0));
        vm.assume(approved != alice); // msg.sender cannot approve herself in some contracts
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(approved, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedReceiverAddressToSelfUpdatesBalances(
        uint256 tokenId,
        bytes memory data
    ) external withUsers dealAnOwnedTokenToAlice(tokenId) {
        _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(bob, tokenId, data);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom by the owner, the balance of the owner does not update.
    function _propertySafeTransferFromWithDataByApprovedAddressToSelfUpdatesBalances(
        address approvedAddress,
        uint256 tokenId,
        bytes memory data
    ) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(approvedAddress);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer =
            _tryCustomerSafeTransferFromWithData(approvedAddress, alice, approvedAddress, tokenId, data);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: approved address could not safeTransferFrom from Alice to him."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of Alice has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(approvedAddress),
            approvedInitialBalance + 1,
            "Balance of approved address has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedAddressToEOAUpdatesBalances(
        address tokenReceiver,
        uint256 tokenId,
        bytes memory data
    ) external withUsers ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByApprovedAddressToReceiverUpdatesBalances(uint256 tokenId, bytes memory data)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenId, data);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom by the approved address, the balances of the tokenSender and the tokenReceiver are correctly updated.
    function _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFromWithData(alice, to, tokenId, data);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to Carol.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator , balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToEOAUpdatesBalances(
        address tokenReceiver,
        uint256 tokenId,
        bytes memory data
    ) external withUsers ensureNotATokenReceiver(tokenReceiver) dealAnOwnedTokenToAlice(tokenId) {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(tokenReceiver, tokenId, data);
    }

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator , balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToReceiverUpdatesBalances(uint256 tokenId, bytes memory data)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenId, data);
    }

    /// @notice Internal property-test checking that after a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator, the balances of the tokenSender and the tokenReceiver are correctly updated.
    function _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId, bytes memory data)
        internal
    {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSomeone(tokenId, data, to)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(to),
                toInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator  to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256,bytes)` (with data) by an operator, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromWithDataByOperatorToSelfUpdatesBalances(uint256 tokenId, bytes memory data)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromWithDataToSelf(tokenId, data)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(bob),
                bobInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }

    /**
     *
     *
     * safeTransferFrom(address,address,uint256) desirable checks.
     *
     *
     */

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromToEOAByOwnerUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByOwnerUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromToReceiverByOwnerUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByOwnerUpdatesBalances(bob, tokenId);
    }

    /// @notice Internal property-test checking that after a safeTransferFrom(address,address,uint256)` (without data) by the tokenOwner, the balances of the tokenReceiver and the tokenReceiver are correctly updated.
    function _propertySafeTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId) internal {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByReceiverOwnerToHimSelfDoesNotUpdatesBalance(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callTransfer = _tryAliceSafeTransferFrom(alice, alice, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from Alice to self."
        );
        assertEq(
            cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after sending a token to himself."
        );
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the EOA token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByEOAOwnerToHimSelfDoesNotUpdatesBalance(address owner, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(owner)
        dealAnOwnedTokenToCustomer(owner, tokenId)
    {
        uint256 ownerInitialBalance = cut.balanceOf(owner);
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(owner, owner, owner, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Could not perform safeTransferFrom from Alice to self."
        );
        assertEq(
            cut.balanceOf(owner), ownerInitialBalance, "Balance of a user has changed after sending a token to himself."
        );
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf
    function testSafeTransferFromByApprovedAddressToOwnerDoesNotUpdatesBalance(address approvedAddress, uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(approvedAddress, alice, alice, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Approved address could not safeTransferFrom from Alice to Alice."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance,
            "Balance of a user has changed after the approved address sent a token to his initial owner."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedEOAAddressToSelfUpdatesBalances(address approvedAddress, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(approvedAddress)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(approvedAddress);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerSafeTransferFrom(approvedAddress, alice, approvedAddress, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: approved address could not safeTransferFrom from Alice to him."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(approvedAddress),
            approvedInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedReceiverAddressToSelfUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFrom(alice, bob, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to him.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(bob),
            bobInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedAddressToEOAUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByApprovedAddressToReceiverUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenId);
    }

    /// @notice Internal property-test checking that after `safeTransferFrom(address,address,uint256,bytes)` (with data) by the approved address, the balance of the tokenSender and the tokenReceiver are updated correctly.
    function _propertySafeTransferFromByApprovedAddressToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobSafeTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not safeTransferFrom from Alice to Carol.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToEOAUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToReceiverUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenId);
    }

    function _propertySafeTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSomeone(tokenId, to)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(to),
                toInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }

    //

    /// @notice A `safeTransferFrom(address,address,uint256)` (without data) by the approved address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `safeTransferFrom(address,address,uint256)` (without data) by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function safeTransferFrom, balanceOf, approve
    function testSafeTransferFromByOperatorToSelfUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        if (_AliceSetApprovedForAllBobAndBobSafeTransfersFromToSelf(tokenId)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(bob),
                bobInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }

    /**
     *
     *
     * transferFrom(address,address,uint256) desirable checks.
     *
     *
     */

    /// @notice A `transferFrom(address,address,uint256)` to an EOA by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` to an EOA by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromToEOAByOwnerUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertyTransferFromByOwnerUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the owner correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` to a contract implementing the ERC721Receiver by the token owner, balances were not updated.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromToReceiverByOwnerUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertyTransferFromByOwnerUpdatesBalances(bob, tokenId);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the owner, the balances of the tokenSender and the tokenReceiver are correctly updated.
    function _propertyTransferFromByOwnerUpdatesBalances(address to, uint256 tokenId) internal {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by an ERC721Receiver to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the ERC721Receiver token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByReceiverOwnerToHimSelfDoesNotUpdatesBalance(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callTransfer = _tryAliceTransferFrom(alice, alice, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom from Alice to self.");
        assertEq(
            cut.balanceOf(alice), aliceInitialBalance, "Balance of a user has changed after sending a token to himself."
        );
    }

    /// @notice A `transferFrom(address,address,uint256)` by an EOA to himself does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the EOA token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByEOAOwnerToHimSelfDoesNotUpdatesBalance(address owner, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(owner)
        dealAnOwnedTokenToCustomer(owner, tokenId)
    {
        uint256 ownerInitialBalance = cut.balanceOf(owner);
        CallResult memory callTransfer = _tryCustomerTransferFrom(owner, owner, owner, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Could not perform transferFrom from Alice to self.");
        assertEq(
            cut.balanceOf(owner), ownerInitialBalance, "Balance of a user has changed after sending a token to himself."
        );
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to the contract owner does not update his balance.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the token owner to himself, balances changed.
    /// @custom:ercx-categories transfer, balance
    /// @custom:ercx-concerned-function transferFrom, balanceOf
    function testTransferFromByApprovedAddressToOwnerDoesNotUpdatesBalance(address approvedAddress, uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(approvedAddress != address(0x0));
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(approvedAddress, alice, alice, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: Approved address could not transferFrom from Alice to Alice."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance,
            "Balance of a user has changed after the approved address sent a token to his initial owner."
        );
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved EOA address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedEOAAddressToSelfUpdatesBalances(address approvedAddress, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(approvedAddress)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(approvedAddress != alice); // msg.sender cannot approve herself in some contracts
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 approvedInitialBalance = cut.balanceOf(approvedAddress);
        CallResult memory callApprove = _tryAliceApprove(approvedAddress, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve.");
        CallResult memory callTransfer = _tryCustomerTransferFrom(approvedAddress, alice, approvedAddress, tokenId);
        conditionalSkip(
            !callTransfer.success, "Inconclusive test: approved address could not transferFrom from Alice to him."
        );
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(approvedAddress),
            approvedInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved ERC721Receiver address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated correctly.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedReceiverAddressToSelfUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobTransferFrom(alice, bob, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not transferFrom from Alice to him.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(bob),
            bobInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedAddressToEOAUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some other contract implementing the ERC721Receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByApprovedAddressToReceiverUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(carol, tokenId);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the approved address, the balances of the tokenSender and tokenReceiver are correctly updated.
    function _propertyTransferFromByApprovedAddressToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        CallResult memory callApprove = _tryAliceApprove(bob, tokenId);
        conditionalSkip(!callApprove.success, "Inconclusive test: Alice could not approve Bob.");
        CallResult memory callTransfer = _tryBobTransferFrom(alice, to, tokenId);
        conditionalSkip(!callTransfer.success, "Inconclusive test: Bob could not transferFrom from Alice to Carol.");
        assertEq(
            cut.balanceOf(alice),
            aliceInitialBalance - 1,
            "Balance of a user has not been decremented after sending a token."
        );
        assertEq(
            cut.balanceOf(to),
            toInitialBalance + 1,
            "Balance of a user has not been incremented after receiving a token."
        );
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to an EOA correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToEOAUpdatesBalances(address tokenReceiver, uint256 tokenId)
        external
        withUsers
        ensureNotATokenReceiver(tokenReceiver)
        dealAnOwnedTokenToAlice(tokenId)
    {
        vm.assume(tokenReceiver != address(0x0));
        _propertyTransferFromByOperatorToSomeoneUpdatesBalances(tokenReceiver, tokenId);
    }

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to some other token receiver correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToReceiverUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        _propertyTransferFromByOperatorToSomeoneUpdatesBalances(carol, tokenId);
    }

    /// @notice Internal property-test checking that after a `transferFrom(address,address,uint256)` by the operator, the balances of the tokenSender and tokenReceiver are correctly updated.
    function _propertyTransferFromByOperatorToSomeoneUpdatesBalances(address to, uint256 tokenId) internal {
        vm.assume(to != alice);
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 toInitialBalance = cut.balanceOf(to);
        if (_AliceSetApprovedForAllBobAndBobTransfersFromToSomeone(tokenId, to)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(to),
                toInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }

    //

    /// @notice A `transferFrom(address,address,uint256)` by the approved address to self correctly updates the balances.
    /// @custom:ercx-expected pass
    /// @custom:ercx-feedback After a `transferFrom(address,address,uint256)` by the approved address, balances were not updated.
    /// @custom:ercx-categories transfer, balance, approval
    /// @custom:ercx-concerned-function transferFrom, balanceOf, approve
    function testTransferFromByOperatorToSelfUpdatesBalances(uint256 tokenId)
        external
        withUsers
        dealAnOwnedTokenToAlice(tokenId)
    {
        uint256 aliceInitialBalance = cut.balanceOf(alice);
        uint256 bobInitialBalance = cut.balanceOf(bob);
        if (_AliceSetApprovedForAllBobAndBobTransfersFromToSelf(tokenId)) {
            assertEq(
                cut.balanceOf(alice),
                aliceInitialBalance - 1,
                "Balance of a user has not been decremented after sending a token."
            );
            assertEq(
                cut.balanceOf(bob),
                bobInitialBalance + 1,
                "Balance of a user has not been incremented after receiving a token."
            );
        }
    }
}
