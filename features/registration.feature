Feature: Booting VM with various registration settings

  Scenario Outline: Boot VirtualBox with and without vbguest additions plugin
    Given provider is virtualbox
    And a file named "Vagrantfile" with:
    """
    <require>
    Vagrant.configure(2) do |config|
      config.vm.box = 'cdk'
      config.vm.box_url = 'file://../boxes/cdk-virtualbox.box'
      config.registration.username = 'service-manager@mailinator.com'
      config.registration.password = 'service-manager'
    end
    """

    When I successfully run `bundle exec vagrant up --provider virtualbox`
    Then vbguest additions <expectation> be installed

    Examples:
      | require                    | expectation |
      | # no require               | should not  |
      | require 'vagrant-vbguest'  | should      |


  Scenario Outline: Test invalid registration credentials
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
      config.registration.username = 'foo'
      config.registration.password = 'bar'
      config.vm.synced_folder '.', '/vagrant', disabled: true
    end
    """

    When I run `bundle exec vagrant up --provider <provider>`
    Then startup should fail with invalid credentials error

    Examples:
      | provider   |
      | virtualbox |
      | libvirt    |


  Scenario Outline: Test skipping registration
    And provider is <provider>
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
      config.registration.skip = true
      config.vm.synced_folder '.', '/vagrant', disabled: true
    end
    """

    When I run `bundle exec vagrant up --provider <provider>`
    Then registration should not be successful

    Examples:
      | provider   |
      | virtualbox |
      | libvirt    |

  Scenario Outline: Test successful registration
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
      config.registration.username = 'service-manager@mailinator.com'
      config.registration.password = 'service-manager'
      config.vm.synced_folder '.', '/vagrant', disabled: true
    end
    """

    When I run `bundle exec vagrant up --provider <provider>`
    Then registration should be successful

    Examples:
      | provider   |
      | virtualbox |
      | libvirt    |
