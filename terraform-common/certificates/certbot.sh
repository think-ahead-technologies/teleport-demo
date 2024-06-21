#!/usr/bin/env bash -e

# This script generates a LetsEncrypt-signed certificate for Teleport domains.

cd certbot

echo "Running CertBot. Please open a new tab to apply Terraform" >&2
echo " in the 'certbot/letsencrypt' subdirectory if/when the DNS" >&2
echo " challenge is provided." >&2

certbot certonly --manual --preferred-challenges dns \
    -d "teleport.thinkahead.dev" \
    -d "*.teleport.thinkahead.dev" \
    --config-dir letsencrypt \
    --work-dir letsencrypt \
    --logs-dir letsencrypt \
    --email teleport-on-prem@think-ahead.tech

echo "Pushing the CertBot certificates to cloud providers..." >&2
terraform init
terraform apply