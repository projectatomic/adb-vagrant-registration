# Changelog

## 1.2.3

- Issue #90 Use locale based messaging
- Issue #65 Adding cucumber tests for proxy settings
- Issue #65 Adding proxy options to rhn_register and subscription_manager
- Adding minitest as unit test framework and setting up basic test harness for Vagrant plugins
- Issue #65 Removing obsolete bash tests

## 1.2.2

- Introducing Cucumber based acceptance tests.
- Fix: Handling of vagrant-registration action hooks depending on provider used.

## 1.2.1

- Fix regression: Use sudo when asking on registration managers being present

## 1.2.0

- Fix: `vagrant destroy` not triggering subscription deactivation and removal, issue #57
- Fix: Allow auto-attach and force options to be configured
- Fix: Remove unnecessary shebang from python script
- Support for attaching to specified subscription pool(s), issue #36
- Fix: rhn_register upload certificate fails, issue #60

## 1.1.0

- Print warning if specifically selected manager is not available
- Support running alongside vagrant-vbguest, issue #40
- Support rhn_register manager
- Fix: Handle various types of configuration option values, issue #48
- Fix: Hide password on registration failure, issue #47

## 1.0.1

- Fix: Set repo_ca_cert option in /etc/rhsm/rhsm.conf after uploading a certificate

## 1.0.0

- Support providing a CA certificate via `config.registration.ca_cert` option
- Issue warnings on unsupported configuration options
- Do not ship tests

## 0.0.19

- Remove extra files from installation

## 0.0.18

- Support `config.registration.unregister_on_halt` option
