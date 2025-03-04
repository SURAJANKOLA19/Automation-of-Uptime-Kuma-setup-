#!/bin/bash

# Set Variables
BACKUP_DIR="/home/ubuntu/uptime-kuma-backups"
SOURCE_DIR="/opt/uptime-kuma/data"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/uptime-kuma-backup-$TIMESTAMP.tar.gz"
MAX_BACKUPS=7  # Keep last 7 backups

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create the backup
echo "Starting backup of Uptime Kuma data..."
if [ -d "$SOURCE_DIR" ]; then
    tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" .
    echo "Backup completed: $BACKUP_FILE"
else
    echo "Error: Uptime Kuma data directory not found!"
    exit 1
fi

# Delete old backups (keep last 7)
echo "Cleaning up old backups..."
ls -t "$BACKUP_DIR"/uptime-kuma-backup-*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f

# OPTIONAL: Upload to Amazon S3 (Uncomment if needed)
# S3_BUCKET="s3://your-bucket-name"
# aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/uptime-kuma-backup-$TIMESTAMP.tar.gz"

echo "Backup process completed successfully!"

# Add Cron Job for Daily Backup at 7 PM (If not already added)
CRON_JOB="0 19 * * * /path/to/backup_uptime_kuma.sh >> /var/log/uptime-kuma-backup.log 2>&1"
CRON_FILE="/tmp/cronjob"

crontab -l > "$CRON_FILE" 2>/dev/null
if ! grep -Fxq "$CRON_JOB" "$CRON_FILE"; then
    echo "$CRON_JOB" >> "$CRON_FILE"
    crontab "$CRON_FILE"
    echo "Cron job added for daily backup at 7 PM."
else
    echo "Cron job already exists."
fi

echo "Setup complete! Your backups are now automated."
exit 0
