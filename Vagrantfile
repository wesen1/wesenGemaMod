Vagrant.configure("2") do |config|

  config.vm.box = "debian/contrib-stretch64"
  config.vm.provision :shell, path: "VagrantProvision.sh"

  # Port forwarding (see https://wiki.cubers.net/action/view/Port_forwarding)
  config.vm.network :forwarded_port, guest: 28763, host: 28763, protocol: "udp"
  config.vm.network :forwarded_port, guest: 28764, host: 28764, protocol: "udp"

end
