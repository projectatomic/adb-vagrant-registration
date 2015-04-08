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
          guest = env[:machine].guest
          @logger.info("Testing for registration_register capability on ")

          if guest.capability?(:register) && guest.capability?(:subscription_manager)

            unless guest.capability(:subscription_manager)
              config.skip=true
              @logger.info("subscription-manager not found on guest")
            end

            unless config.skip
              env[:ui].info("Registering box with vagrant-registration...")

              # Check if credentials are provided, ask user if not
              unless credentials_provided? config
                @logger.debug("credentials for registration not provided")

                # Offer to register ATM or skip
                register_now = env[:ui].ask("Would you like to register the system now (default: yes)? [y|n] ")

                if register_now == 'n'
                  config.skip = true
                # Accept anything else as default
                else
                  config.username, config.password = register_on_screen(env[:ui])
                end
              end
              @logger.info("Registration is forced") if config.force
              result = guest.capability(:register) unless config.skip
            else
              @logger.debug("registration skipped due to configuration")
            end
          else
            @logger.debug("registration skipped due to missing guest capability")
          end
        end

        private

        # Ask user on username/password and return them
        def register_on_screen(ui)
          username = ui.ask("Subscriber username: ")
          password = ui.ask("Subscriber password: ", echo: false)
          [username, password]
        end

        # Check if username and password has been provided in Vagrantfile
        def credentials_provided?(config)
          config.username && config.password
        end
      end
    end
  end
end
