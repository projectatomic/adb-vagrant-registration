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
          guest = env[:machine].guest
          @logger.info("Testing for registration_register capability on ")

          if guest.capability?(:register)
            if !env[:machine].config.registration.skip
              env[:ui].info("Registering box with vagrant-registration...")
              @logger.info("registration_register capability exists on ")
              result = guest.capability(:register)
              @logger.info("called registration_register capability on ")
            else
              @logger.info("registration skipped due to configuration")
            end
          else
            @logger.info("registration skipped due to missing guest capability")
          end
        end
      end
    end
  end
end
