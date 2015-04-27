# Set up test environment
function setup_tests() {
  check_credentials
  install_dependencies

  # Test results that should be printed at the end
  TEST_RESULTS=''
  FAILED=0
  SUCCEDED=0
  EXIT_CODE=0
}

# Print test results
function print_results() {
  if [ "$TEST_RESULTS" != "" ]; then
    printf "\n$TEST_RESULTS\n"
  fi
  printf "\n$SUCCEDED succeded, $FAILED failed.\n"
  exit $EXIT_CODE
}

# Clean up before each test
function clean_up() {
  # Clean up Vagrant metadata
  rm -rf $DIR/.vagrant
}

# Check that we have credentials to run the test suite
function check_credentials() {
  if [ "$VAGRANT_REGISTRATION_USERNAME" = "" ] || [ "$VAGRANT_REGISTRATION_PASSWORD" = "" ]; then
    echo "VAGRANT_REGISTRATION_USERNAME and VAGRANT_REGISTRATION_PASSWORD needs to be provided."
    exit 1
  fi
}

# Install vagrant and vagrant-registration
function install_dependencies() {
  # Install Vagrant if it's not present
  PLUGIN_INSTALLED=$(vagrant --help)
  if [ $? -ne 0 ]; then
    sudo yum install vagrant-libvirt -y
  fi

  # Uninstall vagrant-registration if installed
  # TODO: Uninstall RPM package if needed
  PLUGIN_INSTALLED=$(vagrant plugin list | grep vagrant-registration)
  if [ -z "$PLUGIN_INSTALLED" ]; then
    vagrant plugin uninstall vagrant-registration
  fi

  # Install vagrant-registration from current sources
  rm -rf pkg
  rake build
  vagrant plugin install pkg/vagrant-registration*.gem
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
