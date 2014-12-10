# vagrant-registration

The vagrant-registration plugin supports new capabilities "register" and "unregister." The "register" event occurs during the "up" process, immediately after startup but before any provisioning (including built-in like rysnc). The "unregister" event occurs during the "halt" process (which also is called during the "destroy" process) immediately before the instances goes down. 

Essentially, this supports developers wanting to use linuxes that have a subscription model for updates, like RHEL.

To use, make sure you have the cabilities registered, then set environment variables for your user and password.The two environment variables are 'SUB_USERNAME' and 'SUB_PASSWORD'. Decided to use environment variables to not force the user to type in the user and pass all the time.

## Using

The plugin is still very early alpha, so YMMV. If you try it out, and have problems, please feel free to file an issue. 

* vagrant plugin install vagrant-registration
* Set SUB_USERNAME & SUB_PASSWORD env vars
* that should be it

## Support
Currently, "capabilities" are only provided for Red Hat's Subscription Manager. To add others, one just needs to add a new guest plugin, then a cap directory with register.rb and unregister.rb. See the redhat guest for an example. 
