# End-to-end example for Azure Application Gateway

This module repository includes an example. The setup for the example includes:

- Resource group (default name is `testing`)
- Networks and security groups
- Consul cluster - choose from...
  - (Default) [HCP Consul on Azure](https://learn.hashicorp.com/tutorials/cloud/consul-client-azure-virtual-machines?in=consul/cloud-production)
  - Consul server on a virtual machine (not a secure configuration)
- API virtual machine (with Consul client)
- Web virtual machine (with Consul client)

> Note: This example is not a reflection of a production configuration. Its
> purpose is to help you test this module for your configurations.

## Setup

1. Go into the `examples/setup/` directory.
   ```shell
   $ cd examples/setup
   ```

1. Generate an SSH key so you can log into the machine under the `./.ssh`
   directory.
   ```shell
   $ ssh-keygen -t rsa -f ./.ssh/id_rsa
   ```

1. Set the following environment variables so you can run the configuration.
   Your Azure AD service principal must have sufficient API
   permissions (`Application.ReadWrite.All`) because it creates a service principal
   for network peering.
   ```shell
   export ARM_CLIENT_SECRET=""
   export ARM_CLIENT_ID=""
   export ARM_TENANT_ID=""
   export ARM_SUBSCRIPTION_ID=""
   ```

1. Apply the Terraform configuration. This creates a resource group, two
   subnets, a testing Consul server, and two virtual machines called `web` and
   `api`.
  ```shell
  $ terraform apply
  ```

## Run CTS

1. Go back up to `examples/`.
   ```shell
   $ cd ..
   ```

1. You'll notice that you have a few files under `examples/`, which represent
   the different CTS configurations you can use.
   ```shell
   $ ls cts-*
   cts-config-basic.hcl     cts-config-path.hcl      cts-example-basic.tfvars cts-example-path.tfvars
   ```

1. Run CTS and pass the configuration file of your choice. You
   can choose between basic and path-based routing. The configuration locally
   references the application gateway module to synchronizes `web` and `api`
   services to an application gateway.
   ```shell
   $ consul-terraform-sync -config-file cts-config-<basic|path>.hcl
   ```

## Cleanup

1. Check you are in the `examples/` directory.

1. Go to `sync-tasks/testing`.
   ```shell
   cd sync-tasks/testing
   ```

1. Delete resources created by CTS.
   ```shell
   ../../terraform destroy -auto-approve
   ```

1. Delete resources in the example.
   ```shell
   cd ../../setup && terraform destroy -auto-approve
   ```