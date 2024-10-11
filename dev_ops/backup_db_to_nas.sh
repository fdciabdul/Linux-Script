#!/bin/bash
echo "Running backup_and_restore.sh"
echo "Current user: $(whoami)"
echo "User ID: $(id)"
echo "Current directory: $(pwd)"

# OPTIONAL , KALO PAKE AAPANEL, REMOVE LINE INI
export PATH=$PATH:/www/server/pgsql/bin

# ROOT POSTGREE ( WAJIB )
REMOTE_IP="localhost"
PG_USER="postgres"
PG_PASS="password"
BACKUP_DIR="/backup" # POINT NAS DIRECTORY
CURRENT_TIME=$(date +\%Y\%m\%d_\%H\%M)
LOG_FILE="$BACKUP_DIR/backup_log_$CURRENT_TIME.log"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Export password for non-interactive pg_dump
export PGPASSWORD=$PG_PASS

# Function to dump a single database
dump_database() {
    local db=$1
    local db_backup_dir="$BACKUP_DIR/$db"
    mkdir -p $db_backup_dir
    local backup_file="$db_backup_dir/${db}_$CURRENT_TIME.sql.gz"
    pg_dump -h $REMOTE_IP -U $PG_USER -d $db | gzip > "$backup_file"
    if [ $? -eq 0 ]; then
        echo "Backup successful for database: $db" >> $LOG_FILE
    else
        echo "Backup failed for database: $db" >> $LOG_FILE
    fi
}

# Get the list of databases
DATABASES=$(psql -U $PG_USER -h $REMOTE_IP -d postgres -Atc "SELECT datname FROM pg_database WHERE datname NOT IN ('postgres', 'template0', 'template1');")

# Dump all databases in parallel
for db in $DATABASES; do
    dump_database $db &
done
wait

# Unset password
unset PGPASSWORD

# Delete backup files older than one week
find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +7 -exec rm {} \;

echo "Backup completed successfully! Log file: $LOG_FILE"
