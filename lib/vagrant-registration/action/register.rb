module VagrantPlugins
  module Registration
    module Action
      # This registers the guest if the guest plugin supports it
      class Register

        def initialize(app, env)
          @app    = app
          @env    = env
          @logger = Log4r::Logger.new("vagrant_register::action::register")
        end

        def call(env)
          @app.call(env)
          guest = @env[:machine].guest
          @logger.info("Testing for registration_register capability on ")

          if guest.capability?(:registration_register)
            @logger.info("registration_register capability exists on ")
            result = guest.capability(:registration_register)
            @logger.info("called registration_register capability on ")
          end
        end
      end
    end
  end
end
