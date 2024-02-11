#!/bin/bash

# Remember to keep the private key (domain.key) secure, 
# as it should never be exposed publicly. 
# The PFX file (domain.pfx) can be used in applications
# that require a certificate for TLS 1.2 authentication.

# create the private key
openssl genrsa -out example.com.key 2048

# Create a Certificate Signing Request (CSR)
openssl req -new -key example.com.key -out example.com.csr

# Create self signed certificate
openssl x509 -req -days  365 -in example.com.csr -signkey example.com.key -out example.com.crt

# Convert the Certificate and Private Key to PFX Format
# This command combines the certificate and private 
# key into a single PFX file 
openssl pkcs12 -export -out example.com.pfx -inkey example.com.key -in example.com.crt
