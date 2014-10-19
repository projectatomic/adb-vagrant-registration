require "vagrant"

module VagrantPlugins
  module Registration
    module Errors
      class VagrantRHELError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_registration.errors")
      end

      class SubscribeError < VagrantRegistrationError
        error_key(:subscribe)
      end

      class UnsubscribeError < VagrantRegistrationError
        error_key(:unsubscribe)
      end
    end
  end
end
