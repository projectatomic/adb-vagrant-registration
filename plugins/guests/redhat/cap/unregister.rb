module VagrantPlugins
  module GuestRedHat
    module Cap
      class Unregister
        def self.unregister(machine)
          begin
            if machine.communicate.ready?
              machine.communicate.execute("subscription-manager unregister || :", sudo: true)             
            end
          end
        end
      end
    end
  end
end


            # if !machine.communicate.ready?
            #   raise Vagrant::Errors::VMNotCreatedError
            # end
            
#          rescue IOError
          # Ignore, this probably means connection closed because it
          # shut down.
