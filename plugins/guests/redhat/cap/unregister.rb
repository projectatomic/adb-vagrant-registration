module VagrantPlugins
  module GuestRedHat
    module Cap
      class Unregister
        def self.unregister(machine)
          machine.communicate.execute("subscription-manager unregister || :", sudo: true)
        end
      end
    end
  end
end
