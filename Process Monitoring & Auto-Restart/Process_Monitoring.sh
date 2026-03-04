#!/bin/bash

SERVICE="$1"
MAX_RESTARTS=3
LOG_FILE="/var/log/monitor.log"
COUNT_FILE="/tmp/${SERVICE}_restart_count"

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    logger -t "monitor_script" "$1"
}

is_systemd() {
    systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE}.service"
}

is_running() {
    if is_systemd; then
        systemctl is-active --quiet "$SERVICE"
    else
        pgrep -x "$SERVICE" > /dev/null
    fi
}

restart() {
    if is_systemd; then
        systemctl restart "$SERVICE"
    else
        log "Cannot auto-restart non-systemd process: $SERVICE"
        return 1
    fi
}

get_count() {
    cat "$COUNT_FILE" 2>/dev/null || echo 0
}

increment_count() {
    count=$(get_count)
    count=$((count + 1))
    echo "$count" > "$COUNT_FILE"
    echo "$count"
}

reset_count() {
    echo 0 > "$COUNT_FILE"
}


if is_running; then
    reset_count
    log "$SERVICE is running."
else
    log "WARNING: $SERVICE is DOWN."

    count=$(increment_count)

    if [ "$count" -gt "$MAX_RESTARTS" ]; then
        log "CRITICAL: $SERVICE exceeded max restart attempts."
        exit 1
    fi

    log "Attempting restart ($count/$MAX_RESTARTS)..."

    if restart; then
        sleep 2
        if is_running; then
            log "SUCCESS: $SERVICE restarted."
            reset_count
        else
            log "ERROR: $SERVICE failed after restart."
        fi
    else
        log "ERROR: Restart command failed."
    fi
fi