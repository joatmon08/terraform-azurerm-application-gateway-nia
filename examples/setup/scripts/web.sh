#!/bin/bash

sudo apt-get update
sudo apt-get install curl -y

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && apt install -y consul=${CONSUL_VERSION}-1 unzip

# Install Envoy
curl https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use ${ENVOY_VERSION}
cp /root/.func-e/versions/${ENVOY_VERSION}/bin/envoy /usr/local/bin

# Grab instance IP
local_ip=`ip -o route get to 169.254.169.254 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
mkdir -p /etc/consul.d/certs

cat > /etc/consul.d/certs/consul-agent-ca.pem <<- EOF
${CA_PUBLIC_KEY}
EOF

cat > /etc/consul.d/certs/client-cert.pem <<- EOF
${CLIENT_PUBLIC_KEY}
EOF

cat > /etc/consul.d/certs/client-key.pem <<- EOF
${CLIENT_PRIVATE_KEY}
EOF

# Modify the default consul.hcl file
cat > /etc/consul.d/consul.hcl <<- EOF
data_dir = "/opt/consul"

client_addr = "0.0.0.0"

server = false

bind_addr = "0.0.0.0"

advertise_addr = "$local_ip"

retry_join = ["${CONSUL_SERVER}"]

encrypt = "${GOSSIP_KEY}"

verify_incoming = true

verify_outgoing = true

verify_server_hostname = true

ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"

cert_file = "/etc/consul.d/certs/client-cert.pem"

key_file = "/etc/consul.d/certs/client-key.pem"

acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    default = "${BOOTSTRAP_TOKEN}"
  }
}

ports {
  grpc = 8502
}
EOF

touch /etc/consul.d/consul.env
mkdir /opt/consul
sudo chown -R consul:consul /opt/consul

# Start Consul
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

# Pull down and install Fake Service
curl -LO https://github.com/nicholasjackson/fake-service/releases/download/v0.22.7/fake_service_linux_amd64.zip
unzip fake_service_linux_amd64.zip
mv fake-service /usr/local/bin
chmod +x /usr/local/bin/fake-service

# Fake Service Systemd Unit File
cat > /etc/systemd/system/web.service <<- EOF
[Unit]
Description=WEB
After=syslog.target network.target

[Service]
Environment="MESSAGE=Hello from Web"
Environment="NAME=web"
Environment="LISTEN_ADDR=0.0.0.0:9091"
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload unit files and start the Web
systemctl daemon-reload
systemctl start web

# Consul Config file for our fake Web service
cat > /etc/consul.d/web.hcl <<- EOF
service {
  name = "web"
  port = 9091
  token = "${BOOTSTRAP_TOKEN}"

  check {
    id = "web"
    name = "HTTP API on Port 9091"
    http = "http://localhost:9091/health"
    interval = "30s"
  }
}
EOF

systemctl restart consul