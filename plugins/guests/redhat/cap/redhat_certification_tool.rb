module VagrantPlugins
  module GuestRedHat
    module Cap
      class RedHatCertification
        def self.rhcert(machine)
          machine.communicate.test("/usr/bin/rhcert", sudo: true)
        end
      end
    end
  end
end
