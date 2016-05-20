# vagrant-registration

<!-- MarkdownTOC -->

- [Installation](#installation)
- [Usage](#usage)
  - [Plugin Configuration](#plugin-configuration)
  - [Credentials Configuration](#credentials-configuration)
  - [subscription-manager Configuration](#subscription-manager-configuration)
    - [subscription-manager Default Options](#subscription-manager-default-options)
    - [subscription-manager Options Reference](#subscription-manager-options-reference)
  - [rhn-register Configuration](#rhn-register-configuration)
    - [rhn-register Default Options](#rhn-register-default-options)
    - [rhn-register Options Reference](#rhn-register-options-reference)
- [Development](#development)
  - [Tests](#tests)
    - [Shell script based tests](#shell-script-based-tests)
    - [Acceptance tests](#acceptance-tests)
- [Acknowledgements](#acknowledgements)

<!-- /MarkdownTOC -->

vagrant-registration plugin for Vagrant allows developers to easily register their guests for updates on systems with a subscription model (like Red Hat Enterprise Linux).

This plugin would run *register* action on `vagrant up` before any provisioning and *unregister* on `vagrant halt` or `vagrant destroy`. The actions then call the registration capabilities that have to be provided for given OS.

<a name="installation"></a>
## Installation

Install vagrant-registration as any other Vagrant plugin:

```shell
$ vagrant plugin install vagrant-registration
```

If you are on Fedora, you can install the packaged version of the plugin by running:

```shell
# dnf install vagrant-registration
```

<a name="usage"></a>
## Usage

The plugin is designed in an registration-manager-agnostic way which means that plugin itself does not depend on any OS nor way of registration. vagrant-registration only calls registration capabilities for given guest, passes the configuration options to them and handles interactive registration.

That being said, this plugin currently ships only with registration capability files for RHEL's Subscription Manager and `rhn_register`. Feel free to submit others.

To configure the plugin, always include the configuration options mentioned in this file within the following configuration block in your Vagrantfile.

```
Vagrant.configure('2') do |config|
...
end
```

<a name="plugin-configuration"></a>
### Plugin Configuration

- **skip** skips the registration. If you wish to skip the registration process altogether, you can do so by setting a `skip` option to `true`:

```ruby
  config.registration.skip = true
```

- **unregister_on_halt** disables or enables automatic unregistration on halt (on shut down) so the box will unregister only on destroy. By default the plugin unregisters on halt, you can however change that by setting the option to `false`:

```ruby
  config.registration.unregister_on_halt = false
```

- **manager** selects the registration manager provider. By default the plugin will use the `subscription_manager` manager, you can however change that by setting the option to a different manager:

```ruby
  config.registration.manager = 'subscription_manager'
```

<a name="credentials-configuration"></a>
### Credentials Configuration

Setting up the credentials can be done as follows:

```ruby
Vagrant.configure('2') do |config|
...
  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.username = 'foo'
    config.registration.password = 'bar'
  end

  # Alternatively
  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.org = 'foo'
    config.registration.activationkey = 'bar'
  end
...
end
```

This should go, preferably, into the Vagrantfile in your Vagrant home directory
(defaults to ~/.vagrant.d), to make it available for every project. It can be
later overridden in an individual project's Vagrantfile if needed.

If you prefer not to store your username and/or password on your filesystem,
you can optionally configure vagrant-registration plugin to use environment
variables, such as:

```ruby
Vagrant.configure('2') do |config|
...
  config.registration.username = ENV['SUB_USERNAME']
  config.registration.password = ENV['SUB_PASSWORD']
...
end
```

If you do not provide credentials, you will be prompted for them in the "up process."

Please note the the interactive mode asks you for the preferred registration pair only
of the configured manager.

<a name="subscription-manager-configuration"></a>
### subscription-manager Configuration

vagrant-registration will use the `subscription_manager` manager by default or can be explicitly configured by setting the `manager` option to `subscription_manager`:

```ruby
Vagrant.configure('2') do |config|
...
  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.manager = 'subscription_manager'
  end
...
end
```

In case of `subscription_manager` manager for the preferred registration pair,
you would be ask on your username/password combination.

vagrant-registration supports all the options of subscription-manager's register command.
You can set any option easily by setting `config.registration.OPTION_NAME = 'OPTION_VALUE'`
in your Vagrantfile (please see the subscription-manager's documentation for option
description).

<a name="subscription-manager-default-options"></a>
#### subscription-manager Default Options

- **--force**: Subscription Manager will fail if you attempt to register an already registered machine (see the man page for explanation), therefore vagrant-registration appends the `--force` flag automatically when subscribing. If you would like to disable this feature, set `force` option to `false`:

```ruby
  config.registration.force = false
```

- **--auto-attach**: Vagrant would fail to install packages on registered RHEL system if the subscription is not attached, therefore vagrant-registration appends the
`--auto-attach` flag automatically when subscribing. To disable this option, set `auto_attach` option to `false`:

```ruby
  config.registration.auto_attach = false
```

Note that the `auto_attach` option is set to false when using org/activationkey for registration or if pools are specified.

<a name="subscription-manager-options-reference"></a>
#### subscription-manager Options Reference

```ruby
  # The username to subscribe with (required)
  config.registration.username

  # The password of the subscriber (required)
  config.registration.password

  # Give the hostname of the subscription service to use (required for Subscription
  # Asset Manager, defaults to Customer Portal Subscription Management)
  config.registration.serverurl

  # A path to a CA certificate, this file would be copied to /etc/rhsm/ca and
  # if the file does not have .pem extension, it will be automatically added
  config.registration.ca_cert

  # Give the hostname of the content delivery server to use to receive updates
  # (required for Satellite 6)
  config.registration.baseurl

  # Give the organization to which to join the system (required, except for
  # hosted environments)
  config.registration.org

  # Register the system to an environment within an organization (optional)
  config.registration.environment

  # Name of the subscribed system (optional, defaults to hostname if unset)
  config.registration.name

  # Auto attach suitable subscriptions (optional, auto attach if true,
  # defaults to true)
  config.registration.auto_attach

  # Attach existing subscriptions as part of the registration process (optional)
  config.registration.activationkey

  # Set the service level to use for subscriptions on that machine
  # (optional, used only used with the --auto-attach)
  config.registration.servicelevel

  # Set the operating system minor release to use for subscriptions for
  # the system (optional, used only used with the --auto-attach)
  config.registration.release

  # Force the registration (optional, force if true, defaults to true)
  config.registration.force

  # Set what type of consumer is being registered (optional, defaults to system)
  config.registration.type

  # Skip the registration (optional, skip if true, defaults to false)
  config.registration.skip

  # Attach to specified pool(s) (optional)
  #
  # Example:
  #   config.registration.pools = [ 'POOL-ID-1', 'POOL-ID-2' ]
  config.registration.pools
```

<a name="rhn-register-configuration"></a>
### rhn-register Configuration

vagrant-registration will use the `rhn_register` manager only if explicitly configured by setting the `manager` option to `rhn_register`:

```ruby
Vagrant.configure('2') do |config|
...
  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.manager = 'rhn_register'
  end
...
end
```

In case of a `rhn_register` manager, the preferred registration pair is the username/password/serverurl combination.

vagrant-registration supports most of the options of rhnreg_ks's command. You can set any option easily by setting `config.registration.OPTION_NAME = 'OPTION_VALUE'` in your Vagrantfile (please see the `rhnreg_ks`'s documentation for option description).

`rhn_register` manager reuses the naming of `subscription-manager`'s command options where possible.

<a name="rhn-register-default-options"></a>
#### rhn-register Default Options

- **--force**: `rhnreg_ks` command will fail if you attempt to register an already registered machine (see the man page for explanation), therefore vagrant-registration appends the `--force` flag automatically when subscribing. If you would like to disable this feature, set `force` option to `false`:

```ruby
  config.registration.force = false
```

<a name="rhn-register-options-reference"></a>
#### rhn-register Options Reference

```ruby
  # The username to register the system with under Spacewalk Server, Red Hat Satellite or
  # Red Hat Network Classic. This can be an existing Spacewalk, Red Hat Satellite or
  # Red Hat Network Classic username, or a new  user‐name.
  config.registration.username

  # The password associated with the username specified with the `--username` option.
  # This is an unencrypted password.
  config.registration.password

  # Give the URL of the subscription service to use (required for registering a
  # system with the "Spacewalk Server", "Red Hat Satellite" or "Red Hat Network Classic").
  # The configuration name is mapped to the `--serverUrl` option of rhnreg_ks command.
  #
  # The serverurl is mandatory and if you do not provide a value,
  # you will be prompted for them in the "up process."
  config.registration.serverurl

  # A path to a CA certificate file (optional)
  # The configuration name is mapped to the `--sslCACert` option of rhnreg_ks command.
  #
  # The CA certificate file is be uploaded to /usr/share/rhn/<ca_file_name> in guest
  # and the configuration  in `/etc/sysconfig/rhn/up2date` is updated to:
  # `sslCACert=/usr/share/rhn/<ca_file_name>`
  #
  # As default only the configuration in `/etc/sysconfig/rhn/up2date` is updated
  # to point to the CA certificate file that is present on Fedora, CentOS and RHEL:
  # `sslCACert=/usr/share/rhn/RHNS-CA-CERT`
  config.registration.ca_cert

  # Give the organization to which to join the system (required, except for
  # hosted environments)
  # The configuration name is mapped to the `--systemorgid` option of rhnreg_ks command.
  config.registration.org

  # Name of the subscribed system (optional, defaults to hostname if unset)
  # The configuration name is mapped to the `--profilename` option of rhnreg_ks command.
  config.registration.name

  # Attach existing subscriptions as part of the registration process (optional)
  config.registration.activationkey

  # Subscribe this system to the EUS channel tied to the system's redhat-release (optional)
  config.registration.use_eus_channel

  # Do not probe or upload any hardware info (optional)
  config.registration.nohardware

  #  Do not profile or upload any package info (optional)
  config.registration.nopackages

  # Do not upload any virtualization info (optional)
  config.registration.novirtinfo

  # Do not start rhnsd after completion (optional)
  config.registration.norhnsd

  # Force the registration (optional, force if true, defaults to true)
  config.registration.force

  # Skip the registration (optional, skip if true, defaults to false)
  config.registration.skip
```

<a name="development"></a>
## Development

To install a development environment, clone the repo and prepare dependencies by

```
gem install bundler -v 1.7.5
bundler install
```

The use of [RVM|https://rvm.io] is recommended. Verified to work with ruby 2.0.0p643.

<a name="tests"></a>
### Tests

<a name="shell-script-based-tests"></a>
#### Shell script based tests

Tests currently test the plugin with `subscription-manager` and  `rhn_register` on RHEL 7.1 guest and Fedora host. You need an imported RHEL 7.1 Vagrant box named `rhel-7.1`.

To run them:

```
export VAGRANT_REGISTRATION_MANAGER=
export VAGRANT_REGISTRATION_USERNAME=
export VAGRANT_REGISTRATION_PASSWORD=
export VAGRANT_REGISTRATION_ORG=
export VAGRANT_REGISTRATION_ACTIVATIONKEY=
export VAGRANT_REGISTRATION_SERVERURL=
export VAGRANT_REGISTRATION_CA_CERT=
./tests/run.sh
./tests/run_rhn_register.sh
```

To show the Vagrant output on the console during the tests run, set the `DEBUG`
environment variable on `1` before executing the test script:

```
export DEBUG=1
```

<a name="acceptance-tests"></a>
#### Acceptance tests

The source also contains a set of [Cucumber](https://cucumber.io/) acceptance tests. They can be run via:

    $ bundle exec rake features

The tests assume that the CDK box files are available under
_build/boxes/cdk-\<provider\>.box_. You can either copy the box files manually or
use the _get_cdk_ Rake task to download them.

Per default only the scenarios for CDK in combination with VirtualBox
are run. You can also run against Libvirt using the environment variable
_PROVIDER_:

    # Run tests against Libvirt
    $ bundle exec rake features  PROVIDER=libvirt

    # Run against VirtualBox and Libvirt
    $ bundle exec rake features PROVIDER=virtualbox,libvirt

You can also run a single feature specifying the explicit feature file to use:

    $ bundle exec rake features FEATURE=features/<feature-filename>.feature

After test execution the Cucumber test reports can be found under _build/features_report.html_.
They can also be opened via

    $ bundle exec rake features:open_report

<a name="acknowledgements"></a>
## Acknowledgements

The project would like to make sure we thank [purpleidea](https://github.com/purpleidea/), [humaton](https://github.com/humaton/), [strzibny](https://github.com/strzibny), [scollier](https://github.com/scollier/), [puzzle](https://github.com/puzzle), [voxik](https://github.com/voxik), [lukaszachy](https://github.com/lukaszachy), [goern](https://github.com/goern), [iconoeugen](https://github.com/iconoeugen)  and [pvalena](https://github.com/pvalena) (in no particular order) for their contributions of ideas, code and testing for this project.
