require 'test_helper'

describe VagrantPlugins::GuestRedHat::Cap::SubscriptionManager do
  let(:machine) { fake_machine }

  describe 'register' do
    it 'calls without extra config subscription-manager register with default options' do
      VagrantPlugins::GuestRedHat::Cap::SubscriptionManager.subscription_manager_register(machine, FakeUI)

      # RecordingCommunicator keeps track of the commands executed
      assert_equal(1, machine.communicate.commands[:sudo].length, 'there should be only one recorded sudo command')
      registration_command = machine.communicate.commands[:sudo][0]
      assert_match(/subscription-manager register/, registration_command, 'subscription-manager register should have been called')
    end

    it 'passes username and password to subscription-manager as specified via Vagrant config' do
      machine.config.registration.username = 'foo'
      machine.config.registration.password = 'bar'

      VagrantPlugins::GuestRedHat::Cap::SubscriptionManager.subscription_manager_register(machine, FakeUI)

      # RecordingCommunicator keeps track of the commands executed
      assert_equal(1, machine.communicate.commands[:sudo].length, 'there should be only one recorded sudo command')
      registration_command = machine.communicate.commands[:sudo][0]
      assert_match(/subscription-manager register/, registration_command, 'subscription-manager register should have been called')
      assert_match(/--username='foo'/, registration_command, 'the username should have been set')
      assert_match(/--password='bar'/, registration_command, 'the password should have been set')
    end
  end
end

