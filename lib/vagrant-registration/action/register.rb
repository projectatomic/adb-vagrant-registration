require 'log4r'

module VagrantPlugins
  module Registration
    module Action
      # This registers the guest if the guest plugin supports it
      class Register
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_registration::action::register')
        end

        def call(env)
          # Configuration from Vagrantfile
          config = env[:machine].config.registration
          machine = env[:machine]
          guest = env[:machine].guest

          if should_register?(machine, env[:ui])
            env[:ui].info('Registering box with vagrant-registration...')
            check_configuration_options(machine, env[:ui])

            unless credentials_provided? machine
              @logger.debug('Credentials for registration not provided')

              # Offer to register ATM or skip
              register_now = env[:ui].ask('Would you like to register the system now (default: yes)? [y|n]')

              if register_now == 'n'
                config.skip = true
              else
                config = register_on_screen(machine, env[:ui])
              end
            end
            guest.capability(:registration_register, env[:ui]) unless config.skip
          end

          @logger.debug('Registration is skipped due to the configuration') if config.skip

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
            ui.warn("WARNING: #{manager} supports only the following options:" \
                    "\nWARNING: #{available_options.join(', ')}")
          end
        end

        # Return true if there are any unsupported options
        def unsupported_options_provided?(manager, available_options, options, ui)
          warned = false
          options.each do |option|
            unless available_options.include? option
              ui.warn("WARNING: #{option} option is not supported for #{manager}")
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
            @logger.debug('Registration is skipped due to the missing guest capability')
            false
          end
        end

        # Check if selected registration manager is installed
        def manager_installed?(guest, ui)
          if guest.capability(:registration_manager_installed, ui)
            true
          else
            @logger.debug('Registration manager not found on guest')
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
      end
    end
  end
end
