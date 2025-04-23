#!/bin/bash
set -exuo pipefail

foundryup --install nightly-ca67d15f4abd46394b324c50e21e66f306a1162d

FOUNDRY_PROFILE=default
for TEST in test/golden/*.sol; do
    time NO_COLOR=1 forge test \
        --silent \
        --fork-url $FORK_URL \
        --fork-block-number 17819492 \
        --match-path "$TEST" \
        --allow-failure \
        --ffi > "$TEST.out"
done