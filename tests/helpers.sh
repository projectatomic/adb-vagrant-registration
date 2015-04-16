function setup_tests() {
  # Test results that should be printed at the end
  TEST_RESULTS=''
  FAILED=0
  SUCCEDED=0
  EXIT_CODE=0
}

function print_results() {
  if [ "$TEST_RESULTS" != "" ]; then
    printf "\n$TEST_RESULTS\n"
  fi
  printf "\n$SUCCEDED succeded, $FAILED failed.\n"
  exit $EXIT_CODE
}

function clean_up() {
  # Clean up Vagrant metadata
  rm -rf $DIR/.vagrant
}

# Test that command succeded
#
# Usage:
#
#   test_success TEST_NAME COMMAND_TO_RUN
#
# Example:
#
#   test_success "ls won't fail" "ls -all"
function test_success() {
  eval $2 >&1 >/dev/null
  if [ $? -ne 0 ]; then
    printf "F"
    FAILED=$((FAILED + 1))
    EXIT_CODE=1
    TEST_RESULTS="$TEST_RESULTS\nTest '$1' failed with command:"
    TEST_RESULTS="$TEST_RESULTS\n    $2"
  else
    SUCCEDED=$((SUCCEDED + 1))
    printf '.'
  fi
}

# Test that command failed
#
# Usage:
#
#   test_failure TEST_NAME COMMAND_TO_RUN
#
# Example:
#
#   test_failure "this should fail" "echoo"
function test_failure() {
  eval $2 >&1 >/dev/null
  if [ $? -ne 0 ]; then
    SUCCEDED=$((SUCCEDED + 1))
    printf '.'
  else
    printf "F"
    FAILED=$((FAILED + 1))
    EXIT_CODE=1
    TEST_RESULTS="$TEST_RESULTS\nTest '$1' dit not fail with command:"
    TEST_RESULTS="$TEST_RESULTS\n    $2"
  fi
}

# Test that command produced an expected output
#
# Usage:
#
#   test_output TEST_NAME COMMAND_TO_RUN EXPECTED_OUTPUT
#
# Example:
#
#   test_output "echo abc outputs abc" "echo 'abc'" "abc"
function test_output() {
  eval $2 >&1| grep "$3" >/dev/null
  if [ $? -ne 0 ]; then
    printf "F"
    FAILED=$((FAILED + 1))
    EXIT_CODE=1
    TEST_RESULTS="$TEST_RESULTS\nTest '$1' failed with command:"
    TEST_RESULTS="$TEST_RESULTS\n    $2 | grep '$3'"
  else
    SUCCEDED=$((SUCCEDED + 1))
    printf '.'
  fi
}
