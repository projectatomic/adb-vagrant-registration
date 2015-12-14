# Changelog

- Fix: option auto-attach to accept user-defined values

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
