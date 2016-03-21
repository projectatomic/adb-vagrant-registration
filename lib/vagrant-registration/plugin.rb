begin
  require 'vagrant'
rescue LoadError
  raise 'The vagrant-registration plugin must be run within Vagrant.'
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < '1.2.0'
  fail 'The Vagrant RHEL plugin is only compatible with Vagrant 1.2+.'
end

module VagrantPlugins
  module Registration
    class Plugin < Vagrant.plugin('2')
      class << self

        # vagrant-vbguest plugin updates GuestAdditions for VirtualBox
        # and therefore needs to be run after the box got registered.
        # See https://github.com/projectatomic/adb-vagrant-registration/issues/69
        #
        # vagrant-vbguest hooks before VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions
        # (see https://github.com/mitchellh/vagrant/blob/master/plugins/providers/virtualbox/action.rb#L81)
        # For registration to occur in time, it has to happen before that. Using WaitForCommunicator
        # to be sure - https://github.com/dotless-de/vagrant-vbguest/blob/master/lib/vagrant-vbguest.rb#L53
        #
        # For vagrant-libvirt WaitTillUp is used
        def register(hook)
          setup_logging

          registered = false
          if virtual_box?
            hook.after(VagrantPlugins::ProviderVirtualBox::Action::WaitForCommunicator,
                        VagrantPlugins::Registration::Action.action_register)
            registered = true
          end
          if libvirt?
            hook.after(VagrantPlugins::ProviderLibvirt::Action::WaitTillUp,
                      VagrantPlugins::Registration::Action.action_register)
            registered = true
          end
          # Best guess for the other providers
          unless registered
            hook.after(Vagrant::Action::Builtin::WaitForCommunicator,
                      VagrantPlugins::Registration::Action.action_register)
          end
        end

        def unregister_on_halt(hook)
          setup_logging
          hook.prepend(VagrantPlugins::Registration::Action.action_unregister_on_halt)
        end

        def unregister_on_destroy(hook)
          setup_logging
          hook.prepend(VagrantPlugins::Registration::Action.action_unregister_on_destroy)
        end
      end

      name 'Registration'
      description <<-DESC
      This plugin adds register and unregister functionality to Vagrant Guests that
      support the capability
      DESC

      action_hook(:registration_register, :machine_action_up, &method(:register))
      action_hook(:registration_register, :machine_action_provision, &method(:register))
      action_hook(:registration_unregister_on_halt, :machine_action_halt, &method(:unregister_on_halt))
      action_hook(:registration_unregister_on_destroy, :machine_action_destroy, &method(:unregister_on_destroy))

      config(:registration) do
        setup_logging
        require_relative 'config'
        Config
      end

      # This sets up our log level to be whatever VAGRANT_LOG is
      # for loggers prepended with 'vagrant_registration'
      def self.setup_logging
        require 'log4r'
        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end
        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil unless level.is_a?(Integer)
        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new('vagrant_registration')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end

      # Determines if VirtualBox is provider
      def self.virtual_box?
        defined?(VagrantPlugins::ProviderVirtualBox::Provider)
      end

      # Determines if LibVirt is provider
      def self.libvirt?
        defined?(VagrantPlugins::ProviderLibvirt::Provider)
      end
    end
  end
end
