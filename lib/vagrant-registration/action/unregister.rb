require 'vagrant-aws/util/elb'

#{@machine.name}
module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Unregister

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::action::unregister")
        end

        def call(env)
          @app.call(env)
          @logger.info("Testing for registration_unregister capability on ")
          if @machine.guest.capability?(:registration_unregister)
            @logger.info("registration_unregister capability exists on ")
            result = @machine.guest.capability(:registration_unregister)
            @logger.info("called registration_unregister capability on ")
          end
        end
      end
    end
  end
end
