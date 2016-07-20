$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'vagrant-registration/version'

Gem::Specification.new do |s|
  s.name          = 'vagrant-registration'
  s.version       = VagrantPlugins::Registration::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'GPL-2.0'
  s.authors       = ['Langdon White', 'Josef Strzibny', 'et al']
  s.email         = ['langdon@fedoraproject.org', 'strzibny@strzibny.name']
  s.summary       = 'Automatic guest registration for Vagrant'
  s.description   = 'Enables guests to be registered automatically which is especially useful for RHEL or SLES guests.'
  s.homepage      = 'https://github.com/projectatomic/adb-vagrant-registration'
  s.required_rubygems_version = '>= 1.3.6'

  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the '!' syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) do
    Dir.glob('lib/**/{*,.*}') +
    Dir.glob('plugins/**/{*,.*}') +
    Dir.glob('locales/**/{*,.*}') +
    Dir.glob('resources/**/{*,.*}') +
    ['Rakefile', 'Gemfile', 'README.md', 'CHANGELOG.md', 'LICENSE.md', 'vagrant-registration.gemspec']
  end
  all_files.reject! { |file| ['.', '..'].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, '.gitignore')
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
      File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  s.files         = unignored_files
  s.executables   = unignored_files.map { |f| f[/^bin\/(.*)/, 1] }.compact
  s.require_path  = 'lib'
end
