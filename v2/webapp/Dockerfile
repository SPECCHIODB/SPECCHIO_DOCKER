# 1. Base on stable Ubuntu LTS
FROM ubuntu:22.04

# Prevent interactive installer prompts
ENV DEBIAN_FRONTEND=noninteractive

# 2. Update OS and install OpenJDK 8 along with web utilities
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 3. Download and install GlassFish 4.1
RUN wget http://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip \
    && unzip glassfish-4.1.zip -d /opt \
    && rm glassfish-4.1.zip

# Set up global environment paths
ENV GLASSFISH_HOME=/opt/glassfish4
ENV PATH=$PATH:$GLASSFISH_HOME/bin

# 4. Hardcode proxy trust settings inside GlassFish on build
# This makes GlassFish trust the secure HTTPS headers sent by Nginx
RUN asadmin start-domain && \
    asadmin set server-config.network-config.protocols.protocol.http-listener-1.http.auth-passthrough-enabled=true && \
    asadmin stop-domain

# 5. Move your latest webapp build into the autodeploy location
# 5. Download, extract, and copy your latest webapp build from Jenkins
RUN wget --no-check-certificate https://jenkins.specchio.ch/job/SPECCHIO/lastBuild/artifact/src/webapp/build/distributions/specchio-webapp.zip \
    && unzip specchio-webapp.zip \
    && cp ./specchio-webapp/webapp-*.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/ \
    && rm -rf specchio-webapp.zip specchio-webapp

COPY ./latest-webapp.war $GLASSFISH_HOME/glassfish/domains/domain1/autodeploy/

# 6. Expose the standard web port internally 
# (This stays hidden inside the docker network, Nginx routes traffic here)
EXPOSE 8080

# 7. Start the server in the foreground so the container stays alive
CMD ["asadmin", "start-domain", "--verbose"]