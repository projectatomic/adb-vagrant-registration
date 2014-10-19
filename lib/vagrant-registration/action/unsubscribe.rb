require 'vagrant-aws/util/elb'

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Unsubscribe

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::action::unsubscribe")
        end

        def call(env)
          @app.call(env)
          @logger.info("Testing for registration_unsubscribe capability on #{@machine.name}")
          if @machine.guest.capability?(:registration_unsubscribe)
            @logger.info("registration_unsubscribe capability exists on #{@machine.name}")
            result = @machine.guest.capability(:registration_unsubscribe)
            @logger.info("called registration_unsubscribe capability on #{@machine.name}")
          end
        end
      end
    end
  end
end
