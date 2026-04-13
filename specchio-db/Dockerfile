FROM mysql:latest

# init vars (can be overwritten in the compose!)
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=specchio_db
ENV MYSQL_USER=specchio_user
ENV MYSQL_PASSWORD=specchio_password


# copy sql scripts to init-folder of container
# will be executed one afer another at first start
# naming inside DB folder is critical

COPY SPECCHIO_V3.3.4.sql /docker-entrypoint-initdb.d/01_base.sql
COPY specchio_database_upgrade_V3.3.4_V3.3.5.sql /docker-entrypoint-initdb.d/02_upgrade1.sql
COPY specchio_database_upgrade_V3.3.5_V3.3.6.sql /docker-entrypoint-initdb.d/03_upgrade2.sql
COPY specchio_database_upgrade_V3.3.6_V3.3.7.sql /docker-entrypoint-initdb.d/04_upgrade3.sql


# expose port for webapp to connect 
EXPOSE 3306