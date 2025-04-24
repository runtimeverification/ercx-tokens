# ERCx Token Test Library

ERCx library is a reusable collection of Foundry tests for several ERC token standards. 
The following tables summarize the number of tests in every category (for Light and Heavy versions of the test suites), for each ERC/EIP standard:

#### Light 

| **ERC/EIP standard** | Standard | Security | Features | **Total** |
| - | - | - | - | - |
| **20** | 25 | 90 | 14 | **129** |
| **721** | 141 | 38 | 21 | **200** |
| **1155** | 37 | 14 | 10 | **61** |
| **4626** | 40 | 44 | 32 | **116** |

#### Heavy 

| **ERC/EIP standard** | Standard | Security | Features | **Total** | Remark |
| - | - | - | - | - | - |
| **20** | 21 | - | - | **21** | Full Heavy version for Standard only |
| **721** | 143 | 36 | 21 | **200** | Semi-Heavy version as fixed dummy user addresses are still used |
| **1155** | - | - | - | **-** |  |
| **4626** | 41 | 44 | 106 | **187** | Light version + more tests on Features level |

#### Brief descriptions of each test set are as follows: 

**Standard:** contains tests that check properties extracted from the standard, which include properties that contain the key words *MUST* and *SHOULD* and, more generally, properties that can be extracted from the respective EIP specification.

**Security:** contains security properties, including desirable properties for the sane functioning of the token and properties of add-on functions commonly created and used by developers.

**Features:** contains tests that check properties which reflect implementation choices, rather than correctness or incorrectness.

#### Additional information about the test suites:

- A test is skipped if its result is inconclusive as certain conditions are not met while testing the said property test. 
Some reasons for a test to be skipped include to setup issues, such as not failure to deal tokens to dummy users beforehand, or failing to invoke prerequisite functions before checking a property — particularly when large input values are involved.
Note that skipped tests from non-ABI levels are still important property tests that a token should satisfy.  Please exercise caution when interpreting the results for these tests.

- For each standard, there are two versions, "Light" and "Heavy", of the test suites which you can run. 
The "Light" version runs with fixed dummy user addresses, i.e., the set of users, `alice`, `bob`, and `carol`, is fixed and used for all tests in each test suite. On the other hand, the "Heavy" version involves fuzzed user addresses, i.e., the addresses of users `alice`, `bob`, and `carol` change.
  > **NOTE:** Currently, the repository only has the "HEAVY" version for the ERC20 test suite, and it only contains MANDATORY checks. If not indicated, it is assumed that the "Light" version of the test suite is used. 

- The ERC4626 test suite contains several tests that use the phrase "up to `delta`-approximation" in their descriptions. These tests involve calling functions such as `deposit`, `withdraw`, etc., where conversion of shares to assets, and vice-versa, take place.
As all math operations in Solidity use integer arithmetic, rounding errors may occur and cause vulnerabilities if the contract does not follow the rounding rules outlined in [EIP-4626](https://eips.ethereum.org/EIPS/eip-4626).
In the test suite, we use a global `uint256` variable `delta` in the test that for the user to define a desired leeway for such rounding errors.
The value of `delta` represents the maximum approximation error size (an absolute value given in the smallest unit such as Wei) whenever the assertion check is performed.
For example, `x - y <= delta` is being checked whenever there is a check for `x == y`. It is important to note that `delta` should only be set to a reasonably small value so that the adversarial profit of exploiting such rounding errors stays relatively small compared to the gas cost. The default value of `delta` is set to 0 as all tests are supposed to pass demonstrating that no rounding issues occur if the contract follows the required rounding rules.

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
    * [Do I need to set up anything before running the ERCx tests?](#do-i-need-to-set-up-anything-before-running-the-ERCx-tests)
    * [I have a token-address. How can I run the ERCx tests on it?](#i-have-a-token-address-how-can-i-run-the-ERCx-tests-on-it)
    * [How can I run the ERCx tests on my source code?](#how-can-i-run-the-tests-on-my-source-code)
* [FAQ](#faq)
    * [Why do I need an RPC-endpoint?](#why-do-i-need-an-rpc-endpoint)
    * [What are golden tests?](#what-are-golden-tests)

## Installation

The ERCx token library requires [Foundry](https://book.getfoundry.sh/getting-started/installation).
If you have Foundry installed, you can install the library by running the following command:

~~~sh
forge install runtimeverification/ercx-tests
~~~

## Usage

This section assumes that you already have Foundry and ERCx library installed. There are two ways to execute the test suite.

1. Post-deployment: Run the test suite on any ERC token for which you have the deployment address.
2. Pre-deployment: Run the test suite on the Solidity source code of an ERC token.

### Do I need to set up anything before running the ERCx tests?

Depending on the test suite you wish to run, there might be some setting up to do before running it, as described below.

#### ERC20 test suite (Optional)

The test suite will try to deal tokens to dummy users before running the tests. 
It does so by reading and rewriting the storage slot of functions/variables such as `totalSupply()`
and `balanceOf(user)`.
For most contracts, this should not pose an issue, however, there are some (e.g., deployed contracts such as USDC, stETH) 
that will cause issues while retrieving and reading these storage slots.
As a result, some of the tests may fail due to errors such as `stdStorage find(StdStorage): Slot(s) not found.`.
We have set up the ERC20 test suite such that we can resolve this issue by, first, assigning a top token holder, 
followed by using this account to transfer some tokens to the dummy users for testing. 

Thus, if you wish to address all failures caused by the to `stdStorage` issue, here is what you need to do:

1. Retrieve the top token holder (or some account that holds tokens) of the contract that you want to test.
    > You can retrieve it under the "Holders" tab of the contract's [Etherscan](https://etherscan.io/) token page or by calling some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/gettoptokenholders).

2. Assign the `address` variable `topTokenHolder` in line 111 of `src/ERCAbstract.sol` to the address that you have retrieved, 
e.g., `address topTokenHolder = 0x...;`.

Now the test suite is ready to be run and the `stdStorage` issue will be resolved.

**NOTE:** The above instructions are optional as it is not needed if 
(a) you are running the test suite on the source code of the contract, or
(b) you did not encounter any `stdStorage` issue during your run of the test suite.

#### ERC4626 test suite (Optional)

Similar to the ERC20 test suite, the ERC4626 test suite deals assets, shares, or both to dummy users before running the tests.
As a result, you may encounter the same `stdStorage` issue when running the ERC4626 test suite.

Thus, you can address this issue similarly to the ERC20 test suite. Here is what you can do:

1. Retrieve the `asset` address of the ERC4626 contract that you are working with.
    > You can retrieve it by calling an query on the `asset()` function through the contract's [Etherscan](https://etherscan.io/) token page 
    or some API endpoint.

2. Retrieve the top **asset** holder (or some account that holds assets) of the asset contract that you retrieved in the previous step.
    > You can retrieve it under the "Holders" tab of the asset contract's [Etherscan](https://etherscan.io/) token page or by calling some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/gettoptokenholders).

3. Assign the `address` variable `topTokenHolder` in line 111 of `src/ERCAbstract.sol` to the address that you have retrieved, 
e.g., `address topTokenHolder = 0x...;`.

Now the test suite is ready to be run and the `stdStorage` issue will be resolved.

**NOTE:** The above instructions are optional as not needed if 
(a) you are running the test suite on the source code of the contract, or
(b) you did not encounter any `stdStorage` issues during your run of the test suite.


#### ERC721 test suite (Mandatory)

Since only NFTs with token IDs that have been properly minted (with the owner's permission) and not burned can be transferred, we cannot arbitrarily assign a random token ID to a dummy user — it might correspond to a non-existent, burned, or restricted token.
Thus, to run the test suite against either token source code or deployed contract, we need to have at least 3 token IDs that have been minted and with owners to be assigned and used in the test suite. To do so, here is what you can do:

1. (a) For testing source code, in the `constructor` of your main contract, mint at least 3 NFTs with non-zero token IDs and assign them to some valid address.
(b) For testing of deployed contract, retrieve 3 token IDs that have owners.
    > You can retrieve this information via some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/getnftcollectionitems).

2. Assign variables `uint256 tokenIdWithOwner` and `uint256[3] tokenIdsWithOwners` to the token IDs that you have retrieved in the previous step. 
Example: `uint256 tokenIdWithOwner = 1;` and `uint256[3] tokenIdsWithOwners = [1, 2, 3];`

Now the test suite is ready to be run.


### I have a token address. How can I run the ERCx tests on it?

If you have the address of an ERC token, you can run all tests without writing a single line of code using the fork testing functionality.
To facilitate that, you can set the token address and fork URL via the `ERCx_ADDRESS` and `FORK_URL` environment variables. 
The following shows an example of how you can run all tests from the "Light" version of the ERC20 test suite 
on the ERC20 token, [Dai Stablecoin (DAI)](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f):

~~~sh
export INFURA_API_KEY=0123456789
export FORK_URL=https://mainnet.infura.io/v3/$INFURA_API_KEY
export DAI=0x6b175474e89094c44da98b954eedeac495271d0f
export ERCx_ADDRESS=$DAI
forge test \
    --ffi \
    --fork-url  $FORK_URL\
    --match-path test/ERC20PostDeploymentLightTest.sol
~~~

> **Note:** 
> 1. If you wish to run other ERC test suite for the provided address, you can replace the ERC standard "20" with another ERC standard that we support.
> 2. For the ERC20 test suite, you can choose to launch the "Heavy" version of the test suite by replacing "Light" in `ERC20PostDeploymentLightTest` with `Heavy`. 
As for non-ERC20 test suites, only the "Light" versions of these test suites are available. 
Thus, you can remove the word "Light" completely, e.g., `ERC4626PostDeploymentTest`. 
> 3. You can ignore the results of `testFail_` where `_` can be either `Name`, `Symbol` or `Decimals` as they are meant for the user to retrieve these metadata. If you wish to retrieve any of these metadata, say `name`, you can run the tests via `forge test --ffi --fork-url  $FORK_URL --match-path test/ERC4626PostDeploymentTest.sol --match-test testFailName --json` and look at the value under the key "reason".

If you are a developer and your token is not deployed yet, you can execute the tests directly on your source code. See the following section for more details.

### How can I run the tests on my source code?

Let's assume you have a custom ERC20 implementation in a file called `src/MyERC20.sol`.
To run our tests on your contarct, you should create a corresponding test file `test/MyERC20Test.t.sol` with the following content:
~~~Solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "ercx/ERC20/Light/ERC20Test.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Test is ERC20Test {
    function setUp() override public {
        MyERC20 token = new MyERC20("MyERC20", "MyERC20");
        ERC20Test.init(address(token));
    }
}
~~~

The key thing here is for test contract to inherit from `ERC20Test`.
And that's it! You're all set up! You can now run the entire ERC20 test suite by calling the following command:

~~~sh
forge test --match-path test/MyERC20Test.t.sol --ffi
~~~

> **Note:** Similarly, you can replace the ERC standard "20" to other ERC standard that we support if you wish to run other ERC test suite on the source code of your contracts.

You can also test deployed tokens by pointing to their Ethereum mainnet address. See [I have a token address. How can I run the ERCx tests on it?](#i-have-a-token-address-how-can-i-run-the-ERCx-tests-on-it) for more detailed instructions.


## FAQ

### Why do I need an RPC-endpoint?

When testing a token from a given Ethereum address, we need to fetch the contract from the Ethereum mainnet, which requires using an external web service or an RPC endpoint, such as [Infura](https://app.infura.io/). Notice that you usually need an API to interact with the RPC endpoint, which is usually provided by the service provider.

Note that Foundry also allows us to create a local testnet node for deploying and testing smart contracts, through the [`anvil`](https://book.getfoundry.sh/reference/anvil/) command. It can also be used to fork other EVM compatible networks. This feature allows us to cache the data where possible and minimize the interaction with the RPC endpoint, especially for running big test suites. To do so, you should open a new terminal window and run `anvil --fork-url $FORK_URL`, where the `$FORK_URL` is the RPC endpoint of the forked node, e.g., `https://mainnet.infura.io/v3/$INFURA_API_KEY`. After this, run `forge test` with `--fork-url http://127.0.0.1:8545` (8545 is the default port the server listens to) and any other appropriate options, in the terminal that you are running your test suite in. 

### What are golden tests?

We use golden tests as regression tests using the script available in [test/scripts/run-tests.sh](test/scripts/run-tests.sh). The script executes the source-code tests available in the [test/local](test/local) folder and compare the result with the [expected output](test/scripts/expected-output.json).

If a test run fails, you should investigate the root cause before you update the expected output file. If you conclude that the actual result of running the tests is correct, but the expected output file is outdated, then you can re-generate the expected output file by running the following command: `./test/scripts/run-tests.sh --update-expected-output`. This will update the expected output file with the latest results of running the tests.

Note that we did not include tests from the AddOn level for all golden tests.

Additionally, you can see the examples of tests analyzing deployed contracts the source code of which is not available locally in the [test/remote](test/remote) folder. 

## Contributors

- [@jinxinglim](https://github.com/jinxinglim)
- [@yfalcone](https://github.com/yfalcone)
- [@RaoulSchaffranek](https://github.com/RaoulSchaffranek)
- [@duytai](https://github.com/duytai)
- [@Sta1400](https://github.com/Sta1400)
- [@JuanCoRo](https://github.com/JuanCoRo)