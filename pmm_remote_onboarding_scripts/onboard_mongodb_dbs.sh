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

DBS=$(mongo --quiet --host "$DB_HOST" --port "$DB_PORT" -u "$DB_USER" -p "$DB_PASS" --authenticationDatabase "admin" --eval "db.adminCommand('listDatabases').databases.map(db => db.name).join('\n')" 2>/dev/null | grep -v -E '^(admin|config|local)$')

for db in $DBS; do
  svc_name="${ENV}_mongo_${db}"
  if check_exists "$svc_name"; then
    echo "[SKIP] $svc_name already exists"
  else
    echo "[ADD] Registering $svc_name"
    pmm-admin add mongodb       --username="$DB_USER"       --password="$DB_PASS"       --host="$DB_HOST"       --port="$DB_PORT"       --authentication-database="admin"       --service-name="$svc_name"
  fi
done

echo "[DONE] All MongoDB DBs processed."
