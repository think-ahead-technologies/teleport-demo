#!/bin/bash -e

# This hacky script retrieves the cluster host CA certificate for
#  the Teleport Access Graph, as it isn't supported to natively
#  retrieve this within the TAG Helm chart.

domain=${1:-teleport.thinkahead.dev}
secret_id=${2#*/} # remove the region from the start of the secret `id` attribute
region=$3
MAX_ATTEMPTS=600

SCALEWAY_REGION=fr-par

url=https://$domain/webapi/auth/export?type=tls-host
echo "Waiting to retrieve host CA certificate from: $url"

attempts=0

cert=
while [ -z "$cert" ]; do
    cert=$(curl "$url" 2>/dev/null || true)
    attempts=$(( $attempts + 1 ))
    if [ $attempts -gt $MAX_ATTEMPTS ]; then
        echo "Error: timed out after $MAX_ATTEMPTS attempts" >&2
        exit 127
    fi
    sleep 1
done

echo "Retrieved cluster host certificate. Pushing to Scaleway secret $secret_id..."
http_code=$(curl "https://api.scaleway.com/secret-manager/v1beta1/regions/$region/secrets/$secret_id/versions" \
  -s -o /dev/null -w "%{http_code}" \
  -H "X-Auth-Token: $TF_VAR_SCW_SECRET_KEY" \
  -d "{\"data\":\"$(echo -n "$cert" | base64)\"}")

if [ "$http_code" -lt 200 ] || [ "$http_code" -ge 300 ]; then
    echo "Failed to push secret: received HTTP $http_code" >&2
    exit 1
fi
