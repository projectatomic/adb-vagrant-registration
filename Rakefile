require 'bundler/gem_tasks'
require 'yard'

# Documentation
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'plugins/**/*.rb']
  t.options = []
  t.stats_options = ['--list-undoc']
end

task :clean do
  `rm -rf pkg`
end

# Compare latest release with current git head
require 'rubygems/comparator'
task compare: [:clean, :build] do
  git_version = VagrantPlugins::Registration::VERSION
  options = {}
  options[:output] = 'pkg'
  options[:keep_all] = true
  comparator = Gem::Comparator.new(options)
  comparator.compare_versions('vagrant-registration', ['_', git_version])
  comparator.print_results
end
