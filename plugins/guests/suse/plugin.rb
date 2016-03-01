require 'vagrant'

module VagrantPlugins
  module GuestSUSE
    class Plugin < Vagrant.plugin('2')
      guest_capability('suse', 'registration_registered?') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_register') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_unregister') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_manager_installed') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_credentials') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_options') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_secrets') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'registration_manager') do
        require_relative 'cap/registration'
        Cap::Registration
      end

      guest_capability('suse', 'rhn_register') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_registered?') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_register') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_unregister') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_credentials') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_options') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end

      guest_capability('suse', 'rhn_register_secrets') do
        require_relative 'cap/rhn_register'
        Cap::RhnRegister
      end
    end
  end
end
