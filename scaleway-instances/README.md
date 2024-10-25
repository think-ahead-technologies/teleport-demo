## scaleway-instances

Terraform and Teleport code allowing deployment of a demo cluster on Scaleway compute instances

### Prerequisites
- [database](/terraform-common/database/) stack deployed
- Scaleway and Azure credentials

### Contents
This directory contains Terraform code to deploy a Teleport auth and proxy server, plus [auth](/scaleway-instances/auth.teleport-conf.yaml.tftpl) and [proxy](/scaleway-instances/proxy.teleport-conf.yaml.tftpl) configuration files which will be set up on the machines via [userdata](/scaleway-instances/vm.userdata.sh.tftpl). A [Teleport Access Graph](/scaleway-instances/tag.tf) server will also be set up, with its own [config](/scaleway-instances/tag.teleport-conf.yaml.tftpl) and [userdata](/scaleway-instances/tag.userdata.sh.tftpl).

Teleport configuration for further authentication - via Azure SAML or via GitHub Actions pipelines - is set up according to the [config files](/scaleway-instances/teleport/).

### Usage

The main way to deploy this is to use the GitHub Actions [deploy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-instances-deploy.yml) pipeline.

However, you can also deploy locally using Terraform, with credentials and commands described in [scaleway-k8s](/scaleway-k8s/README.md#local-deployment).