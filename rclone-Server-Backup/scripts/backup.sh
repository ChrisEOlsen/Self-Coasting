#!/bin/bash

# --- CONFIGURATION ---
LOCAL_BACKUP_ROOT="/backups"
SOURCE_DIR="/mnt/server"
RCLONE_REMOTE="G-Drive:server-backups"
RCLONE_CONF="/config/rclone/rclone.conf"
RETENTION_DAYS=7

# --- BACKUP LOOP ---
while true; do
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  BACKUP_DIR="$LOCAL_BACKUP_ROOT/$TIMESTAMP"
  ARCHIVE_NAME="server-backup.tar.gz"

  echo "[$(date)] Starting backup..."

  # Cleanup local backups
  echo "[$(date)] Cleaning up local backups older than ${RETENTION_DAYS} days..."
  find "$LOCAL_BACKUP_ROOT" -maxdepth 1 -mindepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

  # Cleanup remote backups
  echo "[$(date)] Cleaning up remote G-Drive backups older than ${RETENTION_DAYS} days..."
  rclone --config="$RCLONE_CONF" delete --min-age ${RETENTION_DAYS}d "$RCLONE_REMOTE"

  # Create local archive
  echo "[$(date)] Creating local backup archive..."
  mkdir -p "$BACKUP_DIR"
  tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$SOURCE_DIR" .

  # Upload to Google Drive
  echo "[$(date)] Uploading to remote: $RCLONE_REMOTE/$TIMESTAMP"
  rclone --config="$RCLONE_CONF" copy "$BACKUP_DIR" "$RCLONE_REMOTE/$TIMESTAMP" --progress

  echo "[$(date)] Backup complete. Sleeping for 24 hours..."
  sleep 86400
done

