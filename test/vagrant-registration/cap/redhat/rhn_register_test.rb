require_relative '../../../test_helper.rb'

describe VagrantPlugins::GuestRedHat::Cap::RhnRegister do
  let(:machine) { fake_machine }

  describe 'options' do
    it 'supports proxy options' do
      supported_options = VagrantPlugins::GuestRedHat::Cap::RhnRegister.rhn_register_options(machine)
      supported_options.must_include :proxy
      supported_options.must_include :proxyUser
      supported_options.must_include :proxyPassword
    end
  end

  describe 'register' do
    it 'calls rhn_register with default options' do
      VagrantPlugins::GuestRedHat::Cap::RhnRegister.rhn_register_register(machine, FakeUI)

      assert_equal(2, machine.communicate.commands[:sudo].length, 'there should be only one recorded sudo command')
      registration_command = machine.communicate.commands[:sudo][1]
      assert_match(/rhnreg_ks/, registration_command, 'rhnreg_ks should have been called')
    end

    it 'passes username and password to rhn_register as specified via Vagrant config' do
      machine.config.registration.username = 'foo'
      machine.config.registration.password = 'bar'

      VagrantPlugins::GuestRedHat::Cap::RhnRegister.rhn_register_register(machine, FakeUI)

      registration_command = machine.communicate.commands[:sudo][1]
      assert_match(/--username='foo'/, registration_command, 'the username should have been set')
      assert_match(/--password='bar'/, registration_command, 'the password should have been set')
    end
  end

  it 'passes proxy settings to rhn_register as specified via Vagrant config' do
    machine.config.registration.proxy = 'mongo:8080'
    machine.config.registration.proxyUser = 'flash'
    machine.config.registration.proxyPassword = 'zarkov'

    VagrantPlugins::GuestRedHat::Cap::RhnRegister.rhn_register_register(machine, FakeUI)

    registration_command = machine.communicate.commands[:sudo][1]
    assert_match(/--proxy='mongo:8080'/, registration_command, 'the proxy server and port should have been set')
    assert_match(/--proxyUser='flash'/, registration_command, 'the proxy username have been set')
    assert_match(/--proxyPassword='zarkov'/, registration_command, 'the proxy password should have been set')
  end
end

