#!/bin/bash

# Disk Space Alert Script
# Run via cron every 15-30 minutes

THRESHOLD=85
EMAIL="admin@example.com"
HOSTNAME=$(hostname)

# Check each filesystem
df --output=pcent,target | tail -n +2 | while read line; do
    usage=$(echo $line | awk '{print $1}' | tr -d '%')
    mount=$(echo $line | awk '{print $2}')
    
    if [ $usage -ge $THRESHOLD ]; then
        # Get top 5 largest directories
        if [ "$mount" = "/" ]; then
            top_dirs=$(du -sh /* 2>/dev/null | sort -hr | head -5)
        else
            top_dirs=$(du -sh $mount/* 2>/dev/null | sort -hr | head -5)
        fi
        
        # Send alert
        mail -s "DISK ALERT: $HOSTNAME - $mount at ${usage}%" $EMAIL <<EOF
DISK SPACE ALERT

Hostname: $HOSTNAME
Filesystem: $mount
Usage: ${usage}%
Threshold: ${THRESHOLD}%
Date: $(date)

Top 5 Largest Directories:
$top_dirs
EOF
    fi
done