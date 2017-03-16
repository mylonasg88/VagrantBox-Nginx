# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base Box
  # --------------------
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "nginx-devbox.dev"

  # Connect to IP
  # Note: Use an IP that doesn't conflict with any OS's DHCP (Below is a safe bet)
  # --------------------
  config.vm.network :private_network, ip: "10.0.0.20"

  # Forward to Port
  # --------------------
  config.vm.network :forwarded_port, guest: 3306, host: 3306, auto_correct: true
  config.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true

  # Optional (Remove if desired)
  # --------------------
  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", 1024,             # How much RAM to give the VM (in MB)
      "--cpus", 1,                 # Muli-core in the VM
      "--ioapic", "on",
      "--natdnshostresolver1", "on",
      "--natdnsproxy1", "on"
    ]
  end

  # If true, agent forwarding over SSH connections is enabled
  # --------------------
  config.ssh.forward_agent = true

  # The shell to use when executing SSH commands from Vagrant
  # --------------------
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Synced Folders
  # --------------------
  # config.vm.synced_folder ".", "/vagrant/", :mount_options => [ "dmode=777", "fmode=666" ]
  config.vm.synced_folder ".", "/var/www/devbox", :mount_options => [ "dmode=777", "fmode=666" ]
  config.vm.synced_folder "./html", "/var/www/html", :mount_options => [ "dmode=777", "fmode=666" ]
  config.vm.synced_folder "./vhosts", "/var/www/vhosts", :mount_options => [ "dmode=777", "fmode=666" ]

  # Provisioning Scripts
  # --------------------
  config.vm.provision "shell", path: "./VagrantFiles/init.sh", name: "Installation"
  #config.vm.provision :shell, inline: "sleep 10; service postgresql restart;"
  #config.vm.provision :shell, inline: "service mysql restart;"
  config.vm.provision :shell, inline: "service nginx restart;", run: "always"
  config.vm.provision :shell, path: "./VagrantFiles/finish.sh", run: "always", name: "Finish"
end

Vagrant.configure("2") do |config|
    config.vm.provision "shell", path: "./VagrantFiles/finish.sh", name: "Finish"
end

#Set virtual domains
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false
end

Vagrant.configure("2") do |config|
  config.vm.network "forwarded_port", guest: 80, host: 8080
end
