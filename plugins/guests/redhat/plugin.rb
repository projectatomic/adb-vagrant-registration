require "vagrant"

module VagrantPlugins
  module GuestRedHat
    class Plugin < Vagrant.plugin("2")
      guest_capability("redhat", "register") do
        require_relative "cap/register"
        Cap::Register
      end

      guest_capability("redhat", "unregister") do
        require_relative "cap/unregister"
        Cap::Unregister
      end

      guest_capability("redhat", "subscription_manager") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end
    end
  end
end
