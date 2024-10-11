# teleport-demo

Think Ahead Technologies demonstration environment for [Teleport](https://goteleport.com/) security software.

Read our [article](https://think-ahead.tech/en/teleport-demo-env) on this repository!

## Dependencies & tools

- Teleport license
- Cloud account credentials
    - currently supported: combination of [Scaleway](https://www.scaleway.com/) _and_ [Azure](https://azure.microsoft.com/)
- HashiCorp [Terraform](https://www.hashicorp.com/products/terraform)
- (Optional) [Kubernetes] and [FluxCD](https://fluxcd.io/)
- [GitHub Actions](https://github.com/features/actions)

## Usage

Use GitHub Actions pipelines to [deploy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-instances-deploy.yml) or [destroy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-instances-destroy.yml) the demo environment using Scaleway **instances**.

Use similar Actions to [deploy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-k8s-deploy.yml) or [destroy](https://github.com/think-ahead-technologies/teleport-demo/actions/workflows/scw-k8s-destroy.yml) the demo environment on **Kubernetes**, also on Scaleway.
- This will also create a Kubernetes cluster to deploy onto.

Both deployment types will create a cluster at [https://teleport.thinkahead.dev/](https://teleport.thinkahead.dev/web/login).
- Both will deploy Teleport Access Graph if available, using a PostgreSQL database set up on Microsoft Azure for the purpose
    - You may need to run a few manual steps to set up the database for the TAG. If the final pipeline step fails, check the Terraform output for details of what to run.
- Both approaches will store and share secrets via Scaleway Secret Manager
