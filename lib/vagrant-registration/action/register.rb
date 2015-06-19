require "log4r"

module VagrantPlugins
  module Registration
    module Action
      # This registers the guest if the guest plugin supports it
      class Register
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_registration::action::register")
        end

        def call(env)
          @app.call(env)

          # Configuration from Vagrantfile
          config = env[:machine].config.registration
          machine = env[:machine]
          guest = env[:machine].guest

          if capabilities_provided?(guest) && manager_installed?(guest) && !config.skip
            env[:ui].info("Registering box with vagrant-registration...")

            unless credentials_provided? machine
              @logger.debug("Credentials for registration not provided")

              # Offer to register ATM or skip
              register_now = env[:ui].ask("Would you like to register the system now (default: yes)? [y|n] ")

              if register_now == 'n'
                config.skip = true
              else
                config = register_on_screen(machine, env[:ui])
              end
            end
            guest.capability(:registration_register) unless config.skip
          end

          @logger.debug("Registration is skipped due to the configuration") if config.skip
        end

        private

        # Check if registration capabilities are available
        def capabilities_provided?(guest)
          if guest.capability?(:registration_register) && guest.capability?(:registration_manager_installed)
            true
          else
            @logger.debug("Registration is skipped due to the missing guest capability")
            false
          end
        end

        # Check if selected registration manager is installed
        def manager_installed?(guest)
          if guest.capability(:registration_manager_installed)
            true
          else
            @logger.debug("Registration manager not found on guest")
            false
          end
        end

        # Fetch required credentials for selected manager
        def credentials_required(machine)
          if machine.guest.capability?(:registration_credentials)
            machine.guest.capability(:registration_credentials)
          else
            []
          end
        end

        # Secret options for selected manager
        def secrets(machine)
          if machine.guest.capability?(:registration_secrets)
            machine.guest.capability(:registration_secrets)
          else
            []
          end
        end

        # Check if required credentials has been provided in Vagrantfile
        def credentials_provided?(machine)
          credentials_required(machine).each do |option|
            return false unless machine.config.registration.send option
          end
          true
        end

        # Ask user on required credentials and return them,
        # skip options that are provided by Vagrantfile
        def register_on_screen(machine, ui)
          credentials_required(machine).each do |option|
            unless machine.config.registration.send(option)
              echo = !(secrets(machine).include? option)
              response = ui.ask("#{option}: ", echo: echo)
              machine.config.registration.send("#{option.to_s}=".to_sym, response)
            end
          end
          machine.config.registration
        end
      end
    end
  end
end
