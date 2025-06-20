#!/bin/bash
set -e

### 🔧 CONFIGURATION ###
VOLUME_NAME="pmm-prod-data"
BACKUP_DIR="/opt/pmm-backup/prod"
S3_BUCKET="s3://your-bucket-name/pmm-backups"
ENV_FILE="/root/pmm-docker/pmm-docker-prod/.env"
COMPOSE_BASE="docker-compose.base.yml"
COMPOSE_ENV="docker-compose.prod.yml"
COMPOSE_PATH="/root/pmm-docker/pmm-docker-prod"
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BACKUP_FILE="pmm-${VOLUME_NAME}_${TIMESTAMP}.tar.gz"
LOG_FILE="/var/log/pmm-backup.log"
################################

echo "📦 Starting PMM backup @ $TIMESTAMP" | tee -a "$LOG_FILE"

cd "$COMPOSE_PATH"

# Stop Docker for consistency
echo "⛔ Stopping PMM containers..." | tee -a "$LOG_FILE"
docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_ENV" --env-file "$ENV_FILE" down >> "$LOG_FILE" 2>&1

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Backup volume
echo "📦 Backing up Docker volume: $VOLUME_NAME" | tee -a "$LOG_FILE"
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "${BACKUP_DIR}:/backup" \
  alpine sh -c "tar czf /backup/${BACKUP_FILE} -C /data ."

# # Upload to S3
# echo "☁️ Uploading to S3: $S3_BUCKET/$BACKUP_FILE" | tee -a "$LOG_FILE"
# aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}" "${S3_BUCKET}/${BACKUP_FILE}" >> "$LOG_FILE" 2>&1

# Restart Docker
echo "▶️ Restarting PMM containers..." | tee -a "$LOG_FILE"
docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_ENV" --env-file "$ENV_FILE" up -d >> "$LOG_FILE" 2>&1

echo "✅ Backup completed: $BACKUP_FILE" | tee -a "$LOG_FILE"
