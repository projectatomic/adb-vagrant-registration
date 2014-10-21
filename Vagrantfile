# BEING USED FOR TESTING, REMOVE BEFORE RELEASE
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Example configuration of new VM..
  config.vm.define :default do |vagrant_host|
    # Box name
    vagrant_host.vm.box = 'rhel-7.0'
    
    # Domain Specific Options
    vagrant_host.vm.provider :libvirt do |domain|
      domain.memory = 2048
      domain.cpus = 1
    end

    config.vm.synced_folder './', '/vagrant', type: 'rsync'

#    vagrant_host.vm.network :private_network,
#        :libvirt__network_name => 'either_nat'

  end
  
  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbook.yml"
  #   ansible.extra_vars = "vagrant-config.yml"
  # end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbook.yml"
  #   ansible.extra_vars = "vagrant-config.yml"
  #   ansible.sudo = "true"
  # end
  
  # Options for libvirt vagrant provider.
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = 'kvm'
    libvirt.connect_via_ssh = false
    libvirt.username = 'root'
    libvirt.storage_pool_name = 'mnt_vms'
  end
end

