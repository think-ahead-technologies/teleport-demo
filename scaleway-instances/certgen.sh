#!/bin/bash -e

if [ ! -d keys ]; then
    mkdir keys
fi

command -v step >/dev/null || (echo "Error: step not installed." >&2 && exit 1)

tag_ip=$(terraform output -raw tag-ip)
dns_name=teleport.thinkahead.dev

echo "Creating root certificate..."
step certificate create --profile root-ca --no-password --insecure --force \
    "Think Ahead Technologies Teleport cluster" keys/ca.crt keys/ca.key

echo "Creating TAG certificate for IP $tag_ip..."
step certificate create $dns_name keys/tag.crt keys/tag.key \
    --no-password --insecure --force \
    --profile leaf --not-after=8760h \
    --san $tag_ip \
    --ca keys/ca.crt --ca-key keys/ca.key --bundle