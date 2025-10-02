#!/bin/bash
set -e

# Directory for git repo
BACKUP_DIR=/backup

# Clone GitHub repo
if [ ! -d "$BACKUP_DIR" ]; then
    git clone https://$GITHUB_TOKEN@github.com/username/db-backups.git $BACKUP_DIR
else
    cd $BACKUP_DIR && git pull
fi

# Path to latest dump
DUMP_FILE="$BACKUP_DIR/latest_dump.sql"

# If dump exists, restore it
if [ -f "$DUMP_FILE" ]; then
    echo "Restoring database from GitHub..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$DUMP_FILE"
else
    echo "No backup found, starting empty database..."
fi

# Start Postgres
docker-entrypoint.sh postgres &

# Wait a bit and then commit new dump every 5 minutes
while true; do
    sleep 300  # 5 minutes
    echo "Backing up database to GitHub..."
    pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_DIR/latest_dump.sql"
    cd $BACKUP_DIR
    git add latest_dump.sql
    git commit -m "Automated backup $(date +"%Y-%m-%d %H:%M:%S")" || true
    git push https://$GITHUB_TOKEN@github.com/kRxZykRxZy/db-backups.git main
done
