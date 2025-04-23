# ERCx Token Library

ERCx token library is a re-usable collection of Foundry tests for several ERC token standards. 
The following tables summarize the number of tests in every category 
(for Light and Heavy versions of the test suites), for each ERC/EIP standard:

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

**Standard:** consists of testing functions that test for properties extracted from the standard, which include properties that contain the key words, *MUST* and *SHOULD*, 
and more generally properties that can be extracted from the respective EIP specification.

**Security:** consists of the security properties, including desirable properties for the sane functioning of the token and properties 
of add-on functions commonly created and used by developers.

**Features:** consists of testing functions that test for properties that are neither desirable nor undesirable but instead implementation choices.

#### Additional information about the test suites:

- A test is skipped if its result is inconclusive as certain conditions are not met while testing the said property test. 
Some possible reasons for a test to be skipped are failure to deal tokens to dummy users before running the test and 
failure to call the required function before making the property check especially in cases where large values of inputs are used 
in the test. Note that skipped tests from non-ABI levels are still important property tests that a token should satisfy. 
Please exercise caution when interpreting the results for these tests.

- For each standard, there are two versions, "Light" and "Heavy", of the test suites which you can run. 
The "Light" version runs with fixed dummy user addresses, i.e., the set of users, `alice`, `bob` and `carol`
are fixed and used for all tests in each test suite. On the other hand, the "Heavy" version runs with fuzzed dummy user addresses, 
i.e., the set of users, `alice`, `bob` and `carol` used changes for each test.
  > **NOTE:** Currently, the repository only has the "HEAVY" version for ERC20 test suite and it only consists of 
MANDATORY checks. If not indicated, it is assumed that the "Light" version of the test suite is used. 

- For ERC4626 test suite, there are several tests with the phrase "up to `delta`-approximation" in their
test descriptions. These are the tests where calling of functions such as `deposit`, `withdraw`, etc, are 
being carried out and conversation of shares to assets, and vice-versa, will take place. As math operations 
in Solidity is done entirely using fixed-point (i.e., no decimal value), rounding errors may occur if the 
contract does not follow the required rounding rules stated in the [EIP-4626](https://eips.ethereum.org/EIPS/eip-4626) 
standard. However, in the event where the contract does not follow the required rounding rules, there is a 
global `uint256` variable, `delta`, for the test suite where the user can set to provide some leeway for 
such errors. This `delta` value represents the maximum approximation error size (an absolute value given in 
the smallest unit such as Wei) whenever equality assertion check is carried out. For example, `x - y <= delta` 
is being checked whenever there is a check for `x == y`. It is important to note that `delta` should only be 
set to a reasonable small value so that the adversarial profit of exploiting such rounding errors stays relatively 
small compared to the gas cost. The default value of `delta` is set to 0 as all tests are supposed to pass 
at this value if the contract follows the required rounding rules.

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
forge install runtimeverification/ercx-tokens
~~~

## Usage

This section assumes that you already have Foundry and ERCx library installed. There are two ways to execute the test-suite.

1. Post-deployment: Run the test suite on any ERC token for which you have the Ethereum-address.
2. Pre-deployment: Run the test suite on the Solidity source code of an ERC token.

Before running any of the test suite, you may need to do some minor tweaks to some of the test files.

### Do I need to set up anything before running the ERCx tests?

Depending on the test suite you wish to run, there might be some setting up to do before running it.

#### ERC20 test suite (Optional)

The test suite will try to deal tokens to dummy users before running the tests. 
It does so by reading and rewriting the storage slot of functions/variables such as `totalSupply()`
and `balanceOf(user)`.
For most contracts, this should not post an issue, however, there are some (e.g., deployed contracts such as USDC, stETH) 
that will cause issues while retrieving and reading these storage slots.
As a result, many of tests may fail due to errors such as `stdStorage find(StdStorage): Slot(s) not found.`.
We have set up the ERC20 test suite such as we can resolve this issue by first, assigning a top token holder, 
followed by using the account to transfer some tokens to the dummy users for testing. 

Thus, if you wish to address all the failing tests due to `stdStorage` issues, here is what you need to do:

1. Retrieve the top token holder (or some account that holds tokens) of the contract that you want to test with.
    > You can retrieve it under the "Holders" tab of the contract's [Etherscan](https://etherscan.io/) token page or by calling some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/gettoptokenholders).

2. Assign the `address` variable `topTokenHolder` in line 111 of `src/ERCAbstract.sol` with the address that you have retrieved, 
e.g., `address topTokenHolder = 0x...;`.

Now the test suite is ready to be run and the `stdStorage` issue will be resolved.

**NOTE:** The above instructions are optional as it is not needed if 
(a) you are running the test suite on a source code contract, or
(b) you did not encounter any `stdStorage` issue during your run of the test suite.


#### ERC4626 test suite (Optional)

Similar to ERC20 test suite, the ERC4626 test suite deal either assets or shares or both to dummy users 
before running the tests. As a result, it may encounter the same `stdStorage` issue when running the tests.

Thus, if you wish to address the issue like what you can do for the ERC20 test suite, here is what you can do:

1. Retrieve the `asset` address of the ERC4626 contract that you are working on.
    > You can retrieve it by calling an query on the `asset()` function through the contract's [Etherscan](https://etherscan.io/) token page 
    or some API endpoint.

2. Retrieve the top **asset** holder (or some account that holds assets) of the asset contract that you retrieved in the previous step.
    > You can retrieve it under the "Holders" tab of the asset contract's [Etherscan](https://etherscan.io/) token page or by calling some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/gettoptokenholders).

3. Assign the `address` variable `topTokenHolder` in line 111 of `src/ERCAbstract.sol` with the address that you have retrieved, 
e.g., `address topTokenHolder = 0x...;`.

Now the test suite is ready to be run and the `stdStorage` issue will be resolved.

**NOTE:** The above instructions are optional as it is not needed if 
(a) you are running the test suite on a source code contract, or
(b) you did not encounter any `stdStorage` issue during your run of the test suite.


#### ERC721 test suite (Mandatory)

As only NFTs with token IDs that have been minted with the permission of the owner/s and not destroyed 
can be transferred from one to another, we could not randomly choose a token ID and assign it to 
a dummy user. This is because the randomly chosen token ID might be banned from using.

Thus, to run the test suite regardless if it is for source code or deployed contract, 
we need to have at least 3 token IDs that have been minted and with owners to be assigned
and used in the test suite. To do so, here is what you can do:

1. (a) For testing of source code contract, in the `constructor` of your main contract,
mint at least 3 NFTs with non-zero token IDs and assign them to some valid address.
(b) For testing of deployed contract, retrieve 3 token IDs that have owners.
    > You can retrieve this information via some API endpoint such as the one provided by [Chainbase](https://docs.chainbase.com/reference/getnftcollectionitems).

2. Assign the variables `uint256 tokenIdWithOwner` and `uint256[3] tokenIdsWithOwners` 
with the token IDs that you have retrieved in the previous step. 
Example: `uint256 tokenIdWithOwner = 1;` and `uint256[3] tokenIdsWithOwners = [1, 2, 3];`

Now the test suite is ready to be run.


### I have a token address. How can I run the ERCx tests on it?

If you have the address of an ERC token you can run all tests without writing a single line of code. 
You can set these values via the `ERCx_ADDRESS` and `FORK_URL` environment-variables. 
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
> 1. You can replace the ERC standard "20" to other ERC standard that we support if you wish to run other ERC test suite for the provided address.
> 2. For ERC20 test suite, you can choose to launch the "Heavy" version of the test suite by replacing "Light" in `ERC20PostDeploymentLightTest` with `Heavy`. 
As for non-ERC20 test suites, only the "Light" versions of the test suites are available. 
Thus, you can remove the word "Light" completely, e.g., `ERC4626PostDeploymentTest`. 
> 3. You can ignore the results of `testFail_` where `_` can be either `Name`, `Symbol` or `Decimals` as they are meant for user to retrieve these metadata. If you wish to retrieve any of these metadata, say `name`, you can run the code, `forge test --ffi --fork-url  $FORK_URL --match-path test/ERC4626PostDeploymentTest.sol --match-test testFailName --json` and look at the value under the key "reason".

If you are a developer and your token is not deployed yet, you can execute the tests directly on your source code. See the following section for more details.

### How can I run the tests on my source code?

Let's assume you have a custom ERC20 implementation in a file called `src/MyERC20.sol`.
The next step is to create a corresponding test-file `test/MyERC20Test.t.sol`.
Put the following contents in the file:

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

The important thing here is that our test-contract inherits from `ERC20Test`.
That's it! You're all set up! You can now run the entire ERC20 test suite by calling the following command:

~~~sh
forge test --match-path test/MyERC20Test.t.sol --ffi
~~~

> **Note:** Similarly, you can replace the ERC standard "20" to other ERC standard that we support if you wish to run other ERC test suite on the source code of your contracts.

You can also test deployed tokens by pointing to their Ethereum mainnet address. See [I have a token address. How can I run the ERCx tests on it?](#i-have-a-token-address-how-can-i-run-the-ERCx-tests-on-it) for more detailed instructions.


## FAQ

### Why do I need an RPC-endpoint?

When testing a token from a given Ethereum address we need to download the contract from the Ethereum mainnet. For this we rely on external web-service or RPC-endpoint. You can pick whatever RPC-endpoint you want, but notice that we don't test with all endpoints. We've run the most extensive tests with the [infura RPC-endpoint](https://app.infura.io/). Notice, that you need an [API key](https://docs.infura.io/infura/networks/ethereum/how-to/secure-a-project/project-id) if you want to use infura.

Note that Foundry allows us to create a local testnet node for deploying and testing smart contracts, through the command [`anvil`](https://book.getfoundry.sh/reference/anvil/). It can also be used to fork other EVM compatible networks. This allows us to cache everything where possible and not hit the RPC endpoint every single time especially for running big test suites. To do so, open a new terminal and run `anvil --fork-url $FORK_URL`, where the `$FORK_URL` is the RPC endpoint of the forked node, e.g., `https://mainnet.infura.io/v3/$INFURA_API_KEY`. After which, on the terminal that you are running your test suite with, run `forge test` with `--fork-url http://127.0.0.1:8545` (8545 is the default port the server listens to) and any other appropriate option/s. 

### What are golden tests?

We use golden tests as regression tests. If a golden test fails you should investigate the source before you update the expected output file. If you conclude that the actual result from running the tests is correct, but the expected output file is outdated, then you can re-generate the expected output file. For example to update `USDT` you would use the following command:

~~~sh
export INFURA_API_KEY=0123456789
export FORK_URL=https://mainnet.infura.io/v3/$INFURA_API_KEY
NO_COLOR=1 forge test \
    --silent \
    --fork-url $FORK_URL \
    --match-path test/golden/USDTTest.t.sol \
    --ffi \
    > test/golden/USDTTest.t.sol.out
~~~

If you need to update all golden tests you can use the `update-golden-tests.sh`-script:

~~~sh
export INFURA_API_KEY=0123456789
export FORK_URL=https://mainnet.infura.io/v3/$INFURA_API_KEY
./update-golden-tests.sh
~~~

Note that we did not include tests from the AddOn level for all golden tests.

## Contributors

- [@jinxinglim](https://github.com/jinxinglim)
- [@yfalcone](https://github.com/yfalcone)
- [@RaoulSchaffranek](https://github.com/RaoulSchaffranek)
- [@duytai](https://github.com/duytai)
- [@Sta1400](https://github.com/Sta1400)
- [@JuanCoRo](https://github.com/JuanCoRo)