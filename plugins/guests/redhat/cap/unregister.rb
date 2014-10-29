module VagrantPlugins
  module GuestRedHat
    module Cap
      class Unregister
        def self.unregister(machine)
          begin
             machine.communicate.execute("subscription-manager unregister || :", sudo: true)
          rescue IOError
          # Ignore, this probably means connection closed because it
          # shut down.
          end
        end
      end
    end
  end
end
