#!/bin/bash
set -e

# Neutralize any inherited host/port vars that would force a TCP connection
# instead of the Unix socket (this was our earlier bug).
unset MYSQL_HOST MYSQL_TCP_PORT MYSQL_UNIX_PORT

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Only initialize once, on a genuinely fresh data directory.
if [ ! -d "${DATADIR}/mysql" ]; then
    echo "First run - initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="${DATADIR}" > /dev/null
fi

# Temporary, network-less server so we can safely provision it.
mysqld --user=mysql --skip-networking --socket="${SOCKET}" &
TMP_PID=$!

echo "Waiting for MariaDB to accept connections..."
for i in $(seq 1 30); do
    if mysqladmin --socket="${SOCKET}" -uroot ping > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Idempotent — safe on every boot, first run or restart.
mysql --socket="${SOCKET}" -uroot <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# Only reset root's password if it isn't already this password.
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