require 'vagrant-aws/util/elb'

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Register

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::action::register")
        end

        def call(env)
          @app.call(env)
          @logger.info("Testing for registration_register capability on #{@machine.name}")
          if @machine.guest.capability?(:registration_register)
            @logger.info("registration_register capability exists on #{@machine.name}")
            result = @machine.guest.capability(:registration_register)
            @logger.info("called registration_register capability on #{@machine.name}")
          end
        end
      end
    end
  end
end
