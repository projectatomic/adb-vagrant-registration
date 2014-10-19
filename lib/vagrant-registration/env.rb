require "vagrant"

module VagrantPlugins
  module Registration
    class Config < Vagrant.plugin("2", :config)

      # @return [Vagrant::UI::Colored]
      attr_accessor :ui

      def initialize(region_specific=false)
        vagrant_version = Gem::Version.new(::Vagrant::VERSION)
        if vagrant_version >= Gem::Version.new("1.5")
          @ui = ::Vagrant::UI::Colored.new
          @ui.opts[:target] = 'Registration'
        elsif vagrant_version >= Gem::Version.new("1.2")
          @ui = ::Vagrant::UI::Colored.new.scope('Registration')
        end
      end
    end
  end
end
