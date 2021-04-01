enable_path_based_routing = true
frontend_port             = 80
sku_name                  = "Standard_Small"
sku_tier                  = "Standard"

backend_certificates = {
  api = [{
    name = "api"
    data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUV6akNDQXJZQ0NRRHJzOTBRbTNNdDJEQU5CZ2txaGtpRzl3MEJBUXNGQURBcE1Rc3dDUVlEVlFRR0V3SlYKVXpFYU1CZ0dBMVVFQXd3UlkzUnpMbWhoYzJocFkyOXljQzVqYjIwd0hoY05Nakl3TVRBMU1UZ3hORE01V2hjTgpNak13TVRBMU1UZ3hORE01V2pBcE1Rc3dDUVlEVlFRR0V3SlZVekVhTUJnR0ExVUVBd3dSWTNSekxtaGhjMmhwClkyOXljQzVqYjIwd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUUN4Z3dYY2ZzZHUKREQxOFlSbVM0NHRmSWl6Zk9VYkdCa1ROWHFkWEdodmo1RHNVNlpiZENqZm9sTENYZTB1c2xJVjVaQjgyVTEzbQpTNWp5SHBVUU1sUThiaEpWekh3QWF1dUEwUjRlYzFSVUhYZGRHZmNORG9JRm9ZVDZ6OXZGeFo5Q0NwY0NwcVhNCmtWSmdia1ZIZkNRUUdaMUd3QnI1WGdpN3J1NnVXMUhkY0draUpDMEtweEw2eGFXTUNtd0RJdktQRVJhbFJrS0wKbUU4RWQyYm9vaXRvUU1wZG5acEhoakVBY213NEEwaVhsUlRiV3pvd1h2TFE3UjZnTGtvdjhWNzB6MEZFZWphbgpLZGY2NW5YTS90WldDbE1Ed1pTcU92S2hVeGdCUW1TTWN6Z2J3TkxueVpKMk5Md0NLNjhxREhhU3RsdjRRNldZCkM0azFVbmFJR2g3UTFvdUEyTVQzNnRVMk14ZTF0T1RTTWJrSTlSdEhDaEhyZGdqRTNhVkRDQkQvMTVlUGpzbnQKM3RvWGw0UDM1ejdQZ21SNzljcS9MUDJmVUliU2V3YXZrUm9zQXFwekRYYmdXMjhoNkIwMDRCRXVNblVITWlyVwpJMGVacHhPYTVQdVJnTmZFT01MQXlMbjVwMVRoc00vWG1DSk9IbW5sTWVIdWF1NnU3T1p2WVRhZGNVKzNGc0NhCnpMY3J6RVo1MFkyTG5BMHVCUTYvMVBIM0FTbmxMMm9DMytrR0JjeHhYYnd4bFl2RFJSMHp4czBEQytHeVgwZ08KcWMvVHRsSFhPaDhkM1J3L3NpNTVEY2ZhS084a3Z0bndqV2tjTGJZRXBJS0JSS0trVXVuTVhIYWp5NTU1TnpTYQp5ZFJnSytoR0pNS1BNTGxIcW1rL1hVbElWN25BVmFTNG5RSURBUUFCTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElDCkFRQS9tUmJBSnNlelZyNFRGSzVrVlZxbjF6RDhkL2p3Mnd5VE0yaDJmMkp5TUU0MnZmK3FLZ0MzNU92VngvQnIKSjRETHBZa0NDQ1QyK2VzYmZHMDN6YTVoWlM2dEt2VWY3NUlrVFlibXhEVWhFTHR0YVhNYzRwYVlzVTJtbGZLYgpVNm9xTVRJK21ra1ZyOGZVMks1OUNZN1lmMmxlZWx1KzZLbVlUa3Q4WXllMWNXb2tMYktpVFdMSzdnL3JEdmJQCjVNZHJxUjRuR2RBN1c4UjVjU1JNcTBVU1NwZ1o5RXlkVVI5UnE4eDRaZFhjeXlmd054THQ0MnlvK0duWWo0cXUKQnV2TEViNE9jRktXU2thaXdMWThzZUtTcFFMZEM2d0RPVVJzMzhCZXFJZ0NrZHRJNmVIZDZHdVUyL3NRVnNJUgpEdGk2NXByaUExUVVHRmg3NzBCYVNGTi8zMmQ2VytVZGV4Vmx5UU9qeHAxTGgyN0dIemtGamZYbUJaMFA2VHRnCkFLSlRuZkVOdWliaFU2ekZMS1E1U3lhaGErV25HOHVLS3BjV21HbHRBWnF1MEplWFdYV2xYQnErZC9kUmdWMnIKRDJWcFpEL1lVOFIzVWZ5MFd5N3RwVWp5bXB6VjBuRDFJcWhHYjNCSURlWmcrV1FnYXlobXFlMTdmaXBKMEtQTwo5TUF6ZDBtemFpYThqam4yVHN2TUV0M0dnRWhhaDlGWEt6alJZY0J2RTVNUWh6Vk1HZHMwWVV2SzVuSmlSV2JjCnMyQUR2U25Hb3ZVMGppeHJwM0ROUytYZ2h2T1daNjJzZU9CQTI0QlJUNFd6U3pvWkM1YlhFUEtjTGxnVUNleWIKRFNZeFYxMjR4b0E0bFltYTBkY3RpV0g3eUF4L0lkMHpKYS9JTmhFQk92YW1wZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  }]
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
      path = "/api/*"
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
