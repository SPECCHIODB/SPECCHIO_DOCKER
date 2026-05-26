#!/bin/sh

# Stop on any error
set -e

DOMAIN_XML="$GLASSFISH_HOME/glassfish/domains/domain1/config/domain.xml"

echo "Inserting live environment variables into domain.xml..."
sed -i "s/\${DB_USER}/$DB_USER/g" "$DOMAIN_XML"
sed -i "s/\${DB_PASSWORD}/$DB_PASSWORD/g" "$DOMAIN_XML"
sed -i "s/\${DB_NAME}/$DB_NAME/g" "$DOMAIN_XML"

echo "Booting GlassFish Server..."
exec asadmin start-domain --verbose