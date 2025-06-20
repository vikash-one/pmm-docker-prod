#!/bin/bash
set -e

BACKUP_FILE="$1"
VOLUME_NAME="pmm-prod-data"

if [[ -z "$BACKUP_FILE" ]]; then
  echo "❌ Usage: $0 /path/to/pmm-prod-data_YYYY-MM-DD-HH-MM.tar.gz"
  exit 1
fi

BACKUP_DIR=$(dirname "$BACKUP_FILE")
BACKUP_NAME=$(basename "$BACKUP_FILE")

echo "📦 Restoring $BACKUP_NAME into Docker volume $VOLUME_NAME..."

# Use heredoc instead of complex shell quoting inside sh -c
docker run --rm \
  -v "$VOLUME_NAME:/data" \
  -v "$BACKUP_DIR:/backup" \
  alpine sh -c '
    rm -rf /data/* && \
    tar xzf "/backup/'"$BACKUP_NAME"'" -C /data
  '

echo "✅ Restore completed successfully from: $BACKUP_FILE"