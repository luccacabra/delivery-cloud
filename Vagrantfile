# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

controller_count = 3
workers_count = 3

controllers = []
workers = []
loadbalancers = []


# these are convenience arrays used to make ansible'ing unit files easier
controller_ips = []
etcd_ips = []
etcd_hosts = []

vars = YAML::load(File.open("group_vars/all"))

encryption_key = ""
use_encryption = false
use_cri_containerd = false

# encryption only supported after v1.7.0
if Gem::Version.new(vars["kubernetes_version"]) >= Gem::Version.new('1.7.0')
  if File.exist?(".encryption_key")
    encryption_key = `cat .encryption_key`
  else
    encryption_key = `head -c 32 /dev/urandom | base64`
    File.open(".encryption_key", "w") {|f| f.write("#{encryption_key}") }
  end
  use_encryption = true
end

# cri containerd only supported after v1.9.0
if Gem::Version.new(vars["kubernetes_version"]) >= Gem::Version.new('1.9.0')
  use_cri_containerd = true
end

# grap ips outside of vagrant block to ensure they're available for provisioning
(2..controller_count + 1).each do |controller|
  controller_ips << "10.0.0.#{controller}"
  etcd_ips << "kubes-controller#{controller}=https://10.0.0.#{controller}:2380"
  etcd_hosts << "https://10.0.0.#{controller}:2379"
end

Vagrant.configure("2") do |config|

  # controllers
  (2..controller_count + 1).each do |machine|
    config.vm.define "kubes-controller#{machine}" do |node|
      node.vm.hostname = "kubes-controller#{machine}"
      node.vm.box = "debian/jessie64"
      node.vm.network "private_network", ip: "10.0.0.#{machine}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubes-controller#{machine}"
        vb.customize ["modifyvm", :id, "--memory", 1280]

        configure_performance(vb)
      end

      controllers << "kubes-controller#{machine}"
    end
  end

  # workers
  (1..workers_count).each do |machine|
    config.vm.define "kubes-worker#{machine}" do |node|
      node.vm.hostname = "kubes-worker#{machine}"
      node.vm.box = "debian/jessie64"
      node.vm.network "private_network", ip: "10.0.0.1#{machine}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubes-worker#{machine}"
        vb.customize ["modifyvm", :id, "--memory", 2048]

        configure_performance(vb)
      end

      workers << "kubes-worker#{machine}"
    end
  end

  # loadbalancer
  config.vm.define "kubes-loadbalancer" do |node|
    node.vm.hostname = "kubes-loadbalancer"
    node.vm.box = "debian/jessie64"
    node.vm.network "private_network", ip: vars["public_ip"]

    node.vm.provider "virtualbox" do |vb|
      vb.name = "kubes-loadbalancer"

      configure_performance(vb)
    end

    loadbalancers << "kubes-loadbalancer"
  end

  config.ssh.insert_key = false
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "site.yml"
    ansible.extra_vars  = {
      "use_encryption" =>use_encryption,
      "encryption_key" => encryption_key,
      "use_cri_containerd" => use_cri_containerd,
      "etcd_ips" => etcd_ips.join(","),
      "controller_ips" => controller_ips.join(","),
      "apiserver_count" => controller_count,
      "etcd_hosts" => etcd_hosts.join(",")
    }
    ansible.groups = {
        "controllers" => controllers,
        "workers" => workers,
        "loadbalancers" => loadbalancers
    }
  end
end

def configure_performance(vb)
  # https://www.mkwd.net/improve-vagrant-performance/
  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  vb.customize ["modifyvm", :id, "--ioapic", "on"]
end