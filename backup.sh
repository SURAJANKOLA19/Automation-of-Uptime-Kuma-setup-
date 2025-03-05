#!/bin/bash
 
# --- Step 1: Check if app.py is Running ---

APP_PID=$(pgrep -f "python3 app.py")
 
if [ -n "$APP_PID" ]; then

    echo "✅ app.py is already running with PID: $APP_PID. Letting it continue..."

else

    echo "⚠️ app.py is not running. Starting it now..."

    nohup python3 app.py > app.log 2>&1 &  # Run in the background with logging

    sleep 2  # Give it time to start
 
    # Verify if app.py started successfully

    APP_PID=$(pgrep -f "python3 app.py")

    if [ -z "$APP_PID" ]; then

        echo "❌ Error: Failed to start app.py. Check app.log for details."

        exit 1

    fi

fi
 
# --- Step 2: Wait Until app.py Runs for 5 Minutes ---

echo "⏳ Waiting until app.py has been running for at least 5 minutes..."

START_TIME=$(date +%s)
 
while true; do

    CURRENT_TIME=$(date +%s)

    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
 
    # Check if app.py is still running

    if ! ps -p "$APP_PID" > /dev/null; then

        echo "❌ Error: app.py stopped running! Exiting."

        exit 1

    fi
 
    # Exit loop after 5 minutes (300 seconds)

    if [ "$ELAPSED_TIME" -ge 10 ]; then

        echo "✅ app.py has been running for 10 seconds. Proceeding..."

        break

    fi
 
    sleep 10  # Check every 10 seconds

done
 
# --- Step 3: Configure AWS CLI & Create S3 Bucket ---

echo "🔹 Configuring AWS CLI..."

aws s3 ls 
 
echo "✅ AWS CLI configured successfully!"
 
# Create an S3 Bucket

read -p "Enter a name for your S3 backup bucket: " S3_BUCKET_NAME

S3_BUCKET="s3://$S3_BUCKET_NAME"
 
# Check if the bucket exists and create if necessary

if aws s3 ls "s3://$S3_BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then

    echo "⚠️ Bucket does not exist. Creating S3 bucket: $S3_BUCKET_NAME..."

    aws s3 mb "$S3_BUCKET"

    echo "✅ S3 bucket $S3_BUCKET_NAME created successfully!"

else

    echo "✅ S3 bucket $S3_BUCKET_NAME already exists. Proceeding..."

fi
 
# --- Step 4: Uptime Kuma Backup Setup ---

echo "🔹 Starting Uptime Kuma backup..."

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

BACKUP_DIR="$HOME/uptime-kuma-backups"

SOURCE_DIR="/opt/uptime-kuma/data"

BACKUP_FILE="$BACKUP_DIR/uptime-kuma-backup-$TIMESTAMP.tar.gz"

MAX_BACKUPS=7  # Keep last 7 backups
 
mkdir -p "$BACKUP_DIR"
 
# --- Step 5: Perform Backup ---

if [ -d "$SOURCE_DIR" ]; then

    tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" .

    echo "✅ Backup completed: $BACKUP_FILE"

else

    echo "❌ Error: Uptime Kuma data directory not found!"

    exit 1

fi
 
# --- Step 6: Clean Up Old Backups ---

echo "🗑️ Cleaning up old backups..."

ls -t "$BACKUP_DIR"/uptime-kuma-backup-*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
 
# --- Step 7: Upload to AWS S3 ---

echo "☁️ Uploading backup to AWS S3..."

aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/uptime-kuma-backup-$TIMESTAMP.tar.gz"
 
echo "✅ Backup process completed successfully!"
 
# --- Step 8: Automate Backup with Cron ---

echo "🕒 Checking for existing cron job..."

CRON_JOB="0 19 * * * /bin/bash ~/backup.sh >> /var/log/uptime-kuma-backup.log 2>&1"

CRON_FILE="/tmp/cronjob"
 
crontab -l > "$CRON_FILE" 2>/dev/null
 
if ! grep -Fxq "$CRON_JOB" "$CRON_FILE"; then

    echo "$CRON_JOB" >> "$CRON_FILE"

    crontab "$CRON_FILE"

    echo "✅ Cron job added for daily backup at 7 PM."

else

    echo "✅ Cron job already exists."

fi
 
echo "🎉 Setup complete! Your Python app & backups are now automated."

exit 0
