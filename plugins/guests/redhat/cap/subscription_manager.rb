module VagrantPlugins
  module GuestRedHat
    module Cap
      class SubscriptionManager
        def self.subscription_manager(machine)
           machine.communicate.test("/sbin/subscription-manager", sudo: true)
        end
      end
    end
  end
end
