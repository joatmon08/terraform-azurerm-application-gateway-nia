enable_path_based_routing = true
frontend_port             = 443

ssl_certificates = {
  api = {
    name                = "api"
    data_file_path      = "fixtures/cts.hashicorp.com.pfx"
    password            = "test"
    key_vault_secret_id = null
  }
}

services = {
  "api" : {
    address         = "172.17.0.1"
    id              = "api"
    name            = "api"
    kind            = ""
    port            = 80
    meta            = {}
    tags            = []
    namespace       = ""
    status          = "passing"
    node_id         = "node_a"
    node            = "foobar"
    node_address    = "192.168.10.10"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan = "192.168.10.10"
      wan = "10.0.10.10"
    }
    node_meta = {}
    cts_user_defined_meta = {
      path                          = "/api/*",
      backend_request_timeout       = "120"
      backend_path                  = "/v1/"
      backend_cookie_based_affinity = "Enabled"
    }
  },
  "web_1" : {
    address = "172.17.0.3"
    id      = "web_1"
    name    = "web"
    kind    = ""
    port    = 5000
    meta = {
      foobar_meta_value = "baz"
    }
    tags            = ["tacos"]
    namespace       = ""
    status          = "passing"
    node_id         = "node_a"
    node            = "foobar"
    node_address    = "192.168.10.10"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan = "192.168.10.10"
      wan = "10.0.10.10"
    }
    node_meta = {
      somekey = "somevalue"
    }
    cts_user_defined_meta = {
      path         = "/web/*"
      probe_enable = true
    }
  },
  "web_2" : {
    address = "172.17.0.4"
    id      = "web_2"
    name    = "web"
    kind    = ""
    port    = 5000
    meta = {
      foobar_meta_value = "baz"
    }
    tags            = ["burrito"]
    namespace       = ""
    status          = "passing"
    node_id         = "node_b"
    node            = "foobarbaz"
    node_address    = "192.168.10.11"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan = "192.168.10.11"
      wan = "10.0.10.10"
    }
    node_meta = {}
    cts_user_defined_meta = {
      path         = "/web/*",
      probe_enable = true
    }
  }
}
