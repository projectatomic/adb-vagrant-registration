require "log4r"

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest has registration capability
      class UnregisterOnHalt
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_registration::action::unregister_on_halt")
        end

        def call(env)
          config = env[:machine].config.registration
          guest = env[:machine].guest

          if capabilities_provided?(guest) && manager_installed?(guest) && !config.skip && config.unregister_on_halt
            env[:ui].info("Unregistering box with vagrant-registration...")
            guest.capability(:registration_unregister)
          end

          @logger.debug("Unregistration is skipped due to the configuration") if config.skip
          @logger.debug("Unregistration is skipped on halt due to the configuration") if !config.unregister_on_halt
          @app.call(env)

        # Guest might not be available after halting, so log the exception and continue
        rescue => e
          @logger.info(e)
          @logger.debug("Guest is not available, ignore unregistration")
          @app.call(env)
        end

        private

        # Check if registration capabilities are available
        def capabilities_provided?(guest)
          if guest.capability?(:registration_unregister) && guest.capability?(:registration_manager_installed)
            true
          else
            @logger.debug("Unregistration is skipped due to the missing guest capability")
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
      end
    end
  end
end
