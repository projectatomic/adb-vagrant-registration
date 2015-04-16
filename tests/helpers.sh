# Test results that should be printed at the end
TEST_RESULTS=''

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
  OUTPUT=$($2 >&1) >/dev/null
  if [ $? -ne 0 ]; then
    printf "F"
    TEST_RESULTS="$TEST_RESULTS\nTest '$1' failed with command:"
    TEST_RESULTS="$TEST_RESULTS\n    $2"
  else
    printf '.'
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
  OUTPUT=$($2 >&1) >/dev/null
  TEST=$($2 | grep $3)
  if [ $? -ne 0 ]; then
    printf "F"
    TEST_RESULTS="$TEST_RESULTS\nTest '$1' failed with command:"
    TEST_RESULTS="$TEST_RESULTS\n    $2 | grep $2"
  else
    printf '.'
  fi
}
