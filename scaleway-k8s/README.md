## scaleway-k8s

Terraform, Teleport, Kubernetes and [Flux](https://fluxcd.io/) code allowing deployment of a demo cluster on Scaleway managed Kubernetes

### Prerequisites
- [database](/terraform-common/database/) stack deployed
- Scaleway and Azure credentials

### Usage

The main way to deploy this is to use the GitHub Actions [deploy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-k8s-deploy.yml) pipeline.

#### Local deployment

You can also deploy locally using Terraform.

Terraform is [set up](/scaleway-instances/provider.tf) to store state on Scaleway S3 Compatible Object Storage. To deploy locally, you will need Scaleway credentials (including your [project ID](https://console.scaleway.com/project/settings) and [organisation ID](https://console.scaleway.com/organization/settings)) available in your environment, plus AWS aliases so Terraform knows how to access the state objects.

You will also need Azure credentials to setup a [firewall rule](/scaleway-instances/db.tf) allowing the Teleport Access Graph server access to the database created [elsewhere](/terraform-common/database/).
```
# Scaleway provider
export TF_VAR_SCW_ACCESS_KEY=<...>
export TF_VAR_SCW_SECRET_KEY=<...>
export TF_VAR_SCW_DEFAULT_ORGANISATION_ID=<...>
export TF_VAR_SCW_DEFAULT_PROJECT_ID=<...>

# State access
export AWS_ACCESS_KEY_ID=$TF_VAR_SCW_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=TF_VAR_SCW_SECRET_KEY

# Azure provider, for TAG database
export TF_VAR_ARM_CLIENT_ID=<...>
export TF_VAR_ARM_CLIENT_SECRET=<...>
export TF_VAR_ARM_SUBSCRIPTION_ID=<...>
export TF_VAR_ARM_TENANT_ID=<...>
```

#### Deployment
With these credentials in your environment, you can deploy the stack as usual:
```
terraform init
terraform plan >scaleway-instances.tfplan
terraform apply scaleway-instances.tfplan
```

#### Deployment order

With these credentials in environment variables, deploy the stacks in the following order:
1. [database](/terraform-common/database/) for Teleport Access Graph
1. Kubernetes [cluster](/scaleway-k8s/terraform-cluster/)
1. [flux](/scaleway-k8s/terraform-flux/) configuration, referencing [flux-config](/scaleway-k8s/flux-config/)
1. Cross-stack [secrets](/scaleway-k8s/terraform-secrets/)
1. (Optional) [extra resources](/terraform-common/teleport-targets/)