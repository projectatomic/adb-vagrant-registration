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

      # Skip the registration (skip if true)
      #
      # @return [Bool]
      attr_accessor :skip

      # Force the registration (force if true)
      #
      # @return [Bool]
      attr_accessor :force

      # Auto attach suitable subscriptions (auto attach if true)
      #
      # @return [Bool]
      attr_accessor :auto_attach

      # Name of the subscribed system (optional, defaults to hostname if unset)
      #
      # @return [String]
      attr_accessor :name

      def initialize(region_specific=false)
        @subscriber_username = UNSET_VALUE
        @subscriber_password = UNSET_VALUE
        @skip = UNSET_VALUE
        @force = true
        @auto_attach = true
        @name = UNSET_VALUE
      end

      def finalize!
        @subscriber_username = nil if @subscriber_username == UNSET_VALUE
        @subscriber_password = nil if @subscriber_password == UNSET_VALUE
        @skip = false if @skip == UNSET_VALUE
        @force = true if @force == UNSET_VALUE
        @auto_attach = true if @auto_attach == UNSET_VALUE
        @name = nil if @name == UNSET_VALUE
      end
    end
  end
end
