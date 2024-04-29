#!/bin/bash

# Define variables
SSL_FOLDER="ssl-files"

# Generate a new private key (rootCA.key) with a length of 2048 bits
openssl genrsa -out $SSL_FOLDER/rootCA.key 2048

# Create a self-signed X.509 certificate (rootCA.crt) for the root CA using the private key (rootCA.key)
# Set the validity period to 365 days and use SHA256 for the signature algorithm
openssl req -x509 -new -nodes -key $SSL_FOLDER/rootCA.key -sha256 -days 365 -out $SSL_FOLDER/rootCA.crt -config openssl.conf

# Generate a new private key (mydomain.key) with a length of 2048 bits
openssl genrsa -out $SSL_FOLDER/mydomain.key 2048

# Create a new certificate signing request (mydomain.csr) using the private key (mydomain.key)
openssl req -new -key $SSL_FOLDER/mydomain.key -out $SSL_FOLDER/mydomain.csr -config openssl.conf

# Sign the CSR using the root CA certificate (rootCA.crt) and private key (rootCA.key)
# Set the validity period to 365 days and use SHA256 for the signature algorithm
openssl x509 \
  -req -in $SSL_FOLDER/mydomain.csr \
  -CA $SSL_FOLDER/rootCA.crt \
  -CAkey $SSL_FOLDER/rootCA.key \
  -CAcreateserial \
  -out $SSL_FOLDER/mydomain.crt \
  -days 365 \
  -sha256 \
  -extensions req_ext \
  -extfile openssl.conf

openssl pkcs12 \
  -export -out $SSL_FOLDER/mydomain.pfx \
  -inkey $SSL_FOLDER/mydomain.key \
  -in $SSL_FOLDER/mydomain.crt \
  -certfile $SSL_FOLDER/rootCA.crt \
  -passin pass:password \
  -passout pass:password

# View the contents of the signed certificate to verify the information
# openssl x509 -in mydomain.com.crt -text -noout