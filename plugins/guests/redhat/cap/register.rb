module VagrantPlugins
  module GuestRedHat
    module Cap
      class Register
        def self.register(machine)
          command = "subscription-manager register #{configuration_to_options(machine.config)}"
          machine.communicate.execute("cmd=$(#{command}); if [ \"$?\" != \"0\" ]; then echo $cmd | grep 'This system is already registered' || (echo $cmd 1>&2 && exit 1) ; fi", sudo: true)
        end

        private

        # Build additional subscription-manager options based on plugin configuration
        def self.configuration_to_options(config)
          options = []
          options << "--username=#{config.registration.username}"
          options << "--password=#{config.registration.password}"
          options << "--serverurl=#{config.registration.serverurl}" if config.registration.serverurl
          options << "--baseurl=#{config.registration.baseurl}" if config.registration.baseurl
          options << "--org=#{config.registration.org}" if config.registration.org
          options << "--environment=#{config.registration.environment}" if config.registration.environment
          options << "--name=#{config.registration.name}" if config.registration.name
          options << "--auto-attach" if config.registration.auto_attach
          options << "--activationkey=#{config.registration.activationkey}" if config.registration.activationkey
          options << "--servicelevel=#{config.registration.servicelevel}" if config.registration.servicelevel
          options << "--release=#{config.registration.release}" if config.registration.release
          options << "--force" if config.registration.force
          options << "--type=#{config.registration.type}" if config.registration.type
          options.join(' ')
        end
      end
    end
  end
end
