# 1. Base on latest stable Ubuntu LTS
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# 2. Update OS and install OpenJDK 8 along with utilities
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 3. Download and install GlassFish 4.1
RUN wget https://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip \
    && unzip glassfish-4.1.zip -d /opt \
    && rm glassfish-4.1.zip

ENV GLASSFISH_HOME=/opt/glassfish4
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# 4. ADD THE MYSQL CONNECTOR (Replaces java_mysql_connector.yml)
COPY mysql-connector-java-5.1.47-bin.jar /opt/glassfish4/glassfish/lib/

# 5. Boot domain, apply configurations, and shut down cleanly
# This replaces domain.xml.j2 and glassfish.yml
RUN asadmin start-domain && \
    until asadmin list-domains | grep -q "domain1 running"; do echo "Waiting..." && sleep 2; done && \
    # Proxy Trust settings
    asadmin create-jvm-options "-Dglassfish.grizzly.authPassthroughEnabled=true" && \
    # Set Admin Password
    echo "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=admin" > /tmp/pwd.txt && \
    asadmin --user admin --passwordfile /tmp/pwd.txt change-admin-password && \
    rm /tmp/pwd.txt && \
    # Enable Secure Admin
    echo "AS_ADMIN_PASSWORD=admin" > /tmp/auth.txt && \
    asadmin --user admin --passwordfile /tmp/auth.txt enable-secure-admin && \
    rm /tmp/auth.txt && \
    # ----------------------------------------------------
    # NEW: REPLACES JINJA2 / DOMAIN.XML CONFIGURATIONS
    # ----------------------------------------------------
    # Create MySQL Connection Pool (Note the database host is 'db')
    asadmin create-jdbc-connection-pool \
      --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlDataSource \
      --restype javax.sql.DataSource \
      --property user=\${DB_USER}:password=\${DB_PASSWORD}:serverName=db:portNumber=3306:databaseName=\${DB_NAME}:Url="jdbc\:mysql\://db\:3306/\${DB_NAME}" \
      specchio_pool && \
    # Create JNDI Resource
    asadmin create-jdbc-resource --poolid specchio_pool jdbc/specchio_jndi && \
    # Create Security Realm
    asadmin create-auth-realm \
      --classname com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm \
      --property jaas-context=jdbcRealm:password-column=password:datasource-jndi=jdbc/specchio_jndi:group-table=user_groups:user-table=users:group-name-column=group_name:digestrealm-password-enc-algorithm=SHA-256:group-table-user-name-column=username:db-password=\${DB_PASSWORD}:digest-algorithm=SHA-256:db-user=\${DB_USER}:user-name-column=username \
      specchio_realm && \
    # ----------------------------------------------------
    asadmin stop-domain

# 6. Download and deploy your latest webapp build from Jenkins
RUN wget --no-check-certificate https://jenkins.specchio.ch/job/SPECCHIO/lastBuild/artifact/src/webapp/build/distributions/specchio-webapp.zip \
    && unzip specchio-webapp.zip \
    && cp ./specchio-webapp/webapp-*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/ \
    && rm -rf specchio-webapp.zip specchio-webapp

EXPOSE 8080

# 7. Start the server in the foreground
CMD ["asadmin", "start-domain", "--verbose"]