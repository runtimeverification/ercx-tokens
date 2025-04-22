const core = require('@actions/core');
const exec = require('@actions/exec');
const { promises: fs } = require('fs');


// most @actions toolkit packages have async methods
async function run() {
  try {
    core.info('Running golden tests');
    const infura_api_key = core.getInput('infura_api_key');
    const etherscan_api_key = core.getInput('etherscan_api_key');
    
    const forgeConfigOut = await exec.getExecOutput(
      'forge',
      ['config'],
      {
        env : {
          FOUNDRY_PROFILE : 'default',
        }
      }
    );

    const forgeListOut = await exec.getExecOutput(
      'forge',
      ['test', '--list', '--json', '--silent'],
      {
        env : {
          FOUNDRY_PROFILE : 'default',
        }
      }
    );
    const tests = JSON.parse(forgeListOut.stdout);
    const testFiles = Object.keys(tests).filter(testFile => 
      testFile.match(/^test\/golden/)
    );

    let result = true;
    for (let testFile of testFiles) {
      // Run forge test
      const forgeTestOut = await exec.getExecOutput(
        'forge',
        [
          'test',
          '--ffi',
          '--silent',
          '--match-path', testFile,
          '--fork-url', `https://mainnet.infura.io/v3/${infura_api_key}`,
          '--fork-block-number', '17819492'
        ],
        {
          ignoreReturnCode: true,
          env : {
            FOUNDRY_PROFILE : 'default',
            ETHERSCAN_API_KEY : etherscan_api_key
          }
        }
      );
      const actual = forgeTestOut.stdout;
      // Read expected ouput from golden file
      const goldenFile = testFile + '.out';
      try {
        const expected = await fs.readFile(goldenFile, 'utf8');
        // Compare expected output to actual output
        try {
          if (!compare(actual, expected)) {
            result = false;
          }
        } catch (error) {
          core.error(`Couldn't compare expected output.`);
          core.setFailed(error.message);
        }
      } catch (e) {
        core.warning(`Couldn't find a golden file for test file: ${testFile}`);
      }
    }
    if (!result) {
      core.setFailed("One or more golden tests failed");
    }
  } catch (error) {
    core.setFailed(error.message);
  }
}

function compare(actual, expected) {
  let actualLines = actual.split("\n");
  let expectedLines = expected.split("\n");
  if (actualLines.length !== expectedLines.length) {
    core.error("The number of test cases in the expected output and actual output mismatch");
    return false;
  }
  // Remove the first and last lines from the output. These lines
  // contain metadata and not test cases
  actualLines = actualLines.slice(2, -3);
  expectedLines = expectedLines.slice(2, -3);
  // Construct a mapping from function signatures to success states
  // for each test case of actual foundry output
  const testResults = new Map();
  for (let line of actualLines) {
    const testResult = parseLine(line);
    testResults.set(testResult.signature, testResult.result);
  }
  // Go over each test case of the expected foundry ouput and check
  // if it matches the actual output.
  let result = true;
  for (let line of expectedLines) {
    const testResult = parseLine(line);
    if (testResults.get(testResult.signature).includes("PASS") !== testResult.result.includes("PASS")) {
      core.error(`The test result for ${testResult.signature} does not match the expected value.`);
      result = false;
    }
  }
  return result;
}

function parseLine(line) {
  // Strip color codes from input line
  line = line.split(/\033\[[0-9;]+m/).join('');
  let result = "";
  let signature = "";
  let brackets = 0;
  let state = "before result";
  for (let char of line) {
    if (state === "before result") {
      if (char === "[") {
        brackets++;
        state = "inside result"
      } 
    } else if (state == "inside result") {
      if (char === "[") {
        brackets++;
      } else if (char === "]") {
        brackets--;
        if (brackets === 0) {
          state = "before signature"
        }
      } else {
        result += char;
      }
    } else if (state == "before signature") {
      if (char.match(/\w/)) {
        state = "inside signature"
        signature += char;
      }
    } else if (state == "inside signature") {
      if (char.match(" ")) {
        state = "after signature";
      } else {
        signature += char;
      }
    }
  }
  return { result, signature }
}

run();
