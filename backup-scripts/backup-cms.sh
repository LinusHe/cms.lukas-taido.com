#!/bin/bash

# CMS Backup Script with incremental media backup
# Usage: ./backup-cms.sh [daily|weekly|monthly]

BACKUP_TYPE=${1:-daily}
BASE_DIR="/root/cms.lukas-taido.com"
BACKUP_DIR="$BASE_DIR/backups"
LOG_DIR="$BACKUP_DIR/logs"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Create backup directories
mkdir -p "$BACKUP_DIR/$BACKUP_TYPE"
mkdir -p "$BACKUP_DIR/checksums"
mkdir -p "$LOG_DIR"

# Log rotation - keep only last 12 months of logs
find "$LOG_DIR" -name "backup-*.log" -type f -mtime +365 -delete 2>/dev/null

# Setup logging
LOG_FILE="$LOG_DIR/backup-$(date +%Y-%m).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "$(date): === CMS Backup started ($BACKUP_TYPE) ==="

# Track current backup size
CURRENT_BACKUP_SIZE=0

# 1. MongoDB Backup (always full backup)
echo "$(date): Backing up MongoDB..."
DB_BACKUP_FILE="$BACKUP_DIR/$BACKUP_TYPE/db-$TIMESTAMP.gz"
docker exec cmslukas-taidocom_mongo_1 mongodump --db payload --archive --gzip > "$DB_BACKUP_FILE"
if [ $? -eq 0 ]; then
    DB_SIZE=$(du -sb "$DB_BACKUP_FILE" | cut -f1)
    CURRENT_BACKUP_SIZE=$((CURRENT_BACKUP_SIZE + DB_SIZE))
    echo "$(date): ✓ MongoDB backed up ($(du -sh "$DB_BACKUP_FILE" | cut -f1))"
else
    echo "$(date): ✗ MongoDB backup failed!"
    exit 1
fi

# 2. Check media folder changes
echo "$(date): Checking media changes..."
if [ -d "media/" ]; then
    CURRENT_MEDIA_HASH=$(find media/ -type f -exec md5sum {} + 2>/dev/null | sort | md5sum | cut -d' ' -f1)
    LAST_MEDIA_HASH=""

    if [ -f "$BACKUP_DIR/checksums/media-last.hash" ]; then
        LAST_MEDIA_HASH=$(cat "$BACKUP_DIR/checksums/media-last.hash")
    fi

    if [ "$CURRENT_MEDIA_HASH" != "$LAST_MEDIA_HASH" ]; then
        echo "$(date): Media changes detected - creating backup..."
        MEDIA_BACKUP_FILE="$BACKUP_DIR/$BACKUP_TYPE/media-$TIMESTAMP.tar.gz"
        tar -czf "$MEDIA_BACKUP_FILE" media/
        if [ $? -eq 0 ]; then
            echo "$CURRENT_MEDIA_HASH" > "$BACKUP_DIR/checksums/media-last.hash"
            MEDIA_SIZE=$(du -sb "$MEDIA_BACKUP_FILE" | cut -f1)
            CURRENT_BACKUP_SIZE=$((CURRENT_BACKUP_SIZE + MEDIA_SIZE))
            echo "$(date): ✓ Media backed up ($(du -sh media/ | cut -f1))"
        else
            echo "$(date): ✗ Media backup failed!"
        fi
    else
        echo "$(date): ⏭ Media unchanged - no backup needed"
    fi
else
    echo "$(date): ⚠ Media directory not found"
fi

# 3. Check documents folder changes
echo "$(date): Checking documents changes..."
if [ -d "documents/" ]; then
    CURRENT_DOCS_HASH=$(find documents/ -type f -exec md5sum {} + 2>/dev/null | sort | md5sum | cut -d' ' -f1)
    LAST_DOCS_HASH=""

    if [ -f "$BACKUP_DIR/checksums/documents-last.hash" ]; then
        LAST_DOCS_HASH=$(cat "$BACKUP_DIR/checksums/documents-last.hash")
    fi

    if [ "$CURRENT_DOCS_HASH" != "$LAST_DOCS_HASH" ]; then
        echo "$(date): Documents changes detected - creating backup..."
        DOCS_BACKUP_FILE="$BACKUP_DIR/$BACKUP_TYPE/documents-$TIMESTAMP.tar.gz"
        tar -czf "$DOCS_BACKUP_FILE" documents/
        if [ $? -eq 0 ]; then
            echo "$CURRENT_DOCS_HASH" > "$BACKUP_DIR/checksums/documents-last.hash"
            DOCS_SIZE=$(du -sb "$DOCS_BACKUP_FILE" | cut -f1)
            CURRENT_BACKUP_SIZE=$((CURRENT_BACKUP_SIZE + DOCS_SIZE))
            echo "$(date): ✓ Documents backed up ($(du -sh documents/ | cut -f1))"
        else
            echo "$(date): ✗ Documents backup failed!"
        fi
    else
        echo "$(date): ⏭ Documents unchanged - no backup needed"
    fi
else
    echo "$(date): ⚠ Documents directory not found"
fi

# 4. Clean up old backups according to GFS scheme
echo "$(date): Cleaning up old backups..."
case $BACKUP_TYPE in
    daily)
        # Keep only last 7 daily backups
        find "$BACKUP_DIR/daily" -name "db-*.gz" -type f | sort -r | tail -n +8 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/daily" -name "media-*.tar.gz" -type f | sort -r | tail -n +8 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/daily" -name "documents-*.tar.gz" -type f | sort -r | tail -n +8 | xargs rm -f 2>/dev/null
        ;;
    weekly)
        # Keep only last 4 weekly backups
        find "$BACKUP_DIR/weekly" -name "db-*.gz" -type f | sort -r | tail -n +5 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/weekly" -name "media-*.tar.gz" -type f | sort -r | tail -n +5 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/weekly" -name "documents-*.tar.gz" -type f | sort -r | tail -n +5 | xargs rm -f 2>/dev/null
        ;;
    monthly)
        # Keep only last 12 monthly backups
        find "$BACKUP_DIR/monthly" -name "db-*.gz" -type f | sort -r | tail -n +13 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/monthly" -name "media-*.tar.gz" -type f | sort -r | tail -n +13 | xargs rm -f 2>/dev/null
        find "$BACKUP_DIR/monthly" -name "documents-*.tar.gz" -type f | sort -r | tail -n +13 | xargs rm -f 2>/dev/null
        ;;
esac

# Convert bytes to human readable
if [ $CURRENT_BACKUP_SIZE -gt 1073741824 ]; then
    BACKUP_SIZE_HUMAN="$(echo "scale=1; $CURRENT_BACKUP_SIZE/1073741824" | bc)G"
elif [ $CURRENT_BACKUP_SIZE -gt 1048576 ]; then
    BACKUP_SIZE_HUMAN="$(echo "scale=1; $CURRENT_BACKUP_SIZE/1048576" | bc)M"
elif [ $CURRENT_BACKUP_SIZE -gt 1024 ]; then
    BACKUP_SIZE_HUMAN="$(echo "scale=1; $CURRENT_BACKUP_SIZE/1024" | bc)K"
else
    BACKUP_SIZE_HUMAN="${CURRENT_BACKUP_SIZE}B"
fi

echo "$(date): === Backup completed ==="
echo "$(date): Current backup size: $BACKUP_SIZE_HUMAN"
echo "$(date): Total backup storage: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo ""
