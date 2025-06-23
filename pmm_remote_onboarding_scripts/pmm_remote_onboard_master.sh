#!/bin/bash
set -e

echo "Select the database type:"
select DB_TYPE in mysql postgresql mongodb; do
  [[ -n "$DB_TYPE" ]] && break
  echo "Invalid selection."
done

read -p "Environment (e.g. dev, qa, prod): " ENV
read -p "Database Host (EC2 IP or DNS): " DB_HOST

case $DB_TYPE in
  mysql)     DEF_PORT=3306 ;;
  postgresql) DEF_PORT=5432 ;;
  mongodb)   DEF_PORT=27017 ;;
esac

read -p "Database Port [default: $DEF_PORT]: " DB_PORT
DB_PORT=${DB_PORT:-$DEF_PORT}

read -p "DB Username: " DB_USER
read -s -p "DB Password: " DB_PASS
echo

echo "[INFO] Testing connection to $DB_TYPE on $DB_HOST:$DB_PORT..."
if ! nc -z -w2 "$DB_HOST" "$DB_PORT"; then
  echo "[ERROR] Cannot connect to $DB_HOST:$DB_PORT"
  exit 1
fi

echo "[INFO] Testing credentials..."

case $DB_TYPE in
  mysql)
    echo "exit" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" &>/dev/null || {
      echo "[ERROR] Invalid MySQL credentials"
      exit 1
    }
    ;;
  postgresql)
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" &>/dev/null || {
      echo "[ERROR] Invalid PostgreSQL credentials"
      exit 1
    }
    ;;
  mongodb)
    mongo --quiet --host "$DB_HOST" --port "$DB_PORT" -u "$DB_USER" -p "$DB_PASS" --authenticationDatabase "admin" --eval "db.runCommand({ping: 1})" | grep -q '"ok"' || {
      echo "[ERROR] Invalid MongoDB credentials"
      exit 1
    }
    ;;
esac

export ENV DB_TYPE DB_HOST DB_PORT DB_USER DB_PASS

SCRIPT_DIR="$(dirname "$0")"
case "$DB_TYPE" in
  mysql)      bash "$SCRIPT_DIR/onboard_mysql_dbs.sh" ;;
  postgresql) bash "$SCRIPT_DIR/onboard_postgres_dbs.sh" ;;
  mongodb)    bash "$SCRIPT_DIR/onboard_mongodb_dbs.sh" ;;
esac
