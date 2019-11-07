FROM ubuntu:18.04
MAINTAINER Julio Gonzalez Gil <git@juliogonzalez.es>

USER root

# Set locale (will be used by PostgreSQL initdb later on)
# Also install gnupg2, to be used by apt-key later on (apt-key does not have a explicit dependency)
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update > /dev/null && \
    apt-get -qq -o=Dpkg::Use-Pty=0 -y install locales gnupg2 && \
    apt-get -qq -o=Dpkg::Use-Pty=0 clean > /dev/null && \
    DEBIAN_FRONTEND=noninteractive locale-gen en_US.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# Default UID/GID for mounting folders (used at jenkins slaves)
ARG UID=500
ARG GID=500

# Create postgres group and user according to arguments UID/GID
RUN groupadd -g ${GID} postgres
RUN useradd -d /var/lib/postgresql -u ${UID} -g ${GID} postgres && mkdir /var/lib/postgresql && chown postgres:postgres /var/lib/postgresql

# Create the wrappers to start PostgreSQL and check for PostgreSQL Updates
ADD files/*.sh /opt/

# PostgreSQL arguments
# Default version
ARG POSTGRESQL_VER=9.5
ENV POSTGRESQL_VER=${POSTGRESQL_VER}
ARG POSTGRESQL_TESTING=0
ENV POSTGRESQL_TESTING=${POSTGRESQL_TESTING}

# Add PostgreSQL's repository
RUN [ ${POSTGRESQL_TESTING} -eq 1 ] && TESTING="-testing"; echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg${testing} ${POSTGRESQL_VER} main" >> /etc/apt/sources.list.d/pgdg.list

# Pass the output of date command as DATE argument if you want 
# make sure that the image is generated using the lastest 
# PostgreSQL packages (cache will be used for previous steps)
ARG DATE=None

# Add the PostgreSQL PGP key to verify their Debian packages and install them
# Key should be the same as https://www.postgresql.org/media/keys/ACCC4CF8.asc
# Then generate a list of original packages, upgrade and install PostgreSQL and sudo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    dpkg --get-selections | grep 'install' | grep -v 'deinstall'|cut -f1 > /opt/packages-image.txt && \
    apt-get -qq -o=Dpkg::Use-Pty=0 update > /dev/null && \
    LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -qq -o=Dpkg::Use-Pty=0 -y dist-upgrade > /dev/null && \
    LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -qq -o=Dpkg::Use-Pty=0 -y install \
     postgresql-${POSTGRESQL_VER} \
     postgresql-client-${POSTGRESQL_VER} \
     postgresql-server-dev-${POSTGRESQL_VER} > /dev/null && \
    apt-get -qq -o=Dpkg::Use-Pty=0 clean > /dev/null # ${DATE}

# Allow PostgreSQL password acess from localhost
RUN sed -i -r -e 's/host\s+all\s+all\s+127.0.0.1\/32\s+md5/host all all 127.0.0.1\/32 password/' /etc/postgresql/${POSTGRESQL_VER}/main/pg_hba.conf

# Configure temporary dir
RUN mkdir -p /var/run/postgresql/${POSTGRESQL_VER}-main.pg_stat_tmp && chown postgres:postgres /var/run/postgresql/${POSTGRESQL_VER}-main.pg_stat_tmp

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER postgres

CMD ["/bin/bash", "/opt/start_postgresql.sh"]
