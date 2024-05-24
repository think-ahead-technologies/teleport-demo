#! /usr/bin/env bash

TOKEN=$(tctl bots add terraform-test --roles=terraform --format=json | jq -r '.token_id')
tbot start \
  --destination-dir=./terraform-identity \
  --token="$TOKEN" \
  --data-dir=./tbot-data \
  --join-method=token \
  --auth-server=think-ahead-cloud.teleport.sh:443
  # Replace with the host and port of your Teleport Auth Service
  # or Teleport Proxy Service
