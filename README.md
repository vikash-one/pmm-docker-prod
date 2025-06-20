# PMM Docker - Production Setup

## Install Docker
```
cd install/
chmod +x install-docker-and-deps.sh
./install-docker-and-deps.sh
```

## Start PMM
```
cp .env .env.prod
docker compose -f docker-compose.base.yml -f docker-compose.prod.yml --env-file .env up -d
```

## Backup
```
./backup/backup-pmm.sh
```

## Restore
```
./backup/restore-pmm.sh /opt/pmm-backup/prod/pmm-prod-data_YYYY-MM-DD-HH-MM.tar.gz
```

## Sync to S3
```
./backup/sync-backups.sh
```

## Health Check
```
./health-check.sh
```

## Web Access
- PMM: `https://<your-ip>:443`
- Watchtower: `http://<your-ip>:8080`