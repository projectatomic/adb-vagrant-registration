$:.push(File.expand_path('../../plugins', __FILE__))
$:.push(File.expand_path('../../lib', __FILE__))

require 'bundler/setup'

require 'vagrant-registration'
require 'guests/redhat/cap/subscription_manager'
require 'guests/redhat/cap/rhn_register'

require 'minitest/autorun'
require 'mocha/mini_test'

require_relative 'support/fake_ui.rb'

def fake_environment(options = { enabled: true })
  { machine: fake_machine(options), ui: FakeUI }
end

class RecordingCommunicator
  attr_reader :commands, :responses

  def initialize
    @commands = Hash.new([])
    @responses = Hash.new('')
  end

  def stub_command(command, response)
    responses[command] = response
  end

  def sudo(command)
    #puts "SUDO: #{command}"
    commands[:sudo] << command
    responses[command]
  end

  def execute(command)
    #puts "EXECUTE: #{command}"
    commands[:execute] << command
    responses[command].split("\n").each do |line|
      yield(:stdout, "#{line}\n")
    end
  end

  def test(command)
    commands[:test] << command
    true
  end

  def ready?
    true
  end
end

module Registration
  class FakeProvider
    def initialize(*args)
    end

    def _initialize(*args)
    end

    def ssh_info
    end

    def state
      @state ||= Vagrant::MachineState.new('fake-state', 'fake-state', 'fake-state')
    end
  end
end

module Registration
  class FakeConfig
    def registration
      @registration_config ||= VagrantPlugins::Registration::Config.new
    end

    def vm
      VagrantPlugins::Kernel_V2::VMConfig.new
    end
  end
end

def fake_machine(options={})
  env = options.fetch(:env, Vagrant::Environment.new)
  machine = Vagrant::Machine.new(
      'fake_machine',
      'fake_provider',
      Registration::FakeProvider,
      'provider_config',
      {},                          # provider_options
      env.vagrantfile.config,      # config
      Pathname('data_dir'),
      'box',
      options.fetch(:env, Vagrant::Environment.new),
      env.vagrantfile
  )

  machine.instance_variable_set("@communicator", RecordingCommunicator.new)
  machine.config.vm.hostname = options.fetch(:hostname, 'somehost.vagrant.test')
  machine
end

module MiniTest
  class Spec
    alias_method :hush, :capture_io
  end
end






