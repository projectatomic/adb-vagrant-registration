require "log4r"

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Unregister

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_registration::action::unregister")
        end

        def call(env)
          config = env[:machine].config.registration
          guest = env[:machine].guest

          if guest.capability?(:registration_unregister) && guest.capability?(:registration_manager_installed)
            unless guest.capability(:registration_manager_installed)
              config.skip=true
              @logger.info("Registration manager not found on guest")
            end

            if !config.skip
              env[:ui].info("Unregistering box with vagrant-registration...")
              result = guest.capability(:registration_unregister)
            else
              @logger.debug("Unregistration is skipped due to the configuration")
            end
          else
            @logger.debug("Unregistration is skipped due to the missing guest capability")
          end
          @app.call(env)

        # Guest might not be available after halting, so log the exception and continue
        rescue => e
          @logger.info(e)
          @logger.debug("Guest is not available, ignore unregistration")
          @app.call(env)
        end
      end
    end
  end
end
