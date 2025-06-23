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

DBS=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS"   -e "SHOW DATABASES;" -s --skip-column-names 2>/dev/null | grep -v -E '^(mysql|sys|performance_schema|information_schema)$')

for db in $DBS; do
  svc_name="${ENV}_mysql_${db}"
  if check_exists "$svc_name"; then
    echo "[SKIP] $svc_name already exists"
  else
    echo "[ADD] Registering $svc_name"
    pmm-admin add mysql       --username="$DB_USER"       --password="$DB_PASS"       --host="$DB_HOST"       --port="$DB_PORT"       --database="$db"       --service-name="$svc_name"
  fi
done

echo "[DONE] All MySQL DBs processed."
