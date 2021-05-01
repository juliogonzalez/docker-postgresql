#!/bin/bash

DB_NAME=${DB_NAME:-}
DB_PASS=${DB_PASS:-}

DB_USER='postgresql'
PG_VER="${POSTGRESQL_VER}"
PG_PATH="/usr/lib/postgresql/${PG_VER}/bin"
DB_PATH="/var/lib/postgresql/${PG_VER}/main"
ETC_PATH="/etc/postgresql/${PG_VER}/main"

# Start service with pg_ctl
${PG_PATH}/pg_ctl -w start -D ${DB_PATH} -o "-c config_file=${ETC_PATH}/postgresql.conf"

# Create database if needed
if [ ! -z "${DB_NAME}" ]; then
  if ! ${PG_PATH}/psql -c "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1; then
    echo "Creating database \"${DB_NAME}\"..."
    ${PG_PATH}/psql -c "CREATE DATABASE ${DB_NAME}"
  else
    echo "Warning: Database \"${DB_NAME}\" was already created!"
  fi
fi

# Create role if needed
if ! ${PG_PATH}/psql -c "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1; then
  echo "Creating user \"${DB_USER}\"..."
  if [ -z "${DB_PASS}" ]; then
    DB_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
    echo "WARNING: No password specified. Random password created: \"${DB_PASS}\""
  fi
  ${PG_PATH}/psql -c "CREATE ROLE ${DBUSERNAME} SUPERUSER LOGIN PASSWORD '${DBPASSWORD}'"
elif [ ! -z "${DB_PASS}" ]; then
  echo "Warning: User \"${DB_USER}\" was already created!"
fi

# Stop service with pg_ctl and start it with postmaster
${PG_PATH}/pg_ctl -w stop -D ${DB_PATH} -o "-c config_file=${ETC_PATH}/postgresql.conf"

echo "Starting PostgreSQL ${PG_VER}..."
${PG_PATH}/postmaster -D ${DB_PATH} --config_file=${ETC_PATH}/postgresql.conf >> /var/log/postgresql/postgresql-${PG_VER}-main.log 2>&1
