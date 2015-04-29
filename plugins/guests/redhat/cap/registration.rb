module VagrantPlugins
  module GuestRedHat
    module Cap
      class Registration
        def self.registration_register(machine)
          cap = "#{self.registration_manager(machine).to_s}_register".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap, machine.config.registration)
          else
            false
          end
        end

        def self.registration_unregister(machine)
          cap = "#{self.registration_manager(machine).to_s}_unregister".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Check that the machine has the selected registration manager installed
        def self.registration_manager_installed(machine)
          cap = "#{self.registration_manager(machine).to_s}".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Required configuration options of the registration manager
        def self.registration_credentials(machine)
          cap = "#{self.registration_manager(machine).to_s}_credentials".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            []
          end
        end

        # Return selected registration manager or default
        def self.registration_manager(machine)
          (machine.config.registration.manager || 'subscription_manager').to_sym
        end
      end
    end
  end
end
