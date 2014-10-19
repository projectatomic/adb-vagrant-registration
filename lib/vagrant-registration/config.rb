require "vagrant"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)
      # The username to subscribe with
      #
      # @return [String]
      attr_accessor :subscriber_username

      # The password of the subscriber
      #
      # @return [String]
      attr_accessor :subscriber_password

      def initialize(region_specific=false)
        @subscriber_username    = UNSET_VALUE
        @subscriber_password    = UNSET_VALUE
      end

      def finalize!
        # Try to get user & pass from environment variables; they
        # will default to nil if the environment variables are not present.
        @subscriber_username = ENV['SUB_USERNAME'] if @subscriber_username == UNSET_VALUE
        @subscriber_password = ENV['SUB_PASSWORD'] if @subscriber_password == UNSET_VALUE
      end
    end
  end
end
