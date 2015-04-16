# vagrant-registration

The vagrant-registration plugin supports new capabilities "register" and "unregister." The "register" event occurs during the "up" process, immediately after startup but before any provisioning (including built-in like rsync). The "unregister" event occurs during the "halt" process (which also is called during the "destroy" process) immediately before the instances goes down.

This allows developers to easily register their guests that use subscription model for updates, like Red Hat Enterprise Linux.



## Installation

Install as any other Vagrant plugin:

```ruby
vagrant plugin install vagrant-registration
```

## Usage

*Note:* This plugin is still alpha. Please help us to find and fix any bugs.

- Only RHEL Subscription Manager is currectly supported.

### subscription-manager Configuration

vagrant-registration supports all the options of subscription-manager's register command.
You can set any option easily by setting `config.registration.OPTION_NAME = 'OPTION_VALUE'`
in your Vagrantfile (please see the subscription-manager's documentation for option
description).

Setting up the credentials can be done as follows:

```ruby
    config.registration.username = 'foo'
    config.registration.password = 'bar'
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

If you do not provide credentials, you will be prompted for them in the "up process". However, this is a tentative feature because if you are launching more than one VM from one Vagrantfile, the feature acts unexepectedly (appearing to hang because the prompt for creds gets lost in the scrollback). 

You can also skip the registration process altogether by setting a `skip` option
to `true`:

```ruby
    config.registration.skip = true
```

*Note:* RHEL Subscription Manager will fail if you attempt to register an already registered machine (see man page for explanation). Not to slow the boot time, vagrant-registration appends the "--force" flag when subscribing. If you would like to disable this feature, set `force` option to `false`:

```ruby
    config.registration.force = false 
```

## Acknowledgements
The project would like to make sure we thank [purpleidea](https://github.com/purpleidea/), [humaton](https://github.com/humaton/), [strzibny](https://github.com/strzibny), [scollier](https://github.com/scollier/), [puzzle](https://github.com/puzzle), [voxik](https://github.com/voxik), [lukaszachy](https://github.com/lukaszachy) and [goern](https://github.com/goern) (in no particular order) for their contributions of ideas, code and testing for this project.