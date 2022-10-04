#!/bin/bash

set -uo pipefail

OBJ_DIR=${1:-obj_dir}
OBJ_DIR=${OBJ_DIR%/}
TEST_INSTR=${2-}

TEST_FILES=""
if [[ -z "$TEST_INSTR" ]]; then
    TEST_FILES=$(find test/riscv/** -type f \( -iname \*.asm \) 2>/dev/null)
elif [[ "$TEST_INSTR" == "all" ]]; then
    TEST_FILES=$(find test/riscv/all -type f \( -iname \*.asm \) 2>/dev/null)
else
    TEST_FILES=$(find "test/riscv/${TEST_INSTR}" -type f \( -iname \*.asm \) 2>/dev/null)
fi

if [[ $? -ne 0 ]]; then
    # No test files found
    exit 0
fi

EXIT_CODE=0

for file in $(echo "$TEST_FILES" | sort); do
    base_name=$(basename "${file}")
    dir_name=$(basename "$(dirname "$file")")
    unique_name="${dir_name}_${base_name%.*}"

    mkdir -p ./test/bin

    # Logging/Output Files
    testlog="./test/bin/${unique_name}.test.log"

    fail_file() {
        echo "${unique_name} ${dir_name} Fail # $1"
        EXIT_CODE=1
    }

    # Extract Expect Value
    expected_value=$(head -n 1 "$file" | sed -n -e 's/^\(#\|\/\/\) Expect: //p')
    if [[ -z $expected_value ]]; then
        fail_file "Did not find expected value in test case"
        continue
    fi

    export SIM_EXPECTED_VALUE="$expected_value"

    EXTRA_TAGS=$(head -n 2 "$file" | sed -n -e 's/^\(#\|\/\/\) Tags: //p')

    if [[ "$EXTRA_TAGS" == "DESTROY_BYTE_ENABLE_TEST" ]]; then
        export SIM_DESTROY_BYTE_ENABLE="1"
    else
        unset SIM_DESTROY_BYTE_ENABLE
    fi

    # Run
    if ! type timeout >/dev/null 2>&1; then
        ./"$OBJ_DIR/test_integration" "${file}.hex" >"${testlog}" 2>&1
    else
        timeout 5s ./"$OBJ_DIR/test_integration" "${file}.hex" >"${testlog}" 2>&1
    fi

    if [[ $? -ne 0 ]]; then
        fatal=$(grep -i -m 1 "Testbench expected 0x" "${testlog}" | tr -d '\n')
        if [[ $? -ne 0 ]]; then
            fatal=$(grep -m 1 "FATAL: " "${testlog}" | tr -d '\n')
        fi
        fail_file "Test bench exited with non-zero status code: ${fatal}"
        continue
    fi

    # Error
    grep -q -i -v "^ERROR:" "${testlog}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        fail_file "Test bench found 'ERROR:' within log output"
        continue
    fi

    echo "${unique_name} ${dir_name} Pass"
done

exit ${EXIT_CODE}
