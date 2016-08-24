require 'log4r'

module VagrantPlugins
  module Registration
    module Action
      # This registers the guest if the guest plugin supports it
      class Register
        MAX_REGISTRATION_ATTEMPTS = 3

        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_registration::action::register')
        end

        def call(env)
          ui = env[:ui]
          # Configuration from Vagrantfile
          config = env[:machine].config.registration
          machine = env[:machine]
          guest = env[:machine].guest

          if should_register?(machine, ui)
            ui.info I18n.t('registration.action.register.registration_info')
            check_configuration_options(machine, ui)

            unless credentials_provided? machine
              @logger.debug I18n.t('registration.action.register.no_credentials')

              # Offer to register ATM or skip
              register_now = ui.ask I18n.t('registration.action.register.prompt')

              if register_now == 'n'
                config.skip = true
              else
                config = process_registration(guest, machine, ui, config)
              end
            end
          end

          @logger.debug(I18n.t('registration.action.register.skip_due_config')) if config.skip

          # Call next middleware in chain
          @app.call(env)
        end

        private

        # Shall we register the box?
        def should_register?(machine, ui)
          !machine.config.registration.skip &&
          capabilities_provided?(machine.guest) &&
          manager_installed?(machine.guest, ui) &&
          !machine.guest.capability(:registration_registered?)
        end

        # Issues warning if an unsupported option is used and displays
        # a list of supported options
        def check_configuration_options(machine, ui)
          manager = machine.guest.capability(:registration_manager).to_s
          available_options = machine.guest.capability(:registration_options)
          options = machine.config.registration.conf.each_pair.map { |pair| pair[0] }

          if unsupported_options_provided?(manager, available_options, options, ui)
            ui.warn(I18n.t('registration.action.register.options_support_warning',
                           manager: manager, options: available_options.join(', ')))
          end
        end

        # Return true if there are any unsupported options
        def unsupported_options_provided?(manager, available_options, options, ui)
          warned = false
          options.each do |option|
            unless available_options.include? option
              ui.warn(I18n.t('registration.action.register.unsupported_option',
                             manager: manager, option: option))
              warned = true
            end
          end
          warned
        end

        # Check if registration capabilities are available
        def capabilities_provided?(guest)
          if guest.capability?(:registration_register) &&
             guest.capability?(:registration_manager_installed) &&
             guest.capability?(:registration_registered?)
            true
          else
            @logger.debug I18n.t('registration.action.register.skip_missing_guest_capability')
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

        # Fetch required credentials for selected manager
        def credentials_required(machine)
          if machine.guest.capability?(:registration_credentials)
            machine.guest.capability(:registration_credentials)
          else
            []
          end
        end

        # Secret options for selected manager
        def secrets(machine)
          if machine.guest.capability?(:registration_secrets)
            machine.guest.capability(:registration_secrets)
          else
            []
          end
        end

        # Check if required credentials has been provided in Vagrantfile
        #
        # Checks if at least one of the registration options is able to
        # register.
        def credentials_provided?(machine)
          provided = true
          credentials_required(machine).each do |registration_option|
            provided = true
            registration_option.each do |value|
              provided = false unless machine.config.registration.send value
            end
            break if provided
          end
          provided ? true : false
        end

        # Ask user on required credentials and return them,
        # skip options that are provided by Vagrantfile
        def register_on_screen(machine, ui)
          credentials_required(machine)[0].each do |option|
            unless machine.config.registration.send(option)
              echo = !(secrets(machine).include? option)
              response = ui.ask("#{option}: ", echo: echo)
              machine.config.registration.send("#{option}=".to_sym, response)
            end
          end
          machine.config.registration
        end

        def process_registration(guest, machine, ui, config)
          attempt_count = 1

          MAX_REGISTRATION_ATTEMPTS.times do
            config = register_on_screen(machine, ui)

            begin
              guest.capability(:registration_register, ui)
              ui.info I18n.t('registration.action.register.registration_success')
              # break out of loop on successful registration
              break
            rescue StandardError => e
              if attempt_count == MAX_REGISTRATION_ATTEMPTS
                ui.error e.message
                exit 126
              else
                # reset registration config
                reset_registration_config(machine)
                attempt_count += 1
                ui.info I18n.t('registration.action.register.registration_retry',
                               attempt_count: attempt_count, max_attempt: MAX_REGISTRATION_ATTEMPTS)
              end
            end
          end

          config
        end

        def reset_registration_config(machine)
          credentials_required(machine)[0].each do |option|
            machine.config.registration.send("#{option}=".to_sym, nil)
          end
        end
      end
    end
  end
end
