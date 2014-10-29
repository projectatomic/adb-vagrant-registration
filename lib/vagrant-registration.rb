require "pathname"

require "vagrant-registration/plugin"

module VagrantPlugins
  module Registration
    lib_path = Pathname.new(File.expand_path("../vagrant-registration", __FILE__))
    autoload :Action, lib_path.join("action")
    #autoload :Errors, lib_path.join("errors")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end

    # Temporally load the extra capability files for Red Hat
    load(File.join(self.source_root, 'plugins/guests/redhat/plugin.rb'))
  end
end
