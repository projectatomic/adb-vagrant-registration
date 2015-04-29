require "vagrant"

module VagrantPlugins
  module GuestRedHat
    class Plugin < Vagrant.plugin("2")
      guest_capability("redhat", "registration_register") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "registration_unregister") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "registration_manager_installed") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "registration_credentials") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "registration_secrets") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "registration_manager") do
        require_relative "cap/registration"
        Cap::Registration
      end

      guest_capability("redhat", "subscription_manager") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end

      guest_capability("redhat", "subscription_manager_register") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end

      guest_capability("redhat", "subscription_manager_unregister") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end

      guest_capability("redhat", "subscription_manager_credentials") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end

      guest_capability("redhat", "subscription_manager_secrets") do
        require_relative "cap/subscription_manager"
        Cap::SubscriptionManager
      end

      guest_capability("redhat", "rhcert") do
        require_relative "cap/redhat_certification_tool"
        Cap::RedHatCertification
      end
    end
  end
end
