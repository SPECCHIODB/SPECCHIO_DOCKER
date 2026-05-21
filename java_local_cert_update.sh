#!/bin/bash

# script to fetch the self signed certificate to have proper https access 
# when running localhost

# run the docker-compose first. This will generate a local cert for https access
# then run this script to copy the cert into your java so that it is trusted

###### JAVA LOCATION VARIABLE
# Point this to the base directory of the JDK you want to configure

JAVA_HOME_DIR="/home/leschwe/Downloads/jdk-26" # <-------------CHANGE THIS LINE!!!

# Define internal keytool and cacerts paths based on standard JDK architecture
KEYTOOL_BIN="$JAVA_HOME_DIR/bin/keytool"
CACERTS_STORE="$JAVA_HOME_DIR/lib/security/cacerts"
CERT_SOURCE="/home/leschwe/Documents/Github/SPECCHIO_DOCKER/v2/compose/clean_install/nginx/ssl/server.crt"
ALIAS_NAME="specchio-local"
STORE_PASS="changeit"

echo "=== Starting SPECCHIO SSL Keystore Provisioning ==="

# Validation checks
if [ ! -f "$KEYTOOL_BIN" ]; then
    echo "ERROR: keytool binary not found at $KEYTOOL_BIN"
    exit 1
fi

if [ ! -f "$CACERTS_STORE" ]; then
    echo "ERROR: cacerts keystore file not found at $CACERTS_STORE"
    exit 1
fi

if [ ! -f "$CERT_SOURCE" ]; then
    echo "ERROR: Nginx server.crt not found at $CERT_SOURCE."
    echo "Please ensure docker-compose is running and has generated the files."
    exit 1
fi

# 1. remove old cert if there is one in java
echo "Checking for existing certificate under alias '$ALIAS_NAME'..."
"$KEYTOOL_BIN" -list -keystore "$CACERTS_STORE" -storepass "$STORE_PASS" -alias "$ALIAS_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Old certificate found. Removing it from keystore..."
    sudo "$KEYTOOL_BIN" -delete -alias "$ALIAS_NAME" -keystore "$CACERTS_STORE" -storepass "$STORE_PASS"
    echo "Old certificate removed successfully."
else
    echo "No old certificate found matching alias '$ALIAS_NAME'. Skipping deletion step."
fi

# 2. copy the new cert
echo "Importing new Java-compliant certificate into keystore..."
sudo "$KEYTOOL_BIN" -importcert -trustcacerts -alias "$ALIAS_NAME" -file "$CERT_SOURCE" -keystore "$CACERTS_STORE" -storepass "$STORE_PASS" -noprompt

if [ $? -eq 0 ]; then
    echo "=== SUCCESS: Certificate successfully linked and trusted! ==="
else
    echo "ERROR: Failed to import the certificate."
    exit 1
fi