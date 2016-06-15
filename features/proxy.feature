Feature: Booting VM with various proxy settings

  @needs-proxy
  Scenario Outline: Test valid proxy configuration
    Given provider is <provider>
    And a file named "Vagrantfile" with:
    """
    begin
      require 'vagrant-libvirt'
    rescue LoadError
      # NOOP
    end

    Vagrant.configure(2) do |config|
      config.vm.box = 'cdk'
      config.vm.box_url = 'file://../boxes/cdk-<provider>.box'
      config.vm.network :private_network, ip: '10.10.10.123'
      config.vm.synced_folder '.', '/vagrant', disabled: true

      config.registration.username = 'service-manager@mailinator.com'
      config.registration.password = 'service-manager'
      config.registration.proxy = '10.10.10.1:8888'
      config.registration.proxyUser = 'validUser'
      config.registration.proxyPassword = '<password>'
    end
    """

    When I run `bundle exec vagrant up --provider <provider>`
    Then registration <expectation>

    Examples:
      | provider   | password    | expectation              |
      | virtualbox | validPass   | should be successful     |
      | virtualbox | invalidPass | should not be successful |
      | libvirt    | validPass   | should be successful     |
      | libvirt    | invalidPass | should not be successful |
