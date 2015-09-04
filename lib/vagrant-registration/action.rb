module VagrantPlugins
  module Registration
    module Action

      def self.action_register
        Vagrant::Action::Builder.new.tap do |b|
          b.use Register
        end
      end

      def self.action_unregister_on_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use UnregisterOnHalt
        end
      end

      def self.action_unregister_on_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use UnregisterOnDestroy
        end
      end

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Register, action_root.join("register")
      autoload :UnregisterOnHalt, action_root.join("unregister_on_halt")
      autoload :UnregisterOnDestroy, action_root.join("unregister_on_destroy")
    end
  end
end
