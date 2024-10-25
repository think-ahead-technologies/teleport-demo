# teleport-demo

Think Ahead Technologies demonstration environment for [Teleport](https://goteleport.com/) security software.

Read our [article](https://think-ahead.tech/en/teleport-demo-env) on this repository!

## Dependencies & tools

- Teleport license
- Cloud account credentials
    - currently supported: combination of [Scaleway](https://www.scaleway.com/) _and_ [Azure](https://azure.microsoft.com/)
- HashiCorp [Terraform](https://www.hashicorp.com/products/terraform)
- (Optional) [Kubernetes](https://kubernetes.io/) and [FluxCD](https://fluxcd.io/)
- [GitHub Actions](https://github.com/features/actions)

## Usage

There are two deployment styles, both of which create a cluster at [https://teleport.thinkahead.dev/](https://teleport.thinkahead.dev/).
- Both approaches will store and share secrets via Scaleway [Secret Manager](https://console.scaleway.com/secret-manager/)
- Both will be set up for login with Azure Active Directory
    - NB This required manual setup (see [tutorial](https://goteleport.com/docs/admin-guides/access-controls/sso/azuread/) and resulting [config file](/scaleway-instances/teleport/azure-connector.yaml))
- Both will create a handful of '[target](/terraform-common/teleport-targets/)' resources accessible through Teleport once logged in

#### With Scaleway instances
To deploy a demo environment running on Scaleway Computer instances, run the GitHub Actions [deploy instances](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-instances-deploy.yml) or [destroy instances](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-instances-destroy.yml) pipelines.

You will need to have created web certificates before running this. See [certificates/](/terraform-common/certificates/) for more information.

#### With Kubernetes on Scaleway
To create a Scaleway Kapsule Kubernetes cluster and install Teleport on it, run the GitHub Actions [deploy Kubernetes](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-k8s-deploy.yml) or [destroy Kubernetes](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-k8s-destroy.yml) pipelines.

These will create a cluster with self-signed web certificates. These take some minutes to generate.

#### Teleport Access Graph
- Teleport Access Graph is partly supported:  if available, using a PostgreSQL database set up on Microsoft Azure for the purpose
    - You may need to run a few manual steps to set up the database for the TAG. If the final pipeline step fails, check the Terraform output for details of what to run.
