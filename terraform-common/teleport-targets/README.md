# Extra Teleport resources

A small collection of resources that can be deployed and accessed via the Teleport demo proxy. Requires manual setup.

## Prerequisites
- `terraform`, an Infrastructure as Code tool [by HashiCorp](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
- `tctl` and `tsh`, the [Teleport CLI tools](https://goteleport.com/docs/installation/)
- `az`, the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

### Deployment on Kubernetes
1. Run 'Deploy kubernetes demo' pipeline. It should fail at the final step, deploying these resources.
1. Wait for the Teleport service to be avaiilable.
1. Log in on the CLI.
    - `tsh login --proxy=teleport.thinkahead.dev --auth=ad`
1. Add [bot tokens](/scaleway-instances/teleport/) for GitHub Actions to run scripts
    - `cd scaleway-instances/teleport` (from the repo root)
    - `tctl create bot.yaml`
    - `tctl create bot-token.yaml`
    - `tctl create github-repo-role.yaml`
1. (Optional) Rerun the failed step of the 'deploy' pipeline.
1. Run terraform manually within [this directory](/terraform-common/teleport-targets/).
    - `make tokens`
    - `terraform init`
    - `terraform apply`
    - NB This must be run on the same machine as the next step, to create a firewall rule allowing you network access to the database.
1. Run the commands output in the `terraform output psql-create-role-script`:
    - generate an ActiveDirectory access token with `az account get-access-token`
    - use that token to log into the demo Azure Postgresql database
    - create an ActiveDirectory role to allow Teleport to access the database
1. Log into Teleport at [teleport.thinkahead.dev](https://teleport.thinkahead.dev/).
    - You should see a Scaleway instance under Resources
    - You should also see the above database too, and be able to access it.
        - the command for this can be found in the Teleport UI, or the above `terraform output`.