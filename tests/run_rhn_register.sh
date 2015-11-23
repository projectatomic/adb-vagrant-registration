#!/bin/bash

# This tests test vagrant-registration plugin running on Fedora
# with libvirt. If you do not have Vagrant installed or if you
# have vagrant-libvirt package on your system, Vagrant will be
# installed or vagrant-libvirt removed respectively. In that case
# you need sudo to run the tests. If you do not run Fedora, make
# sure you have Vagrant installed (any provider should do if you
# add RHEL box called 'rhel-7').
#
# IMPORTANT: Tests need valid credentials to actually test
# registration. This can be provided in form of environment
# variables.
#
# NOTE: This will install a development version of
# vagrant-registration on your system.
#
# == rhn-register
#
# For testing RHN Classic on RHEL export
# VAGRANT_REGISTRATION_USERNAME with VAGRANT_REGISTRATION_PASSWORD
# for username/password registration and VAGRANT_REGISTRATION_ORG
# with VAGRANT_REGISTRATION_ACTIVATIONKEY for org/activationkey one.
#

DIR=$(dirname $(readlink -f "$0"))

# Import test helpers
. $DIR/helpers.sh

setup_tests

# Test correct username/password and org/activationkey credentials in a multi-machine setup
clean_up
export VAGRANT_REGISTRATION_MANAGER=rhn_register
export VAGRANT_VAGRANTFILE=$DIR/vagrantfiles/Vagrantfile.rhel_multi_machine

test_success 'vagrant up on RHEL multi_machine setup' 'vagrant up rhel1-valid-credentials'

test_success 'first machine is registered with given username/password' \
            'vagrant ssh rhel1-valid-credentials -c '\''sudo rhn_check'\'''

test_success 'vagrant halt on RHEL multi_machine setup' 'vagrant halt rhel1-valid-credentials'
test_success 'vagrant halt on RHEL multi_machine setup' 'vagrant destroy'
test_success 'vagrant up on RHEL multi_machine setup' 'vagrant up rhel2-valid-credentials'

test_success 'second machine is registered with given org/activationkey' \
            'vagrant ssh rhel2-valid-credentials -c '\''sudo rhn_check'\'''

test_success 'vagrant halt on RHEL multi_machine setup' 'vagrant destroy'

# Test wrong credentials
clean_up
export VAGRANT_VAGRANTFILE=$DIR/vagrantfiles/Vagrantfile.rhel_wrong_credentials
test_failure 'vagrant up on RHEL with wrong credentials should fail' 'vagrant up'
test_success 'vagrant destroy on RHEL with wrong credentials' 'vagrant destroy'

print_results
