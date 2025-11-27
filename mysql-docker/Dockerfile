FROM mysql:8.0.33


ADD db_backup.sql /docker-entrypoint-initdb.d/db_backup.sql

ENV MYSQL_DATABASE="accounts"

ENV MYSQL_ROOT_PASSWORD="db-pass"