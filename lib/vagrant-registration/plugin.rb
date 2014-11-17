# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.2.0"
  raise "The Vagrant RHEL plugin is only compatible with Vagrant 1.2+"
end

module VagrantPlugins
  module Registration
    class Plugin < Vagrant.plugin("2")
      def initialize(app, env)
        @app    = app
      end

      class << self
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::plugin")
        end

        def register(hook)
          @logger.info("in register hook")
          hook.after(::Vagrant::Action::Builtin::ConfigValidate, 
                     VagrantPlugins::Registration::Action.action_register)
        end

        def unregister(hook)
          @logger.info("in unregister hook")
          hook.prepend(VagrantPlugins::Registration::Action.action_unregister)
        end

        def unregister_on_destroy(hook)
          @logger.info("in unregister_on_destroy hook")
          hook.after(::Vagrant::Action::Builtin::ConfigValidate, 
                     VagrantPlugins::Registration::Action.action_unregister)
        end

      end

      name "Registration"
      description <<-DESC
      This plugin adds register and unregister functionality to Vagrant Guests that 
      support the capability
      DESC

      @logger = Log4r::Logger.new("vagrant_register::plugin::setup")
      @logger.info("attempting to register hooks on up")
      action_hook(:registration_register, :machine_action_up, &method(:register))

      @logger.info("attempting to register hooks on halt")
      action_hook(:registration_unregister, :machine_action_halt, &method(:unregister))

      @logger.info("attempting to register hooks on destroy")
      action_hook(:registration_unregister, :machine_action_destroy, &method(:unregister_on_destroy))

      config(:registration) do
        require_relative 'config'
        Config
      end

    end
  end
end

