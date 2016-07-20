require 'log4r'

module VagrantPlugins
  module Registration
    module Action
      # This unregisters the guest if the guest has registration capability
      class UnregisterOnHalt
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_registration::action::unregister_on_halt')
        end

        def call(env)
          config = env[:machine].config.registration
          guest = env[:machine].guest

          if capabilities_provided?(guest) && manager_installed?(guest, env[:ui]) && !config.skip && config.unregister_on_halt
            env[:ui].info I18n.t('registration.action.unregister.unregistration_info')
            guest.capability(:registration_unregister)
          end

          @logger.debug(I18n.t('registration.action.unregister.skip_due_config')) if config.skip
          @logger.debug(I18n.t('registration.action.unregister.skip_on_halt_due_config')) unless config.unregister_on_halt
          @app.call(env)

        # Guest might not be available after halting, so log the exception and continue
        rescue => e
          @logger.info(e)
          @logger.debug I18n.t('registration.action.unregister.guest_unavailable')
          @app.call(env)
        end

        private

        # Check if registration capabilities are available
        def capabilities_provided?(guest)
          if guest.capability?(:registration_unregister) && guest.capability?(:registration_manager_installed)
            true
          else
            @logger.debug I18n.t('registration.action.unregister.skip_missing_guest_capability')
            false
          end
        end

        # Check if selected registration manager is installed
        def manager_installed?(guest, ui)
          if guest.capability(:registration_manager_installed, ui)
            true
          else
            @logger.debug I18n.t('registration.action.manager_not_found')
            false
          end
        end
      end
    end
  end
end
