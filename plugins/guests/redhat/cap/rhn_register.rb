module VagrantPlugins
  module GuestRedHat
    module Cap
      class RhnRegister
        # Test that the machine is already registered
        def self.rhn_register_registered?(machine)
          true if machine.communicate.execute('/usr/sbin/rhn_check', sudo: true)
        rescue
          false
        end

        # Test that we have rhn installed
        def self.rhn_register(machine)
          machine.communicate.test('/usr/sbin/rhn_check --version', sudo: true) &&
            machine.communicate.test('/usr/sbin/rhnreg_ks --version', sudo: true)
        end

        # Register the machine using 'rhnreg_ks' command, config is (Open)Struct
        def self.rhn_register_register(machine, ui)
          rhn_register_upload_certificate(machine, ui) if machine.config.registration.ca_cert
          rhn_register_server_url(machine, ui) if machine.config.registration.serverurl
          command = "rhnreg_ks #{configuration_to_options(machine.config.registration)}"
          machine.communicate.execute("cmd=$(#{command}); if [ \"$?\" != \"0\" ]; then echo $cmd | grep 'This system is already registered' || (echo $cmd 1>&2 && exit 1) ; fi", sudo: true)
        end

        # Unregister the machine using 'rhn_unregister.py' resource script
        def self.rhn_register_unregister(machine)
          machine.communicate.tap do |comm|
            tmp = '/tmp/rhn_unregister'
            system_id = '/etc/sysconfig/rhn/systemid'
            server_url = machine.config.registration.serverurl
            # Generate the api url
            server_url = server_url.sub(/XMLRPC$/, 'rpc/api')
            comm.sudo("rm -f #{tmp}", error_check: false)
            comm.upload(resource('rhn_unregister.py'), tmp)
            comm.sudo("python #{tmp} -s #{server_url} -f #{system_id}")
            comm.sudo("rm -f #{tmp}")
            # guest still "thinks" it is a part of RHN network until systemdid file is removed
            comm.sudo("rm -f #{system_id}")
          end
        end

        # Return required configuration options for rhn register
        def self.rhn_register_credentials(_)
          [[:username, :password], [:org, :activationkey]]
        end

        # Return all available options for rhn register
        def self.rhn_register_options(_)
          [:name, :username, :password, :org, :serverurl,
           :ca_cert, :activationkey, :use_eus_channel,
           :nohardware, :nopackages, :novirtinfo, :norhnsd,
           :force]
        end

        # Return secret options for rhreg_ks
        def self.rhn_register_secrets(_)
          [:password]
        end

        private

        # Upload provided SSL CA cert to the standard /usr/share/rhn/ path on the guest
        def self.rhn_register_upload_certificate(machine, ui)
          ui.info("Uploading CA certificate from #{machine.config.registration.ca_cert}...")
          if File.exist?(machine.config.registration.ca_cert)
            cert_file_content = File.read(machine.config.registration.ca_cert)
            cert_file_name = File.basename(machine.config.registration.ca_cert)
            machine.communicate.execute("echo '#{cert_file_content}' > /usr/share/rhn/#{cert_file_name}", sudo: true)
            machine.communicate.execute("sed -i 's|^sslCACert=.*$|sslCACert=/usr/share/rhn/#{cert_file_name}|' /etc/sysconfig/rhn/up2date", sudo: true)
          else
            ui.warn("WARNING: Provided CA certificate file #{machine.config.registration.ca_cert} does not exist, skipping")
          end
        end

        # Update configuration file '/etc/sysconfig/rhn/up2date' with
        # provided server URL
        def self.rhn_register_server_url(machine, ui)
          ui.info("Update server URL to #{machine.config.registration.serverurl}...")
          machine.communicate.execute("sed -i 's|^serverURL=.*$|serverURL=/usr/share/rhn/#{machine.config.registration.serverurl}|' /etc/sysconfig/rhn/up2date", sudo: true)
        end

        # @param name [String] the resource file name
        # @return [String] the absolute path to the resource file
        def self.resource(name)
          File.join(resource_root, name)
        end

        # @return [String] the absolute path to the resource directory
        def self.resource_root
          File.expand_path('../../../../../resources', __FILE__)
        end

        # Build additional rhreg_ks options based on plugin configuration
        def self.configuration_to_options(config)
          config.force = true unless config.force

          options = []
          options << "--profilename='#{config.name}'" if config.name
          options << "--username='#{config.username}'" if config.username
          options << "--password='#{config.password}'" if config.password
          options << "--systemorgid='#{config.org}'" if config.org
          options << "--serverUrl='#{config.serverurl}'" if config.serverurl
          options << "--activationkey='#{config.activationkey}'" if config.activationkey
          options << '--use_eus_channel' if config.use_eus_channel
          options << '--nohardware' if config.nohardware
          options << '--nopackages' if config.nopackages
          options << '--novirtinfo' if config.novirtinfo
          options << '--norhnsd' if config.norhnsd
          options << '--force' if config.force
          options.join(' ')
        end
      end
    end
  end
end
