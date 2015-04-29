# vagrant-registration

vagrant-registration plugin for Vagrant allows developers to easily register their guests for updates on systems with a subscription model (like Red Hat Enterprise Linux).

This plugin would run *register* action on `vagrant up` before any provisioning
and *unregister* on `vagrant halt` or `vagrant destroy`. The actions then call the registration capabilities that have to be provided for given OS.


## Installation

Install vagrant-registration as any other Vagrant plugin:

```ruby
vagrant plugin install vagrant-registration
```

## Usage

The plugin is designed in an registration-manager-agnostic way which means that plugin itself does not depend on any OS nor way of registration. vagrant-registration only calls registration capabilities for given guest, passes the configuration options to them and handles
interactive registration.

That being said, this plugin currently ships only with registration capability files for RHEL's Subscription Manager. Feel free to submit others.

*Note:* This plugin is still alpha. Please help us to find and fix any bugs.

### subscription-manager Configuration

vagrant-registration supports all the options of subscription-manager's register command.
You can set any option easily by setting `config.registration.OPTION_NAME = 'OPTION_VALUE'`
in your Vagrantfile (please see the subscription-manager's documentation for option
description).

Setting up the credentials can be done as follows:

```ruby
if Vagrant.has_plugin?('vagrant-registration')
  config.registration.username = 'foo'
  config.registration.password = 'bar'
end
```

This should go, preferably, into the Vagrantfile in your Vagrant home directory
(defaults to ~/.vagrant.d), to make it available for every project. It can be
later overriden in an individual project's Vagrantfile, if needed.

If you prefer not to store your username and/or password on your filesystem,
you can optionally configure vagrant-registration plugin to use environment
variables, such as:

```ruby
  config.registration.username = ENV['SUB_USERNAME']
  config.registration.password = ENV['SUB_PASSWORD']
```

If you do not provide credentials, you will be prompted for them in the "up process."

You can also skip the registration process altogether by setting a `skip` option
to `true`:

```ruby
  config.registration.skip = true
```

#### Default Options

- **--force**: Subscription Manager will fail if you attempt to register an already registered machine (see the man page for explanation), therefore vagrant-registration appends the `--force` flag automatically when subscribing. If you would like to disable this feature, set `force` option to `false`:

```ruby
  config.registration.force = false
```
- **--auto-attach**: Vagrant would fail to install packages on registered RHEL system if the subscription is not attached, therefore vagrant-registration appends the
`--auto-attach` flag automatically when subscribing. To disable this option, set `auto_attach` option to `false`:


```ruby
  config.registration.auto_attach = false
```

#### subscription-manager Options Reference

```ruby
  # The username to subscribe with (required)
  config.registration.username

  # The password of the subscriber (required)
  config.registration.password

  # Give the hostname of the subscription service to use (required for Subscription
  # Asset Manager, defaults to Customer Portal Subscription Management)
  config.registration.serverurl

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
```

## Acknowledgements

The project would like to make sure we thank [purpleidea](https://github.com/purpleidea/), [humaton](https://github.com/humaton/), [strzibny](https://github.com/strzibny), [scollier](https://github.com/scollier/), [puzzle](https://github.com/puzzle), [voxik](https://github.com/voxik), [lukaszachy](https://github.com/lukaszachy) and [goern](https://github.com/goern) (in no particular order) for their contributions of ideas, code and testing for this project.
