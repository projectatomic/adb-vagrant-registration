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
          if @machine.guest.capability?(:registration_unsubscribe)
            result = @machine.guest.capability(:registration_unsubscribe)
          end
        end
      end
    end
  end
end
