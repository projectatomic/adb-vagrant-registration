require 'aruba/cucumber'
require 'komenda'

###############################################################################
# Aruba config and Cucumber hooks
###############################################################################

Aruba.configure do |config|
  config.exit_timeout = 300
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.working_directory = 'build/aruba'
end

Before do |scenario|
  @scenario_name = scenario.name
  ENV['VAGRANT_HOME'] = File.join(File.dirname(__FILE__), '..', '..', 'build', 'vagrant.d')
end

After do |_scenario|
  if File.exist?(File.join(aruba.config.working_directory, 'Vagrantfile'))
    Komenda.run('bundle exec vagrant destroy -f', cwd: aruba.config.working_directory, fail_on_fail: true)
    if ENV.has_key?('CUCUMBER_RUN_PROVIDER')
      # if we have more than one provider we need to wait between scenarios in order to allow for proper cleanup/shutdown
      # of virtualization framework
      sleep 10
    end
  end
end

###############################################################################
# Some shared step definitions
##############################################################################
Given /provider is (.*)/ do |current_provider|
  requested_provider =  ENV.has_key?('PROVIDER') ? ENV['PROVIDER']: 'virtualbox'

  unless requested_provider.include?(current_provider)
    #puts "Skipping scenario '#{@scenario_name}' for provider '#{current_provider}', since this provider is not explicitly enabled via environment variable 'PROVIDER'"
    skip_this_scenario
  end
end

Given /box is (.*)/ do |current_box|
  requested_box =  ENV.has_key?('BOX') ? ENV['BOX']: 'cdk'

  unless requested_box.include?(current_box)
    #puts "Skipping scenario '#{@scenario_name}' for box '#{current_box}', since this box is not explicitly enabled via environment variable 'BOX'"
    skip_this_scenario
  end
end

Then(/^stdout from "([^"]*)" should match \/(.*)\/$/) do |cmd, regexp|
  aruba.command_monitor.find(Aruba.platform.detect_ruby(cmd)).send(:stdout)  =~ /#{regexp}/
end
