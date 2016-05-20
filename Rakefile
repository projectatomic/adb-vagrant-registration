require 'bundler/gem_tasks'
require 'rake/clean'
require 'cucumber/rake/task'
require 'yard'
require 'rubygems/comparator'
require 'launchy'
require 'mechanize'
require 'fileutils'

CLOBBER.include('pkg')
CLEAN.include('build')

# Documentation
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'plugins/**/*.rb']
  t.options = []
  t.stats_options = ['--list-undoc']
end

task :init do
  FileUtils.mkdir_p 'build'
end

# Cucumber acceptance test tasks
Cucumber::Rake::Task.new(:features)
task :features => :init

namespace :features do
  desc 'Opens the HTML Cucumber test report'
  task :open_report do
    Launchy.open('./build/features_report.html')
  end
end

# Compare latest release with current git head
task compare: [:clean, :build] do
  git_version = VagrantPlugins::Registration::VERSION
  options = {}
  options[:output] = 'pkg'
  options[:keep_all] = true
  comparator = Gem::Comparator.new(options)
  comparator.compare_versions('vagrant-registration', ['_', git_version])
  comparator.print_results
end

desc 'Download CDK Vagrant box using the specified provider (default \'virtualbox\')'
task :get_cdk, [:provider] do |t, args|
  provider = args[:provider].nil? ? 'virtualbox' : args[:provider]
  agent = Mechanize.new
  agent.follow_meta_refresh = true
  agent.get(CDK_DOWNLOAD_URL) do |page|

    # Submit first form which is the redirect to login page form
    login_page = page.forms.first.submit

    # Submit the login form
    after_login = login_page.form_with(:name => 'login_form') do |f|
      username_field = f.field_with(:id => 'username')
      username_field.value = 'service-manager@mailinator.com'
      password_field = f.field_with(:id => 'password')
      password_field.value = 'service-manager'
    end.click_button

    # There is one more redirect after successful login
    download_page = after_login.forms.first.submit

    download_page.links.each do |link|
      if link.href =~ /#{Regexp.quote(CDK_BOX_BASE_NAME)}-#{Regexp.quote(provider)}.box/
        download_dir = File.join(File.dirname(__FILE__), 'build', 'boxes')
        unless File.directory?(download_dir)
          FileUtils.mkdir_p(download_dir)
        end
        agent.pluggable_parser.default = Mechanize::Download
        puts "Downloading #{link.href}"
        agent.get(link.href).save(File.join(download_dir, "cdk-#{provider}.box"))
      end
    end
  end
end
task :get_cdk => :init
