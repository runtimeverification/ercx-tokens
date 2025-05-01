#!/usr/bin/env bash
set -euo pipefail

# Required Foundry version string
required_version="rc-1"
actual_version=$(forge --version 2>&1 | awk -F ': ' '/Version:/ {print $2}')

# Check if the installed Foundry version is the required one
if [[ "$actual_version" != *"$required_version"* ]]; then
  echo "⚠️ Foundry version mismatch: expected $required_version, got $actual_version"
  echo "🔄 Installing correct version..."
  foundryup --install "$required_version"
fi

EXPECTED="test/scripts/expected-output.json"
OUTPUT=$(mktemp)
PARSED=$(mktemp)

# Run source-code tests and save output to a temporary file
forge test --match-path 'test/local/*' --json --allow-failure > "$OUTPUT"

# Retrieve test results from the JSON output
jq 'to_entries
  | map({
      (.key): {
        tests: (
          .value.test_results
          | to_entries
          | map({
              name: .key,
              status: .value.status,
              reason: .value.reason,
              decoded_logs: .value.decoded_logs
            })
          | sort_by(.name)
        )
      }
    })
  | add' "$OUTPUT" > "$PARSED"

# Check if the output should be updated
if [[ "${1:-}" == "--update-expected-output" ]]; then
  cp "$PARSED" "$EXPECTED"
else
  diff -u "$EXPECTED" "$PARSED" || {
    echo
    echo "❌ Output differs from expected"
    rm "$OUTPUT" "$PARSED"
    exit 1
  }
fi

rm "$OUTPUT" "$PARSED"