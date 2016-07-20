require 'pathname'
require 'vagrant-registration/plugin'

module VagrantPlugins
  module Registration
    lib_path = Pathname.new(File.expand_path('../vagrant-registration', __FILE__))
    autoload :Action, lib_path.join('action')

    # This returns the path to the source of this plugin.
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    # Temporally load the extra capability files for Red Hat
    load(File.join(source_root, 'plugins/guests/redhat/plugin.rb'))
    # Default I18n to load the en locale
    I18n.load_path << File.expand_path('locales/en.yml', source_root)
  end
end
