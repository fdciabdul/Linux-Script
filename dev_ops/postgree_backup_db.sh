#!/bin/bash

# Function to display ASCII banner
display_banner() {
    echo -e "\033[1;34m"
    echo -e "\033[0m"
}

# Display banner
display_banner

# Prompt for backup directory
read -rp "Enter the backup directory (default: /mnt/nas1): " BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-/mnt/nas1}

# Prompt for PostgreSQL credentials
read -rp "Enter PostgreSQL Host (default: localhost): " REMOTE_IP
REMOTE_IP=${REMOTE_IP:-localhost}

read -rp "Enter PostgreSQL Username (default: postgres): " PG_USER
PG_USER=${PG_USER:-postgres}

read -rsp "Enter PostgreSQL Password (default: postgre123): " PG_PASS
PG_PASS=${PG_PASS:-postgre123}
echo

export PATH=$PATH:/www/server/pgsql/bin
export PGPASSWORD=$PG_PASS

CURRENT_TIME=$(date +%Y%m%d_%H%M)
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
THREAD_ID=""

mkdir -p "$BACKUP_DIR"

# Log start
echo -e "\033[1;32m[INFO]\033[0m Backup process started at $(date)"

# Function to dump database
dump_database() {
    local db=$1
    local db_backup_dir="$BACKUP_DIR/$db"
    mkdir -p "$db_backup_dir"
    local backup_file="$db_backup_dir/${db}_$CURRENT_TIME.sql.gz"

    echo -e "\033[1;36m[PROCESSING]\033[0m Backing up database: $db"
    if pg_dump -h "$REMOTE_IP" -U "$PG_USER" -d "$db" | gzip > "$backup_file"; then
        echo -e "\033[1;32m[SUCCESS]\033[0m Backup successful for: $db"
    else
        echo -e "\033[1;31m[ERROR]\033[0m Backup failed for: $db"
    fi
}

# Fetch databases
DATABASES=$(psql -U "$PG_USER" -h "$REMOTE_IP" -d postgres -Atc \
"SELECT datname FROM pg_database WHERE datname NOT IN ('postgres', 'template0', 'template1');")

if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Could not fetch databases. Check credentials or connection."
    exit 1
fi

DB_COUNT=$(echo "$DATABASES" | wc -l)

# Backup in parallel
for db in $DATABASES; do
    dump_database "$db" &
done
wait

unset PGPASSWORD

# Cleanup old backups
echo -e "\033[1;33m[CLEANUP]\033[0m Removing backups older than 3 days..."
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +3 -exec rm {} \;

if [ $? -eq 0 ]; then
    echo -e "\033[1;32m[SUCCESS]\033[0m Old backups cleaned successfully."
else
    echo -e "\033[1;31m[ERROR]\033[0m Failed to clean old backups."
fi

# Send Telegram notification
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d "chat_id=$TELEGRAM_CHAT_ID" \
    -d "message_thread_id=$THREAD_ID" \
    -d "text=$message"
}

SUCCESS_MESSAGE="✅ Backup completed successfully at $(date '+%Y-%m-%d %H:%M:%S'). Total databases backed up: $DB_COUNT."
send_telegram_message "$SUCCESS_MESSAGE"

# Completion log
echo -e "\033[1;32m[INFO]\033[0m Backup process completed at $(date)"
echo -e "\033[1;34m[COMPLETE]\033[0m All backups are done!"
