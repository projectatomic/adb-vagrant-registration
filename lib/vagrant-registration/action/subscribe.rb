require 'vagrant-aws/util/elb'

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Subscribe

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::action::subscribe")
        end

        def call(env)
          @app.call(env)
          @logger.info("Testing for registration_subscribe capability on #{@machine.name}")
          if @machine.guest.capability?(:registration_subscribe)
            @logger.info("registration_subscribe capability exists on #{@machine.name}")
            result = @machine.guest.capability(:registration_subscribe)
            @logger.info("called registration_subscribe capability on #{@machine.name}")
          end
        end
      end
    end
  end
end
