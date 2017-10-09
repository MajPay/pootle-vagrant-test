Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"

    # forward http traffic
    config.vm.network "forwarded_port", guest: 80, host: 8041

    config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.cpus = 2
    end

    config.vm.provision "shell", path: "bootstrap.sh"
end