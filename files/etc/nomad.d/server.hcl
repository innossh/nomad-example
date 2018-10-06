bind_addr = "0.0.0.0"
datacenter = "dc1"
name = "nomad"
data_dir  = "/var/lib/nomad"

advertise {
  http = "192.168.33.10"
  rpc  = "192.168.33.10"
  serf = "192.168.33.10"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled       = true
  network_interface = "eth0"
}

consul {
  address = "127.0.0.1:8500"
}
