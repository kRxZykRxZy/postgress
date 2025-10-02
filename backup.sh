#!/bin/bash
set -e

# Environment variables (to set in Render dashboard)
# GITHUB_TOKEN, GITHUB_REPO, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB

BACKUP_DIR=/backup

# Clone or update repo
if [ ! -d "$BACKUP_DIR" ]; then
    git clone https://$GITHUB_TOKEN@github.com/$GITHUB_REPO.git $BACKUP_DIR
else
    cd $BACKUP_DIR && git pull
fi

DUMP_FILE="$BACKUP_DIR/latest_dump.sql"

# Dump the database
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -U $POSTGRES_USER $POSTGRES_DB > "$DUMP_FILE"

cd $BACKUP_DIR
git add latest_dump.sql
git commit -m "Automated backup $(date +"%Y-%m-%d %H:%M:%S")" || true
git push https://$GITHUB_TOKEN@github.com/$GITHUB_REPO.git main
