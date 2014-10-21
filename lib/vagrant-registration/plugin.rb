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
        #@logger = Log4r::Logger.new("vagrant_register::plugin::setup")
      end

      class << self
        def initialize(app, env)
          @app    = app
          #@logger = Log4r::Logger.new("vagrant_register::action::register")
        end

        def register(hook)
          @logger.info("in register hook")
          hook.after(::Vagrant::Action::Builtin::ConfigValidate, VagrantPlugins::Registration::Action.register)
        end

        def unregister(hook)
          @logger.info("in unregister hook")
          hook.before(::Vagrant::Action::Builtin::Halt, VagrantPlugins::Registration::Action.unregister)
        end

      end

      name "Registration"
      description <<-DESC
      This plugin adds register and unregister functionality to Vagrant Guests that 
      support the capability
      DESC

      #@logger.info("attempting to register hooks on ")
      action_hook(:registration_register, :machine_action_reload, &method(:register))

      action_hook(:registration_unregister, :machine_action_halt, &method(:unregister))

      config(:registration) do
        Config
      end

    end
  end
end

