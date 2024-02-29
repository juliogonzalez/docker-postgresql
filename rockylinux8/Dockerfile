FROM docker.io/rockylinux/rockylinux:8
MAINTAINER Julio Gonzalez Gil <git@juliogonzalez.es>

USER root

# Set locale (will be used by PostgreSQL initdb later on)
RUN dnf -y -q install glibc-langpack-en
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
ADD files/postgresql.repo /etc/yum.repos.d/postgresql-${POSTGRESQL_VER}.repo
RUN if [ ! -f /etc/yum.repos.d/postgresql-${POSTGRESQL_VER/./}.repo ]; then \
      mv /etc/yum.repos.d/postgresql-${POSTGRESQL_VER}.repo /etc/yum.repos.d/postgresql-${POSTGRESQL_VER/./}.repo; \
    fi && \
    [ ${POSTGRESQL_TESTING} -eq 1 ] && TESTING="testing\/"; \
    sed -i -e "s/download.postgresql.org\/pub\/repos\/yum\/<!POSTGRESQL_VER!>/download.postgresql.org\/pub\/repos\/yum\/${TESTING}${POSTGRESQL_VER}/g" /etc/yum.repos.d/postgresql-${POSTGRESQL_VER/./}.repo; \
    sed -i -e "s/<!POSTGRESQL_VER!>/${POSTGRESQL_VER}-testing/g" /etc/yum.repos.d/postgresql-${POSTGRESQL_VER/./}.repo

# Pass the output of date command as DATE argument if you want 
# make sure that the image is generated using the lastest 
# PostgreSQL packages (cache will be used for previous steps)
ARG DATE=None

# Generate a list of original packages, add EPEL, enable powertools, disable the default PostgreSQL module, update and install PostgreSQL
RUN rpm -qa --qf "%{NAME}\n" > /opt/packages-image.txt && \
    dnf -y -q install epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf -y -q module disable postgresql && \
    dnf -y -q update && \
    dnf -y -q install \
      postgresql${POSTGRESQL_VER/./} \
      postgresql${POSTGRESQL_VER/./}-server \
      postgresql${POSTGRESQL_VER/./}-devel && \
    dnf -q clean all # ${DATE}

USER postgres
# Initialize PostgreSQL cluster
RUN /usr/pgsql-${POSTGRESQL_VER}/bin/initdb -D /var/lib/pgsql/${POSTGRESQL_VER}/data

# Allow postgresql password acess from localhost
RUN sed -i -r -e 's/host\s+all\s+all\s+127.0.0.1\/32\s+ident/host all all 127.0.0.1\/32 password/' /var/lib/pgsql/${POSTGRESQL_VER}/data/pg_hba.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  [ "/var/lib/pgsql"]

CMD ["/bin/bash", "/opt/start_postgresql.sh"]
