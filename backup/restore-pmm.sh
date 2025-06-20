#!/bin/bash
set -e
BACKUP_FILE="$1"
VOLUME_NAME="pmm-prod-data"
[[ -z "$BACKUP_FILE" ]] && echo "❌ Provide backup file path." && exit 1
docker run --rm -v $VOLUME_NAME:/data -v $(dirname "$BACKUP_FILE"):/backup alpine sh -c "rm -rf /data/* && tar xzf /backup/$(basename \"$BACKUP_FILE\") -C /data"
echo "✅ Restore completed."