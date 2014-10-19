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
        @logger = Log4r::Logger.new("vagrant_register::plugin::setup")
      end

      class << self
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_register::action::subscribe")
        end

        def subscribe(hook)
          @logger.info("in subscribe hook")
          hook.after(::Vagrant::Action::Builtin::ConfigValidate, VagrantPlugins::Registration::Action.subscribe)
        end

        def unsubscribe(hook)
          @logger.info("in unsubscribe hook")
          hook.before(::Vagrant::Action::Builtin::Halt, VagrantPlugins::Registration::Action.unsubscribe)
        end

      end

      name "Registration"
      description <<-DESC
      This plugin adds subscribe and unsubscribe functionality to Vagrant Guests that 
      support the capability
      DESC

      @logger.info("attempting to register hooks on #{@machine.name}")
      action_hook(:registration_subscribe, :machine_action_reload, &method(:subscribe))

      action_hook(:registration_unsubscribe, :machine_action_halt, &method(:unsubscribe))

      config(:registration) do
        Config
      end

    end
  end
end

