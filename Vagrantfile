# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copied from https://github.com/hashicorp/nomad/tree/v0.8.6/demo/vagrant

$script = <<SCRIPT
# Update apt and get dependencies
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl vim \
    apt-transport-https \
    ca-certificates \
    software-properties-common

# Download Nomad
NOMAD_VERSION=0.8.6

echo "Fetching Nomad..."
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip

echo "Fetching Consul..."
CONSUL_VERSION=1.2.3
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip

echo "Installing Nomad..."
unzip nomad.zip
sudo install nomad /usr/bin/nomad

sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
sudo mkdir -p /var/lib/nomad
sudo chmod a+w /var/lib/nomad

# Set hostname's IP to made advertisement Just Work
#sudo sed -i -e "s/.*nomad.*/$(ip route get 1 | awk '{print $NF;exit}') nomad/" /etc/hosts

echo "Installing Docker..."
if [[ -f /etc/apt/sources.list.d/docker.list ]]; then
    echo "Docker repository already installed; Skipping"
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
fi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce

# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart

# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant

echo "Installing Consul..."
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
sudo mkdir -p /var/lib/consul
sudo chmod a+w /var/lib/consul
(
cat <<-EOF
	[Unit]
	Description=consul agent
	Requires=network-online.target
	After=network-online.target
	
	[Service]
	Restart=on-failure
	ExecStart=/usr/bin/consul agent -config-dir=/vagrant/files/etc/consul.d
	ExecReload=/bin/kill -HUP $MAINPID
	
	[Install]
	WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
sudo systemctl enable consul.service
sudo systemctl start consul

for bin in cfssl cfssl-certinfo cfssljson
do
	echo "Installing $bin..."
	curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
	sudo install /tmp/${bin} /usr/local/bin/${bin}
done

echo "Installing autocomplete..."
nomad -autocomplete-install

echo "Starting nomad..."
(
cat <<-EOF
	[Unit]
	Description=nomad agent
	Requires=network-online.target
	After=network-online.target
	
	[Service]
	Restart=on-failure
	ExecStart=/usr/bin/nomad agent -config=/vagrant/files/etc/nomad.d
	ExecReload=/bin/kill -HUP $MAINPID
	
	[Install]
	WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service
sudo systemctl enable nomad.service
sudo systemctl start nomad

SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
  config.vm.box_version = "201808.24.0"
  config.vm.hostname = "nomad"
  config.vm.provision "shell", inline: $script, privileged: false
  config.vm.provision "docker" # Just install it
  
  config.vm.network "private_network", ip: "10.0.2.15"

  # Expose the nomad api and ui to the host
  config.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true

  # Increase memory for Parallels Desktop
  config.vm.provider "parallels" do |p, o|
    p.memory = "1024"
  end

  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
  end

  # Increase memory for VMware
  ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = "1024"
    end
  end
end
