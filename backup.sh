#!/bin/bash

# Set the PostgreSQL service name and namespace
POSTGRES_SERVICE_NAME="postgres"
NAMESPACE="default"

# Directory to store the backups
BACKUP_DIR="/path/to/backup/directory"

# Number of days to retain backups
RETENTION_DAYS=7

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Get the ClusterIP of the PostgreSQL service
POSTGRES_HOST=$(kubectl get svc $POSTGRES_SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.clusterIP}')

# Set the PostgreSQL username and password
PGUSER="your_pg_username"
PGPASSWORD="your_pg_password"  # Make sure to handle this securely
export PGPASSWORD

# Get the current date and time for the backup filename
DATE=$(date +"%Y%m%d%H%M%S")

# Set the backup filename
BACKUP_FILE="$BACKUP_DIR/postgres_backup_$DATE.sql"

# Perform the backup using pg_dumpall
pg_dumpall -h "$POSTGRES_HOST" -U "$PGUSER" -f "$BACKUP_FILE"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup successful: $BACKUP_FILE"
else
  echo "Backup failed"
  exit 1
fi

# Unset the PGPASSWORD variable for security
unset PGPASSWORD

# Remove backups older than RETENTION_DAYS
find "$BACKUP_DIR" -type f -name "postgres_backup_*.sql" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "Old backups older than $RETENTION_DAYS days have been deleted."

