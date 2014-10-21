require 'vagrant-aws/util/elb'

#{@machine.name}
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
          @logger.info("Testing for registration_register capability on ")
          if @machine.guest.capability?(:registration_register)
            @logger.info("registration_register capability exists on ")
            result = @machine.guest.capability(:registration_register)
            @logger.info("called registration_register capability on ")
          end
        end
      end
    end
  end
end
