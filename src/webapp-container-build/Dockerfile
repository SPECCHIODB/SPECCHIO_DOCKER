# Base on latest stable Ubuntu LTS
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update OS and install OpenJDK 8 along with utilities
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Download and install GlassFish 4.1
RUN wget https://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip \
    && unzip glassfish-4.1.zip -d /opt \
    && rm glassfish-4.1.zip

ENV GLASSFISH_HOME=/opt/glassfish4
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# Add the MySQL Connector (file taken from current GitHub repo)
COPY mysql-connector-java-5.1.47-bin.jar /opt/glassfish4/glassfish/lib/

# Boot domain, apply configurations, and shut down
RUN asadmin start-domain && \
    until asadmin list-domains | grep -q "domain1 running"; do echo "Waiting..." && sleep 2; done && \
    # Proxy Trust settings
    asadmin create-jvm-options "-Dglassfish.grizzly.authPassthroughEnabled=true" && \
    # Set Admin Password from blank to 'admin' #CHANGE?
    echo "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=admin" > /tmp/pwd.txt && \ 
    asadmin --user admin --passwordfile /tmp/pwd.txt change-admin-password && \ 
    rm /tmp/pwd.txt && \
    # Create a reusable authentication file for subsequent commands
    echo "AS_ADMIN_PASSWORD=admin" > /tmp/admin_auth.txt && \
    # Enable Secure Admin
    asadmin --user admin --passwordfile /tmp/admin_auth.txt enable-secure-admin && \


    # Create MySQL Connection Pool
    asadmin --user admin --passwordfile /tmp/admin_auth.txt create-jdbc-connection-pool \
      --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlDataSource \
      --restype javax.sql.DataSource \
      --property user=\${DB_USER}:password=\${DB_PASSWORD}:serverName=database:portNumber=3306:databaseName=\${DB_NAME}:useSSL=false \
      specchio_pool && \
    # Create JNDI Resource (jdbc/specchio)
    asadmin --user admin --passwordfile /tmp/admin_auth.txt create-jdbc-resource --connectionpoolid specchio_pool jdbc/specchio && \
    # Create Security Realm
    asadmin --user admin --passwordfile /tmp/admin_auth.txt create-auth-realm \
      --classname com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm \
      --property jaas-context=jdbcRealm:datasource-jndi=jdbc/specchio:user-table=specchio.specchio_user:user-name-column=user:password-column=password:group-table=specchio.specchio_user_group:group-table-user-name-column=user:group-name-column=group_name:digestrealm-password-enc-algorithm=MD5:digest-algorithm=MD5:db-user=\${DB_USER}:db-password=\${DB_PASSWORD} \
      specchio_realm && \
    asadmin --user admin --passwordfile /tmp/admin_auth.txt set server.security-service.default-realm=specchio_realm && \

    # Clean up and shutdown
    rm /tmp/admin_auth.txt && \
    asadmin stop-domain

# Download and deploy the latest webapp build from Jenkins
RUN wget --no-check-certificate https://jenkins.specchio.ch/job/SPECCHIO/lastBuild/artifact/src/webapp/build/distributions/specchio-webapp.zip \
    && unzip specchio-webapp.zip \
    && cp ./specchio-webapp/webapp-*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/ \
    && rm -rf specchio-webapp.zip specchio-webapp

EXPOSE 8080

# 7. Copy the bootstrap script, make it executable, and set it as the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]