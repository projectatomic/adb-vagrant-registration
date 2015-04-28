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
          config = env[:machine].config.registration
          machine = env[:machine]
          guest = env[:machine].guest
          @logger.info("Testing for registration capability")

          if guest.capability?(:registration_register) && guest.capability?(:registration_manager_installed)
            unless guest.capability(:registration_manager_installed)
              config.skip=true
              @logger.info("Registration manager not found on guest")
            end

            unless config.skip
              env[:ui].info("Registering box with vagrant-registration...")

              # Check if credentials are provided, ask user if not
              unless credentials_provided? machine
                @logger.debug("Credentials for registration not provided")

                # Offer to register ATM or skip
                register_now = env[:ui].ask("Would you like to register the system now (default: yes)? [y|n] ")

                if register_now == 'n'
                  config.skip = true
                # Accept anything else as default
                else
                  config = register_on_screen(machine, env[:ui])
                end
              end

              @logger.info("Registration is forced") if config.force
              @logger.info("Registration is skipped") if config.skip
              guest.capability(:registration_register) unless config.skip
            else
              @logger.debug("Registration is skipped due to the configuration")
            end
          else
            @logger.debug("Registration is skipped due to the missing guest capability")
          end
        end

        private

        # Fetch required credentials for selected manager
        def credentials_required(machine)
          if machine.guest.capability?(:registration_credentials)
            machine.guest.capability(:registration_credentials)
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

        # Ask user on required credentials and return them
        def register_on_screen(machine, ui)
          credentials_required(machine).each do |option|
            # Skip options that are provided by Vagrantfile
            unless machine.config.registration.send(option)
              response = ui.ask("#{option}: ", echo: true)
              machine.config.registration.send("#{option.to_s}=".to_sym, response)
            end
          end
          machine.config.registration
        end

      end
    end
  end
end
