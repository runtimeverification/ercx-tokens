#!/bin/bash

# Tested tokens and the expected results

tokens=(
    "ERC20Mock"
    "ERC4626Mock"
    "USDC"
    "USDT"
    "XMPL"
    "ZeroAddress"
)

expected_results=(
    "93 pass / 15 failed / 108 total"
    "135 pass / 59 failed / 194 total"
    "94 pass / 14 failed / 108 total"
    "74 pass / 34 failed / 108 total"
    "134 pass / 60 failed / 194 total"
    "6 pass / 102 failed / 108 total"
)

# Ensure both arrays have the same length

if [ ${#tokens[@]} -ne ${#expected_results[@]} ]; then
    echo "Arrays of tokens and expected results have different lengths. Ensure they are of the same length before proceeding."
    exit 1
fi

# Updating Foundry. The output is silenced.
foundryup --install nightly-ca67d15f4abd46394b324c50e21e66f306a1162d > /dev/null

# Constants
FINAL_RESULT_FILE="results.txt"

FOUNDRY_PROFILE=default
for ((i=0; i<${#tokens[@]}; i++)); do
    # Test files are suffixed with Test
    TEST_FILE="${tokens[i]}Test"
    TEST="test/golden/${TEST_FILE}.t.sol"
    TMP_FILE=$TEST.tmp.out
    test_command="time NO_COLOR=1 forge test \
            --silent \
            --fork-url $FORK_URL \
            --fork-block-number 17819492 \
            --match-path "$TEST" \
            --allow-failure \
            --ffi"
    echo $test_command
    eval $test_command > $TMP_FILE
    RUNNING=$(grep -E '^Running' $TMP_FILE)
    RESULT=$(grep -E '^Test result:' $TMP_FILE)
    echo $RUNNING
    echo $RESULT
    echo $RUNNING >> $FINAL_RESULT_FILE
    echo $RESULT >> $FINAL_RESULT_FILE
    echo "Expected ${expected_results[i]}."
    echo "Expected ${expected_results[i]}." >> $FINAL_RESULT_FILE
    echo "========================================="
    echo "=========================================" >> $FINAL_RESULT_FILE
    rm $TMP_FILE
done