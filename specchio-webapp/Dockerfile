# Get latest glassfish (now managed by eclipse...)
FROM ghcr.io/eclipse-ee4j/glassfish:latest

# Switch user to root for permissions
USER root

# install wget and unzip for following actions
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Get zip from build server
RUN wget -P /tmp https://jenkins.specchio.ch/job/SPECCHIO/lastSuccessfulBuild/artifact/src/webapp/build/distributions/specchio-webapp.zip

# create folder to save specchio webapp, this needs to be used in the compse

RUN mkdir -p /deploy

RUN unzip /tmp/specchio-webapp.zip -d /tmp 

RUN cp /tmp/specchio-webapp/*.war /deploy/


# Remove zipped file 
RUN rm /tmp/specchio-webapp.zip
RUN rm -r /tmp/specchio-webapp

# Switch back to the default glassfish user 
USER glassfish

EXPOSE 8080 4848