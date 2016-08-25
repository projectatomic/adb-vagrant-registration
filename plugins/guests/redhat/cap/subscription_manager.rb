module VagrantPlugins
  module GuestRedHat
    module Cap
      class SubscriptionManager
        # Test that the machine is already registered
        def self.subscription_manager_registered?(machine)
          false if machine.communicate.sudo("/usr/sbin/subscription-manager list --consumed | grep 'No consumed subscription pools to list'")
        rescue
          true
        end

        # Test that we have subscription-manager installed
        def self.subscription_manager(machine)
          machine.communicate.test('/usr/sbin/subscription-manager', sudo: true)
        end

        # Register the machine using 'register' option, config is (Open)Struct
        def self.subscription_manager_register(machine, ui)
          subscription_manager_upload_certificate(machine, ui) if machine.config.registration.ca_cert
          command = "subscription-manager register #{configuration_to_options(machine.config.registration)}"

          # Handle exception to avoid displaying password
          begin
            error = String.new
            machine.communicate.sudo(registration_command(command)) do |type, data|
              error += "#{data}" if type == :stderr
            end
          rescue Vagrant::Errors::VagrantError
            raise Vagrant::Errors::VagrantError.new, error.strip
          end

          attach_pools(machine, machine.config.registration.pools)
        end

        # Unregister the machine using 'unregister' option
        def self.subscription_manager_unregister(machine)
          machine.communicate.sudo("subscription-manager unregister #{configuration_to_options_unregister(machine.config.registration)}")
        end

        # Return required configuration options for subscription-manager
        def self.subscription_manager_credentials(machine)
          [[:username, :password], [:org, :activationkey]]
        end

        # Return all available options for subscription-manager
        #
        # ca_cert is not part of 'register' command API, but it's needed
        # in conjuntion with serverurl option.
        def self.subscription_manager_options(machine)
          [:username, :password, :serverurl, :baseurl, :org, :environment,
           :name, :auto_attach, :activationkey, :servicelevel, :release,
           :force, :type, :ca_cert, :pools, :proxy, :proxyUser, :proxyPassword]
        end

        # Return secret options for subscription-manager
        def self.subscription_manager_secrets(machine)
          [:password]
        end

        private

        # Upload provided CA cert to the standard /etc/rhsm/ca path on the guest
        #
        # Since subscription-manager recognizes only .pem files, we rename those
        # files not ending with '.pem' extension.
        def self.subscription_manager_upload_certificate(machine, ui)
          ui.info("Uploading CA certificate from #{machine.config.registration.ca_cert}...")
          if File.exist?(machine.config.registration.ca_cert)
            cert_file_content = File.read(machine.config.registration.ca_cert)
            cert_file_name = File.basename(machine.config.registration.ca_cert)
            cert_file_name = "#{cert_file_name}.pem" unless cert_file_name.end_with? '.pem'
            machine.communicate.sudo("echo '#{cert_file_content}' > /etc/rhsm/ca/#{cert_file_name}")
            ui.info('Setting repo_ca_cert option in /etc/rhsm/rhsm.conf...')
            machine.communicate.sudo("sed -i 's|^repo_ca_cert\s*=.*|repo_ca_cert = /etc/rhsm/ca/#{cert_file_name}|g' /etc/rhsm/rhsm.conf")
          else
            ui.warn("WARNING: Provided CA certificate file #{machine.config.registration.ca_cert} does not exist, skipping")
          end
        end

        # Build registration command that skips registration if the system is registered
        def self.registration_command(command)
          "cmd=$(#{command}); if [ \"$?\" != \"0\" ]; then echo $cmd | grep 'This system is already registered' || (echo $cmd 1>&2 && exit 1) ; fi"
        end

        # Build additional subscription-manager options based on plugin configuration
        def self.configuration_to_options(config)
          config.force = true if config.force.nil?

          # --auto-attach cannot be used in case of org/activationkey registration
          # or if pools are specified
          if (config.org && config.activationkey) || config.pools
            config.auto_attach = false
          else
            config.auto_attach = true if config.auto_attach.nil?
          end

          options = []
          options << "--username='#{config.username}'" if config.username
          options << "--password='#{config.password}'" if config.password
          options << "--serverurl='#{config.serverurl}'" if config.serverurl
          options << "--baseurl='#{config.baseurl}'" if config.baseurl
          options << "--org='#{config.org}'" if config.org
          options << "--environment='#{config.environment}'" if config.environment
          options << "--name='#{config.name}'" if config.name
          options << '--auto-attach' if config.auto_attach
          options << "--activationkey='#{config.activationkey}'" if config.activationkey
          options << "--servicelevel='#{config.servicelevel}'" if config.servicelevel
          options << "--release='#{config.release}'" if config.release
          options << '--force' if config.force
          options << "--type='#{config.type}'" if config.type
          options << "--proxy='#{config.proxy}'" if config.proxy
          options << "--proxyuser='#{config.proxyUser}'" if config.proxyUser
          options << "--proxypassword='#{config.proxyPassword}'" if config.proxyPassword
          options.join(' ')
        end

        # Build subscription manager options for unregistering the Vagrant guest
        def self.configuration_to_options_unregister(config)
          options = []
          options << "--proxy='#{config.proxy}'" if config.proxy
          options << "--proxyuser='#{config.proxyUser}'" if config.proxyUser
          options << "--proxypassword='#{config.proxyPassword}'" if config.proxyPassword
          options.join(' ')
        end

        # Attach subscription pools
        def self.attach_pools(machine, pools)
          if pools
            command = "subscription-manager attach #{pools_to_options(pools)}"
            machine.communicate.sudo(command)
          end
        end

        # Return pools options for subscription-manager
        def self.pools_to_options(pools)
          pools = [pools] if pools.kind_of?(String)
          pools.map do |pool|
            "--pool=#{pool}"
          end.join(' ')
        end
      end
    end
  end
end
