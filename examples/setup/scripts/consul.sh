#!/bin/bash

sudo apt-get update
sudo apt-get install curl -y

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && apt install -y consul=${CONSUL_VERSION}-1 unzip

local_ip=`ip -o route get to 169.254.169.254 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
mkdir -p /etc/consul.d/certs

cat > /etc/consul.d/certs/consul-agent-ca.pem <<- EOF
${CA_PUBLIC_KEY}
EOF

cat > /etc/consul.d/certs/server-cert.pem <<- EOF
${SERVER_PUBLIC_KEY}
EOF

cat > /etc/consul.d/certs/server-key.pem <<- EOF
${SERVER_PRIVATE_KEY}
EOF

# Modify the default consul.hcl file
cat > /etc/consul.d/consul.hcl <<- EOF
data_dir = "/opt/consul"

client_addr = "0.0.0.0"

ui_config {
  enabled = true
}

acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens = {
    master = "${BOOTSTRAP_TOKEN}"
    agent = "${BOOTSTRAP_TOKEN}"
  }
}

server = true

bind_addr = "0.0.0.0"

advertise_addr = "$local_ip"

bootstrap_expect=1

encrypt = "${GOSSIP_KEY}"

verify_incoming = true

verify_outgoing = true

verify_server_hostname = true

ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"

cert_file = "/etc/consul.d/certs/server-cert.pem"

key_file = "/etc/consul.d/certs/server-key.pem"

ports {
  grpc = 8502
}

connect {
  enabled = true
}

config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"
      config {
        protocol = "http"
      }
    }
  ]
}
EOF

touch /etc/consul.d/consul.env
mkdir /opt/consul
sudo chown -R consul:consul /opt/consul

# Start Consul
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul