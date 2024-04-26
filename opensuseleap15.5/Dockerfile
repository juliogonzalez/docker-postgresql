FROM docker.io/opensuse/leap:15.5
MAINTAINER Julio Gonzalez Gil <git@juliogonzalez.es>

USER root

# Set locale (will be used by PostgreSQL initdb later on)
RUN zypper -q install -y glibc-i18ndata
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Default UID/GID for mounting folders (used at jenkins slaves)
ARG UID=500
ARG GID=500

# Create postgres group and user according to arguments UID/GID
RUN groupadd -g ${GID} postgres && \
    useradd -d /var/lib/postgresql -m -u ${UID} -g ${GID} postgres

# Create the wrappers to start PostgreSQL and check for PostgreSQL Updates
ADD files/*.sh /opt/

# PostgreSQL arguments
# Default version
ARG POSTGRESQL_VER=9.5
ENV POSTGRESQL_VER=${POSTGRESQL_VER}
ARG POSTGRESQL_TESTING=0
ENV POSTGRESQL_TESTING=${POSTGRESQL_TESTING}

# Add PostgreSQL's repository
ADD files/postgresql.repo /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER}.repo
RUN if [ ! -f /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER/./}.repo ]; then \
      mv /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER}.repo /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER/./}.repo; \
    fi && \
    [ ${POSTGRESQL_TESTING} -eq 1 ] && TESTING="testing\/" && \
    sed -i -e "s|baseurl=https://download.postgresql.org/pub/repos/zypp/<!POSTGRESQL_VER!>|baseurl=https://download.postgresql.org/pub/repos/zypp/testing/${POSTGRESQL_VER}|" /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER/./}.repo; \
    sed -i -e "s/<!POSTGRESQL_VER!>/${POSTGRESQL_VER}/g" /etc/zypp/repos.d/postgresql-${POSTGRESQL_VER/./}.repo

# Pass the output of date command as DATE argument if you want 
# make sure that the image is generated using the lastest 
# PostgreSQL packages (cache will be used for previous steps)
ARG DATE=None

# Generate a list of original packages, update install PostgreSQL
RUN rpm -qa --qf "%{NAME}\n" > /opt/packages-image.txt && \
    rpm --import https://zypp.postgresql.org/keys/PGDG-RPM-GPG-KEY-SLES15 && \
    zypper -q update -y && \
    zypper -q install -y --allow-downgrade \
      postgresql${POSTGRESQL_VER/./} \
      postgresql${POSTGRESQL_VER/./}-server \
      postgresql${POSTGRESQL_VER/./}-devel && \
    zypper -q clean -a # ${DATE}

USER postgres
# Initialize PostgreSQL cluster
RUN /usr/pgsql-${POSTGRESQL_VER}/bin/initdb -D /var/lib/pgsql/${POSTGRESQL_VER}/data

# Allow postgresql password acess from localhost
RUN sed -i -r -e 's/host\s+all\s+all\s+127.0.0.1\/32\s+ident/host all all 127.0.0.1\/32 password/' /var/lib/pgsql/${POSTGRESQL_VER}/data/pg_hba.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Seems there is a problem with the latest openSUSE MicroOS as if
# userns is used to launch the container, the /var/log/postgresql
# is owned by UID/GID 1002 which does not exist on the container or
# the OS
# I still could not find where the issue is
RUN chmod 755 /var/lib/pgsql

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  [ "/var/lib/pgsql"]

CMD ["/bin/bash", "/opt/start_postgresql.sh"]
