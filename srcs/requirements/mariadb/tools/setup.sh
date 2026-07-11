#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Only run this once, on a genuinely empty data directory.
if [ ! -d "${DATADIR}/mysql" ]; then
    echo "First run - initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="${DATADIR}" > /dev/null
fi

# Start a temporary, network-less server (socket only) so we can safely
# provision it before it's reachable from other containers.
mysqld --user=mysql --skip-networking --socket="${SOCKET}" &
TMP_PID=$!

echo "Waiting for MariaDB to accept connections..."
for i in $(seq 1 30); do
    if mysqladmin --socket="${SOCKET}" -uroot ping > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Idempotent: safe to run on every boot, whether this is the first run
# or a restart after an earlier, possibly-interrupted attempt.
mysql --socket="${SOCKET}" -uroot <<-EOSQL
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
	ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	FLUSH PRIVILEGES;
EOSQL

# Only (re)set root's password if it isn't already this password -
# avoids failing on restarts where it was already applied.
if ! mysql --socket="${SOCKET}" -uroot -p"${DB_ROOT_PASS}" -e "SELECT 1" > /dev/null 2>&1; then
    mysql --socket="${SOCKET}" -uroot <<-EOSQL
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
	FLUSH PRIVILEGES;
EOSQL
fi

mysqladmin --socket="${SOCKET}" -uroot -p"${DB_ROOT_PASS}" shutdown
wait "${TMP_PID}"

chown -R mysql:mysql "${DATADIR}"

echo "Starting MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0
