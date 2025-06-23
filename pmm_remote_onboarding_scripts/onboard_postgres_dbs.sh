#!/bin/bash
set -e

: "${ENV:?Missing ENV}"
: "${DB_HOST:?Missing DB_HOST}"
: "${DB_PORT:?Missing DB_PORT}"
: "${DB_USER:?Missing DB_USER}"
: "${DB_PASS:?Missing DB_PASS}"

check_exists() {
  pmm-admin list | grep -qw "$1"
}

DBS=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -At -c   "SELECT datname FROM pg_database WHERE datistemplate = false;" 2>/dev/null)

for db in $DBS; do
  svc_name="${ENV}_pgsql_${db}"
  if check_exists "$svc_name"; then
    echo "[SKIP] $svc_name already exists"
  else
    echo "[ADD] Registering $svc_name"
    pmm-admin add postgresql       --username="$DB_USER"       --password="$DB_PASS"       --host="$DB_HOST"       --port="$DB_PORT"       --database="$db"       --service-name="$svc_name"
  fi
done

echo "[DONE] All PostgreSQL DBs processed."
