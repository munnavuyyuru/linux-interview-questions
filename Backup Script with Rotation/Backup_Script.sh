#!/bin/bash

# Usage: ./backup.sh <source_dir> <backup_dir>

# 1. Argument check
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_destination>"
    exit 1
fi

SOURCE="$1"
DEST="$2"
KEEP_COUNT=7

# 2. Validate source
if [ ! -d "$SOURCE" ] || [ ! -r "$SOURCE" ]; then
    echo "Invalid or unreadable source directory: $SOURCE"
    exit 1
fi

# 3. Ensure destination exists
mkdir -p "$DEST" || {
    echo "Cannot create destination directory: $DEST"
    exit 1
}

# 4. Create backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SOURCE_NAME=$(basename "$SOURCE")
BACKUP_PATH="$DEST/backup_${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE")" "$SOURCE_NAME" || {
    echo "Backup failed"
    exit 1
}

echo "Backup created: $BACKUP_PATH"

# 5. Rotation (keep last 7)
TOTAL=$(ls -1 "$DEST"/backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$TOTAL" -gt "$KEEP_COUNT" ]; then
    ls -t "$DEST"/backup_*.tar.gz \
        | tail -n +$((KEEP_COUNT + 1)) \
        | xargs -r rm -f
fi

exit 0