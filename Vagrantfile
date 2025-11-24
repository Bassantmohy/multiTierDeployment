
Vagrant.configure("2") do |config|

  #database Tier
  config.vm.define "db01" do |db_config|
    db_config.vm.box = "centos/stream9"
    db_config.vm.network "private_network", ip: "192.168.56.15"
    db_config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = 2048
   end
  db_config.vm.provision "shell", path: "db.sh"
 end  

 #memecache Tier
  config.vm.define "mc01" do |mc_config|
    mc_config.vm.box = "centos/stream9"
    mc_config.vm.network "private_network", ip: "192.168.56.14"
    mc_config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = 900
    end
  mc_config.vm.provision "shell", path: "memcache.sh"
 end  

 #messagequeue Tier
  config.vm.define "rmq01" do |rmq_config|
    rmq_config.vm.box = "centos/stream9"
    rmq_config.vm.network "private_network", ip: "192.168.56.13"
    rmq_config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = 600
    end
  rmq_config.vm.provision "shell", path: "rabbitmq.sh"
 end
  #Application Tier
  config.vm.define "app01" do |app_config|
    app_config.vm.box = "centos/stream9"
    app_config.vm.network "private_network", ip: "192.168.56.12"
    app_config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = 2048
    end
  app_config.vm.provision "shell", path: "tomcat.sh"
 end
  #web tier
  config.vm.define "web01" do |web_config|
    web_config.vm.box = "ubuntu/jammy64"
    web_config.vm.network "private_network", ip: "192.168.56.11"
    web_config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = 800
    end
  web_config.vm.provision "shell", path: "nginx.sh"
  
 end
end
