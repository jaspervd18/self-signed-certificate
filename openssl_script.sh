# Generate a new private key (rootCA.key) with a length of 2048 bits
openssl genrsa -out rootCA.key 2048

# Create a self-signed X.509 certificate (rootCA.crt) for the root CA using the private key (rootCA.key)
# Set the validity period to 365 days and use SHA256 for the signature algorithm
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 365 -out rootCA.crt -config openssl.conf

# Generate a new private key (mydomain.com.key) with a length of 2048 bits
openssl genrsa -out mydomain.key 2048

# Create a new certificate signing request (mydomain.com.csr) using the private key (mydomain.com.key)
openssl req -new -key mydomain.key -out mydomain.csr -config openssl.conf


# Sign the CSR using the root CA certificate (rootCA.crt) and private key (rootCA.key)
# Set the validity period to 365 days and use SHA256 for the signature algorithm
openssl x509 \
  -req -in mydomain.csr \
  -CA rootCA.crt \
  -CAkey rootCA.key \
  -CAcreateserial \
  -out mydomain.crt \
  -days 365 \
  -sha256 \
  -extensions req_ext \
  -extfile openssl.conf

openssl pkcs12 -export -out mydomain.pfx -inkey mydomain.key -in mydomain.crt -certfile rootCA.crt -passin pass:password -passout pass:password

# View the contents of the signed certificate to verify the information
# openssl x509 -in mydomain.com.crt -text -noout