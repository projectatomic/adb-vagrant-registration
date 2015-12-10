module VagrantPlugins
  module GuestRedHat
    module Cap
      # Common configuration options for all managers
      DEFAULT_CONFIGURATION_OPTIONS = [:manager, :skip, :unregister_on_halt]

      # This provides registration capabilities for vagrant-registration
      #
      # As we might support more registration options (managers), this
      # just calls the capabilities of the selected registration manager
      # (from config.registration.manager).
      class Registration
        # Is the machine already registered?
        def self.registration_registered?(machine)
          cap = "#{registration_manager(machine).to_s}_registered?".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Register the given machine
        def self.registration_register(machine, ui)
          cap = "#{registration_manager(machine).to_s}_register".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap, ui)
          else
            false
          end
        end

        # Unregister the given machine
        def self.registration_unregister(machine)
          cap = "#{registration_manager(machine).to_s}_unregister".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            false
          end
        end

        # Check that the machine has the selected registration manager installed
        # and warn if the user specifically selected a manager that is not available
        def self.registration_manager_installed(machine, ui)
          cap = "#{registration_manager(machine).to_s}".to_sym
          return machine.guest.capability(cap) if machine.guest.capability?(cap)
          if machine.config.registration.manager != ''
            ui.error("WARNING: Selected registration manager #{machine.config.registration.manager} is not available, skipping.")
          end
          false
        end

        # Required configuration options of the registration manager
        #
        # This is array of arrays of all possible registration combinations.
        # First one is the default used in interactive mode.
        #
        # e.g. [[:username, :password]]
        def self.registration_credentials(machine)
          cap = "#{registration_manager(machine).to_s}_credentials".to_sym
          if machine.guest.capability?(cap)
            machine.guest.capability(cap)
          else
            []
          end
        end

        # Return all available options for a given registration manager together
        # with general options available to any.
        def self.registration_options(machine)
          cap = "#{registration_manager(machine).to_s}_options".to_sym
          if machine.guest.capability?(cap)
            DEFAULT_CONFIGURATION_OPTIONS + machine.guest.capability(cap)
          else
            DEFAULT_CONFIGURATION_OPTIONS
          end
        end

        # Return secret options for the registration manager
        def self.registration_secrets(machine)
          cap = "#{registration_manager(machine).to_s}_secrets".to_sym
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
