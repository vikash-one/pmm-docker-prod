#!/bin/bash
aws s3 sync /opt/pmm-backup/prod s3://my-pmm-prod-backups/ --storage-class STANDARD_IA