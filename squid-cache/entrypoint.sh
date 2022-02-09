#!/bin/sh
set -e

echo "Checking certificate..."
SSL_CERT_FILE="/apps/ssl_cert/server.pem"
OPENSSL_CONFIG_FILE="/apps/openssl.conf"
if [[ ! -f ${SSL_CERT_FILE} ]]; then
    echo "No certificate file found. Initializing new certificate..."

    openssl req -new -newkey rsa:2048 -sha256 -days 365 \
                -nodes -x509 -extensions v3_ca -keyout ${SSL_CERT_FILE} \
                -out ${SSL_CERT_FILE} \
                -config ${OPENSSL_CONFIG_FILE} -subj "/C=US/ST=CA/L=San Francisco/O=Dis/CN=www.example.com"
else
    echo "Found existing certificate at ${SSL_CERT_FILE}"
fi

echo "Initializing cache..."
/apps/squid/sbin/squid -N -f /apps/squid.conf -z

echo "Starting Squid..."
exec /apps/squid/sbin/squid -NYC -f /apps/squid.conf
