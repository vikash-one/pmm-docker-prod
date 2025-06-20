#!/bin/bash
set -e

ENVIRONMENT=prod
VOLUME_NAME="pmm-${ENVIRONMENT}-data"
BACKUP_DIR="/opt/pmm-backup/${ENVIRONMENT}"
TIMESTAMP=$(date +%F-%H-%M)
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "📦 Backing up volume $VOLUME_NAME to $BACKUP_FILE"

docker run --rm \
  -v $VOLUME_NAME:/data:ro \
  -v $BACKUP_DIR:/backup \
  alpine \
  sh -c "tar czf /backup/$(basename "$BACKUP_FILE") -C /data ."

echo "✅ Backup successful: $BACKUP_FILE"