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
          guest = env[:machine].guest

          if guest.capability?(:unregister)
            if !env[:machine].config.registration.skip
              env[:ui].info("Unregistering box with vagrant-registration...")
              @logger.info("registration_unregister capability exists on ")
              result = guest.capability(:unregister)
              @logger.info("called registration_unregister capability on ")
            else
              @logger.debug("unregistration is skipped due to configuration")
            end
          else
            @logger.debug("unregistration is skipped due to missing guest capability")
          end

          @app.call(env)

        # Guest might not be available after halting, so log the exception and continue
        rescue => e
          @logger.info(e)
          @logger.debug("guest is not available, ignore unregistration")
          @app.call(env)
        end
      end
    end
  end
end
