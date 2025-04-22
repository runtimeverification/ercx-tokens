// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";

/// @notice Abstract contract that defines internal functions that are used in ERC20 test suite
abstract contract ERCAbstract is Test {

    uint256 MAX_UINT96  = type(uint96).max;
    uint256 MAX_UINT256 = type(uint256).max; 
    uint256 lowerBoundPercentage = 80; // lower bound percentage for dealing tokens

    /******************************************
    *
    * Declaration of state variables and events
    *
    *******************************************/

    // Some dummy users, Alice, Bob and Carol
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");


    // contractOwner is the address of this ERC20Abstract contract, 
    // which will be address that deploys "cut" during testing
    address contractOwner = address(this);

    // List of accounts which consists of the three dummy users
    address[] internal accountsNoOwner = [alice, bob, carol];
    // List of accounts which consists of contractOwner and the three dummy users
    address[] internal accounts = [contractOwner, alice, bob, carol];

    
    /******************************************
    *
    * Common types
    *
    *******************************************/

    enum OptionalReturn { RETURN_ABSENT, RETURN_FALSE, RETURN_TRUE }

    struct CallResult {
        bool success;
        OptionalReturn optionalReturn;
    }


    /******************************************
    *
    * Internal modifiers
    *
    *******************************************/

    modifier isNotZeroAddress(address _address) {
        vm.assume(_address != address(0x0));
        _;
    }

    modifier unique3Addresses(address address1, address address2, address address3) {
        vm.assume(address1 != address2);
        vm.assume(address2 != address3);
        vm.assume(address1 != address3);
        _;
    }

    modifier unique2Addresses(address address1, address address2) {
        vm.assume(address1 != address2);
        _;
    }

    modifier unique2NonZeroAddresses(address address1, address address2) {
        vm.assume(address1 != address(0x0));
        vm.assume(address2 != address(0x0));
        vm.assume(address1 != address2);
        _;
    }


    /******************************************
    *
    * Internal helper function
    *
    *******************************************/

    /// @notice Deal `amount` tokens to `tokenReceiver`
    /// @dev The default implementation uses the `deal` cheat code. This may not work in all cases. 
    /// Developers are encouraged to override this function with the proper way to mint tokens of the subject contract.    
    function _dealERC20Token(address token, address tokenReceiver, uint256 amount) 
    internal virtual returns (bool success, string memory reason) {
        try this.externalDeal(token, tokenReceiver, amount, true) {
            if (_tryERC20TokenBalanceOfUser(token, tokenReceiver) == amount) {
                return (true, "");
            }
            else {
                (bool transferSuccess, string memory failReason) = _tryTopERC20TokenHolderTransferToReceiver(token, tokenReceiver, amount);
                return (transferSuccess, failReason);
            }
        } catch {
            (bool transferSuccess, string memory failReason) = _tryTopERC20TokenHolderTransferToReceiver(token, tokenReceiver, amount);
            return (transferSuccess, failReason);            
        }
    }

    function externalDeal(address token, address to, uint256 give, bool adjust) external {
        deal(token, to, give, adjust);
    }

    function _tryTopERC20TokenHolderTransferToReceiver(address token, address tokenReceiver, uint256 amount) 
    internal returns (bool, string memory) {
        address topTokenHolder;
        
        // As some tokens take fees during `transfer` call, we will give a lower bound of 80% of the intended amount.
        // i.e., `cut.balanceOf(tokenReceiver)` must be at least lowerBoundPercentage% of the intended `amount` after the top token holder 
        // made the `transfer` call to `tokenReceiver`.
        // Note: We need to check if `amount * lowerBoundPercentage / 100 > 0`. 
        // But before we do the multiplication `amount * lowerBoundPercentage`, we need to make sure that this amount does not overflow.
        vm.assume(amount < MAX_UINT256 / lowerBoundPercentage);
        uint256 lowerBoundedAmount = amount * lowerBoundPercentage / 100;
        if (topTokenHolder != address(0x0)) {
            uint256 topTokenHolderBalance = _tryERC20TokenBalanceOfUser(token, topTokenHolder);
            if (topTokenHolderBalance == 0) {
                return (false, "Top token holder does not have any token in his/her balance.");
            }
            // Need to make sure that the amount to be transferred must be <= balanceOf(topTokenHolder) 
            vm.assume(amount <= topTokenHolderBalance);
            _tryERC20TokenSenderTransferReceiver(token, topTokenHolder, tokenReceiver, amount);
            if (_tryERC20TokenBalanceOfUser(token, tokenReceiver) >= lowerBoundedAmount) {
                return (true, "");
            }
            else {
                return (false, "Top token holder failed to deal at least 80% of the intended amount of tokens to dummy users.");
            }
        }
        else {
            return (false, "Failed to retrieve top token holder.");
        }        
    }

    function _tryERC20TokenBalanceOfUser(address token, address user)
    internal returns (uint256) {
        bytes memory data = abi.encodeWithSignature("balanceOf(address)", user);
        (bool success, bytes memory returnData) = token.call(data);
        uint256 returnValue;
        if (success && returnData.length > 0) {
            returnValue = abi.decode(returnData, (uint256));
        }
        return returnValue;
    }

    function _tryERC20TokenSenderTransferReceiver(address token, address sender, address receiver, uint256 amount)
    internal returns (bool) {
        vm.startPrank(sender);
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", receiver, amount);
        (bool success, ) = token.call(data);
        vm.stopPrank();
        return success;
    }

    function _callOptionalReturn(address called_address, bytes memory data) 
    internal returns (CallResult memory) {
        (bool success, bytes memory returndata) = called_address.call(data);
        if (success && returndata.length > 0) {
            bool returnValue = abi.decode(returndata, (bool));
            OptionalReturn optionalReturn = returnValue
                ? OptionalReturn.RETURN_TRUE
                : OptionalReturn.RETURN_FALSE;
            return CallResult(success, optionalReturn);
        }
        return CallResult(success, OptionalReturn.RETURN_ABSENT);
    }

    function assertSuccess(CallResult memory result) 
    internal {
        assertTrue(result.success && result.optionalReturn != OptionalReturn.RETURN_FALSE);
    }

    function assertSuccess(CallResult memory result, string memory err) 
    internal {
        assertTrue(result.success && result.optionalReturn != OptionalReturn.RETURN_FALSE, err);
    }

    function assertFail(CallResult memory result) 
    internal {
        assertFalse(result.success && result.optionalReturn != OptionalReturn.RETURN_FALSE);
    }

    function assertFail(CallResult memory result, string memory err)
    internal {
        assertFalse(result.success && result.optionalReturn != OptionalReturn.RETURN_FALSE, err);
    }

    function selectorOf(string memory _func) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    /***********************************************************************************
    * Utility functions
    ***********************************************************************************/

    function _compareStrings(string memory a, string memory b) internal pure returns(bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function _concatenate(string memory a, string memory b) internal pure returns (string memory) {
        bytes memory bytesA = bytes(a);
        bytes memory bytesB = bytes(b);
        bytes memory result = abi.encodePacked(bytesA, bytesB);
        return string(result);
    }

    function _isNotEmptyString(string memory _string) internal pure returns (bool) {
        return !_compareStrings(_string, "");
    }

    function conditionalSkip(bool condition, string memory message) internal {
        if (condition) {
            emit log(message);
            vm.skip(true);
        }
    } 

}
