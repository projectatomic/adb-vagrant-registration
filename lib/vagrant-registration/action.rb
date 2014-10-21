module VagrantPlugins
  module Registration
    module Action

      def self.action_register
        Vagrant::Action::Builder.new.tap do |b|
          b.use Register
        end
      end

      def self.action_unregister
        Vagrant::Action::Builder.new.tap do |b|
          b.use Unregister
        end
      end

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Register, action_root.join("register")
      autoload :Unregister, action_root.join("unregister")
    end
  end
end
