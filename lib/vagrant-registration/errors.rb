require "vagrant"

module VagrantPlugins
  module Registration
    module Errors
      class VagrantRHELError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_registration.errors")
      end

      class RegisterError < VagrantRegistrationError
        error_key(:register)
      end

      class UnregisterError < VagrantRegistrationError
        error_key(:unregister)
      end
    end
  end
end
