module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest plugin supports it
      class Unregister

        def initialize(app, env)
          @app    = app
          @env    = env
          @logger = Log4r::Logger.new("vagrant_register::action::unregister")
        end

        def call(env)
          guest = @env[:machine].guest
          #   @logger.info("Testing for registration_unregister capability on ")
          if guest.capability?(:unregister)
            @logger.info("registration_unregister capability exists on ")
            result = guest.capability(:unregister)
            @logger.info("called registration_unregister capability on ")
          end
          
          @app.call(env)

        rescue Vagrant::Errors::MachineGuestNotReady => e
          @logger.info("Machine is offline (caught error: #{e.inspect} ), no need to unreg: #{e.inspect}")
        end
      end
    end
  end
end
