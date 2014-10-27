module VagrantPlugins
  module GuestRedHat
    module Cap
      class Register
        def self.register(machine)
          username = machine.config.registration.subscriber_username
          password = machine.config.registration.subscriber_password	       
          machine.communicate.execute("sudo subscription-manager register --username=#{username} --password=#{password} --auto-attach")
        rescue IOError
        # Ignore, this probably means connection closed because it
        # shut down.
        end
      end
    end
  end
end
