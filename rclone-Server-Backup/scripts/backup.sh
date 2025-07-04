#!/bin/bash

# --- CONFIGURATION ---
SOURCE_DIR="/mnt/server"
RCLONE_REMOTE="G-Drive:server-backups"
RCLONE_CONF="/config/rclone/rclone.conf"
RETENTION_DAYS=7

# --- BACKUP LOOP ---
while true; do
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  ARCHIVE_NAME="server-backup-${TIMESTAMP}.tar.gz"
  TEMP_ARCHIVE="/tmp/$ARCHIVE_NAME"

  echo "[$(date)] Starting backup..."

  # Cleanup remote backups
  echo "[$(date)] Cleaning up remote G-Drive backups older than ${RETENTION_DAYS} days..."
  rclone --config="$RCLONE_CONF" delete --min-age ${RETENTION_DAYS}d "$RCLONE_REMOTE"

  # Create archive in /tmp
  echo "[$(date)] Creating archive: $ARCHIVE_NAME"
  tar -czf "$TEMP_ARCHIVE" -C "$SOURCE_DIR" .

  # Upload directly to Google Drive
  echo "[$(date)] Uploading to remote: $RCLONE_REMOTE/$ARCHIVE_NAME"
  rclone --config="$RCLONE_CONF" copy "$TEMP_ARCHIVE" "$RCLONE_REMOTE/" --progress

  # Delete local archive
  echo "[$(date)] Cleaning up local temp archive..."
  rm -f "$TEMP_ARCHIVE"

  echo "[$(date)] Backup complete. Sleeping for 24 hours..."
  sleep 86400
done

