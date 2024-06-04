#!/bin/bash -e

# This utility script pushes the current versions of the *.teleport-conf.yaml.tftpl
#  files to the auth and proxy servers, for convenience.
# It requires direct SSH access to the servers, without going via Teleport.

cd $(dirname $0)

PROXY_IP_FILE=proxy-ip.tmp
AUTH_IP_FILE=auth-ip.tmp
REMOTE_USER=root
SSH_TIMEOUT=3

if [ ! -s proxy-ip.tmp ] || [ ! -s auth-ip.tmp ]; then
    echo "Retrieving Teleport server IP files..." >&2
    terraform init
    terraform output -raw proxy-ip >$PROXY_IP_FILE
    terraform output -raw auth-ip >$AUTH_IP_FILE
fi

export proxy_server_ip=$(cat $PROXY_IP_FILE)
export auth_server_ip=$(cat $AUTH_IP_FILE)
envsubst <proxy.teleport-conf.yaml.tftpl >proxy.teleport-conf.yaml.tmp
envsubst <auth.teleport-conf.yaml.tftpl >auth.teleport-conf.yaml.tmp

echo "Copying config file to proxy machine on $proxy_server_ip..." >&2
scp -o ConnectTimeout=$SSH_TIMEOUT proxy.teleport-conf.yaml.tmp $REMOTE_USER@$proxy_server_ip:/etc/teleport.yaml \
    || (rm $PROXY_IP_FILE && false)
echo "Copying config file to auth server on $auth_server_ip..." >&2
scp -o ConnectTimeout=$SSH_TIMEOUT auth.teleport-conf.yaml.tmp $REMOTE_USER@$auth_server_ip:/etc/teleport.yaml \
    || (rm $AUTH_IP_FILE && false)

echo "Restarting Teleport on proxy machine..." >&2
ssh -o ConnectTimeout=$SSH_TIMEOUT $REMOTE_USER@$proxy_server_ip "systemctl restart teleport"
echo "Restarting Teleport on auth server..." >&2
ssh -o ConnectTimeout=$SSH_TIMEOUT $REMOTE_USER@$auth_server_ip "systemctl restart teleport"