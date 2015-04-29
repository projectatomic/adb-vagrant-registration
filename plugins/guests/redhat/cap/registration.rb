module VagrantPlugins
  module GuestRedHat
    module Cap
      # This provides registration capabilities for vagrant-registration
      #
      # As we might support more registration options (managers), this
      # just calls the capabilities of the selected registration manager
      # (from config.registration.manager).
      class Registration
        # Register the given machine
        def self.registration_register(machine)
          cap = "#{self.registration_manager(machine).to_s}_register".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap, machine.config.registration)
          else
            false
          end
        end

        # Unregister the given machine
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

        # Return secret options for the registration manager
        def self.registration_secrets(machine)
          cap = "#{self.registration_manager(machine).to_s}_secrets".to_sym
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
