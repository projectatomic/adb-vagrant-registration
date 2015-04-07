require "vagrant"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)
      # The username to subscribe with (required)
      #
      # @return [String]
      attr_accessor :subscriber_username

      # The password of the subscriber (required)
      #
      # @return [String]
      attr_accessor :subscriber_password

      # Give the hostname of the subscription service to use (required for Subscription
      # Asset Manager, defaults to Customer Portal Subscription Management)
      #
      # @return [String]
      attr_accessor :serverurl

      # Give the hostname of the content delivery server to use to receive updates
      # (required for Satellite 6)
      #
      # @return [String]
      attr_accessor :baseurl

      # Give the organization to which to join the system (required, except for
      # hosted environments)
      #
      # @return [String]
      attr_accessor :org

      # Register the system to an environment within an organization (optional)
      #
      # @return [String]
      attr_accessor :environment

      # Name of the subscribed system (optional, defaults to hostname if unset)
      #
      # @return [String]
      attr_accessor :name

      # Auto attach suitable subscriptions (optional, auto attach if true)
      #
      # @return [Bool]
      attr_accessor :auto_attach

      # Attach existing subscriptions as part of the registration process (optional)
      #
      # @return [String]
      attr_accessor :activationkey

      # Set the service level to use for subscriptions on that machine
      # (optional, used only used with the --auto-attach)
      #
      # @return [String]
      attr_accessor :servicelevel

      # Set the operating system minor release to use for subscriptions for
      # the system (optional, used only used with the --auto-attach)
      #
      # @return [String]
      attr_accessor :release

      # Force the registration (optional, force if true, defaults to true)
      #
      # @return [Bool]
      attr_accessor :force

      # Set what type of consumer is being registered (optional, defaults to system)
      #
      # @return [String]
      attr_accessor :type

      # Skip the registration (optional, skip if true, defaults to false)
      #
      # @return [Bool]
      attr_accessor :skip

      def initialize(region_specific=false)
        @subscriber_username = UNSET_VALUE
        @subscriber_password = UNSET_VALUE
        @serverurl = UNSET_VALUE
        @baseurl = UNSET_VALUE
        @org = UNSET_VALUE
        @environment = UNSET_VALUE
        @name = UNSET_VALUE
        @auto_attach = true
        @activationkey = UNSET_VALUE
        @servicelevel = UNSET_VALUE
        @release = UNSET_VALUE
        @force = true
        @type = UNSET_VALUE
        @skip = UNSET_VALUE
      end

      def finalize!
        @subscriber_username = nil if @subscriber_username == UNSET_VALUE
        @subscriber_password = nil if @subscriber_password == UNSET_VALUE
        @serverurl = nil if @serverurl = UNSET_VALUE
        @baseurl = nil if @baseurl = UNSET_VALUE
        @org = nil if @org = UNSET_VALUE
        @environment = nil if @environment = UNSET_VALUE
        @name = nil if @name == UNSET_VALUE
        @auto_attach = true if @auto_attach == UNSET_VALUE
        @activationkey = nil if @activationkey = UNSET_VALUE
        @servicelevel = nil if @servicelevel = UNSET_VALUE
        @release = nil if @release = UNSET_VALUE
        @force = true if @force == UNSET_VALUE
        @type = nil if @type == UNSET_VALUE
        @skip = false if @skip == UNSET_VALUE
      end
    end
  end
end
