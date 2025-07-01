#!/bin/sh

while true; do
  echo "Cleaning up local backups older than 7 days..."
  find /backups/* -maxdepth 0 -type d -mtime +7 -exec rm -rf {} \;

  echo "Cleaning up remote G-Drive backups older than 7 days..."
  rclone --config=/config/rclone/rclone.conf delete --min-age 7d G-Drive:gitea-backups

  echo "Running Gitea backup..."
  TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
  BACKUP_DIR="/backups/$TIMESTAMP"
  mkdir -p "$BACKUP_DIR"

  echo "Dumping PostgreSQL database..."
  pg_dump -h db -U "$POSTGRES_USER" gitea > "$BACKUP_DIR/gitea-db.sql"

  echo "Archiving Gitea data..."
  tar -czf "$BACKUP_DIR/gitea-data.tar.gz" -C /data .

  echo "Uploading to remote..."
  rclone --config=/config/rclone/rclone.conf copy "$BACKUP_DIR" G-Drive:gitea-backups/"$TIMESTAMP" --progress

  echo "Backup complete. Sleeping for 24h."
  sleep 86400
done
