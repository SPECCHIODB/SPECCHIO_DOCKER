# 1. Base on latest stable Ubuntu LTS
# -> latest tag is latest LTS!
FROM ubuntu:latest

# Prevent interactive installer prompts
ENV DEBIAN_FRONTEND=noninteractive

# 2. Update OS and install OpenJDK 8 along with web utilities
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 3. Download and install GlassFish 4.1
RUN wget https://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip \
    && unzip glassfish-4.1.zip -d /opt \
    && rm glassfish-4.1.zip

# Set up global environment paths
ENV GLASSFISH_HOME=/opt/glassfish4
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# 4. Hardcode proxy trust settings inside GlassFish on build
# This makes GlassFish trust the secure HTTPS headers sent by Nginx

RUN asadmin start-domain && \
    until asadmin list-domains | grep -q "domain1 running"; do echo "Waiting for GlassFish..." && sleep 2; done && \
    # 1. Enable proxy header support
    asadmin create-jvm-options "-Dglassfish.grizzly.authPassthroughEnabled=true" && \
    # 2. Update admin password from blank to 'admin' (required for secure admin)
    echo "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=admin" > /tmp/pwd.txt && \
    asadmin --user admin --passwordfile /tmp/pwd.txt change-admin-password && \
    rm /tmp/pwd.txt && \
    # 3. Create a credential file so enable-secure-admin can authenticate instantly
    echo "AS_ADMIN_PASSWORD=admin" > /tmp/auth.txt && \
    asadmin --user admin --passwordfile /tmp/auth.txt enable-secure-admin && \
    rm /tmp/auth.txt && \
    # 4. Clean shutdown to save configuration
    asadmin stop-domain

# Keep the container running in the foreground so Docker can manage its lifecycle
CMD ["asadmin", "start-domain", "-w"]

# 5. Move your latest webapp build into the autodeploy location
# 5. Download, extract, and copy your latest webapp build from Jenkins
RUN wget --no-check-certificate https://jenkins.specchio.ch/job/SPECCHIO/lastBuild/artifact/src/webapp/build/distributions/specchio-webapp.zip \
    && unzip specchio-webapp.zip \
    && cp ./specchio-webapp/webapp-*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/ \
    && rm -rf specchio-webapp.zip specchio-webapp



# 6. Expose the standard web port internally 
# (This stays hidden inside the docker network, Nginx routes traffic here)
EXPOSE 8080

# 7. Start the server in the foreground so the container stays alive
CMD ["asadmin", "start-domain", "--verbose"]