module VagrantPlugins
  module GuestRedHat
    module Cap
      class SubscriptionManager
        # Test that we have subscription-manager installed
        def self.subscription_manager(machine)
          machine.communicate.test("/sbin/subscription-manager", sudo: true)
        end

        # Register the machine using 'register' option, config is (Open)Struct
        def self.subscription_manager_register(machine, config)
          command = "subscription-manager register #{configuration_to_options(config)}"
          machine.communicate.execute("cmd=$(#{command}); if [ \"$?\" != \"0\" ]; then echo $cmd | grep 'This system is already registered' || (echo $cmd 1>&2 && exit 1) ; fi", sudo: true)
        end

        # Unregister the machine using 'unregister' option
        def self.subscription_manager_unregister(machine)
          machine.communicate.execute("subscription-manager unregister || :", sudo: true)
        end

        # Return required configuration options for subscription-manager
        def self.subscription_manager_credentials(machine)
          [:username, :password]
        end

        private

        # Build additional subscription-manager options based on plugin configuration
        def self.configuration_to_options(config)
          options = []
          options << "--username=#{config.username}"
          options << "--password=#{config.password}"
          options << "--serverurl=#{config.serverurl}" if config.serverurl
          options << "--baseurl=#{config.baseurl}" if config.baseurl
          options << "--org=#{config.org}" if config.org
          options << "--environment=#{config.environment}" if config.environment
          options << "--name=#{config.name}" if config.name
          options << "--auto-attach" if config.auto_attach
          options << "--activationkey=#{config.activationkey}" if config.activationkey
          options << "--servicelevel=#{config.servicelevel}" if config.servicelevel
          options << "--release=#{config.release}" if config.release
          options << "--force" if config.force
          options << "--type=#{config.type}" if config.type
          options.join(' ')
        end
      end
    end
  end
end
