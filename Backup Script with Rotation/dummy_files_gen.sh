#!/bin/bash

SOURCE=/tmp/test_source
DEST=/tmp/test_backup

rm -rf "$SOURCE" "$DEST"

mkdir -p "$SOURCE" "$DEST"

# create dummy source files
for i in {1..5}; do
    echo "data $i" > "$SOURCE/file$i.txt"
done

# create 10 fake backups
for i in {1..10}; do
    touch "$DEST/backup_test_source_2024010${i}_120000.tar.gz"
    sleep 1
done

echo "Before:"
ls -1 "$DEST" | wc -l

./backup.sh "$SOURCE" "$DEST"

echo "After:"
ls -1 "$DEST" | wc -l