# Certificate generation for Teleport demo

Certificate generation tools producing certificates for Teleport demo, to be executed manually.

## Prerequisites

- [Terraform](https://www.terraform.io/)
- [CertBot](https://certbot.eff.org/)
- `openssl`
- Cloud provider credentials. Currently: [Scaleway](https://console.scaleway.com/)

## CertBot usage

[LetsEncrypt](https://letsencrypt.org/getting-started/) CertBot is used to generate web certificates with which to access the Teleport UI at (e.g.) https://teleport.thinkahead.dev . These are validated using a DNS challenge.

1. Install [CertBot](https://certbot.eff.org/).
1. Run `./certbot.sh`
    - This will run CertBot on your local machine.
    - CertBot will request you to create a DNS value. This can be done by running `terraform` in the `certbot/letsencrypt/` subdirectory in a separate terminal window.
    - Once the DNS value is deployed, continue with LetsEncrypt.
    - When LetsEncrypt has generated a certificate, the script will run `terraform` to deploy these in cloud provider secret resources.
- _Note_: You can update the domains requested by modifying:
    - [certbot.sh](./certbot.sh); and
    - [proxy.tf](./certbot/letsencrypt/proxy.tf).

## Self-signed certificate usage

Basic `openssl` is used to generate self-signed certificates for internal use by Teleport:
- a root certificate authority; and
- a leaf certificate for the Teleport Access Graph.

1. Run `./selfsigned.sh`
1. Apply `terraform` in this directory to deploy these secrets to cloud providers.