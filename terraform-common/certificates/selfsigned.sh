#!/usr/bin/env bash -e

# This script generates a self-signed root CA plus
#  subordinate certificates for the Teleport Access Graph

# NB 'step' (Smallstep) provides an alternative, simpler approach to certificate generation.

CA_NAME=ca
DOMAIN_KEYPAIR_NAME=tag

function gen_ca() {
    echo "Generating root CA key..."
    openssl req -nodes -newkey rsa:4096 -keyout $CA_NAME.key \
        -subj "/C=DE/ST=BW/L=Stuttgart/O=Think Ahead Technologies/OU=DevOps/"
    echo "Generating root CA certificate..."
    openssl req -x509 -new -key $CA_NAME.key -sha256 -days 3652 -out $CA_NAME.crt -subj '/CN=root'
}

function gen_domain_keys() {
    echo "Generating Teleport Access Graph signing request..."
    openssl req -new \
        -out $DOMAIN_KEYPAIR_NAME.csr -newkey rsa:4096 -nodes -keyout $DOMAIN_KEYPAIR_NAME.key \
        -subj '/CN=Teleport Access Graph'
    echo "Generating Teleport Access Graph certificate..."
    openssl x509 -req -in $DOMAIN_KEYPAIR_NAME.csr \
        -out $DOMAIN_KEYPAIR_NAME.crt -days 3652 -sha256 \
        -CA $CA_NAME.crt -CAkey $CA_NAME.key -CAcreateserial \
        -extfile <(echo """
            extendedKeyUsage = serverAuth, clientAuth
            subjectAltName = @alt_names
            [alt_names]
            DNS.1 = teleport-access-graph.thinkahead.dev
            DNS.2 = teleport-access-graph.teleport-access-graph.svc.cluster.local
        """)
    echo "Certificates for $DOMAIN_KEYPAIR_NAME issued successfully"
}

gen_ca
gen_domain_keys
