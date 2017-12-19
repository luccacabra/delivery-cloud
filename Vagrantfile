# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

controllers = []
workers = []
loadbalancers = []


vars = YAML::load(File.open("group_vars/all"))

encryption_key = ""

if File.exists?(".encryption_key")
  encryption_key = `cat .encryption_key`
else
  encryption_key = `head -c 32 /dev/urandom | base64`
  File.open(".encryption_key", "w") {|f| f.write("#{encryption_key}") }
end

Vagrant.configure("2") do |config|

  # controllers
  (2..4).each do |machine|
    config.vm.define "kubes-controller#{machine}" do |node|
      node.vm.hostname = "kubes-controller#{machine}"
      node.vm.box = "ubuntu/precise64"
      node.vm.network "private_network", ip: "10.0.0.#{machine}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubes-controller#{machine}"
        vb.customize ["modifyvm", :id, "--memory", 1280]
      end

      controllers << "kubes-controller#{machine}"
    end
  end

  # workers
  (1..3).each do |machine|
    config.vm.define "kubes-worker#{machine}" do |node|
      node.vm.hostname = "kubes-worker#{machine}"
      node.vm.box = "ubuntu/precise64"
      node.vm.network "private_network", ip: "10.0.0.1#{machine}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubes-worker#{machine}"
        vb.customize ["modifyvm", :id, "--memory", 2048]
      end

      workers << "kubes-worker#{machine}"
    end
  end

  # loadbalancer
  config.vm.define "kubes-loadbalancer" do |node|
    node.vm.hostname = "kubes-loadbalancer"
    node.vm.box = "ubuntu/precise64"
    node.vm.network "private_network", ip: vars["public_ip"]

    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubes-loadbalancer"
    end

    loadbalancers << "kubes-loadbalancer"
  end

  config.ssh.insert_key = false
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "site.yml"
    ansible.extra_vars  = {
      "encryption_key" => encryption_key
    }
    ansible.groups = {
        "controllers" => controllers,
        "workers" => workers,
        "loadbalancers" => loadbalancers
    }
  end
end