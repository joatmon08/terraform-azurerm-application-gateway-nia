enable_path_based_routing = false

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
      host_names = "[\"api.cts.hashicorp.com\"]"
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
      host_names   = "[\"web.cts.hashicorp.com\",\"*.web.cts.hashicorp.com\"]"
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
      host_names   = "[\"web.cts.hashicorp.com\",\"*.web.cts.hashicorp.com\"]"
      probe_enable = true
    }
  }
}
