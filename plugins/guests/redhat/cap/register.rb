module VagrantPlugins
  module GuestRedHat
    module Cap
      class Register
        def self.register(machine)
          cap = "#{self.register_manager(machine).to_s}_register".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        def self.register_unregister(machine)
          cap = "#{self.register_manager(machine).to_s}_unregister".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Check that the machine has the selected registration manager installed
        def self.register_manager_installed(machine)
          cap = "#{self.register_manager(machine).to_s}".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Required configuration options of the registration manager
        def self.register_credentials(machine)
          cap = "#{self.register_manager(machine).to_s}_credentials".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            []
          end
        end

        # Return selected registration manager or default
        def self.register_manager(machine)
          machine.config.registration.manager || :subscription_manager
        end
      end
    end
  end
end
