#!/bin/bash
# SnipeIT MySQL Database Backup Script

set -e

# Configuration from environment variables
DB_HOST="${MYSQL_PORT_3306_TCP_ADDR:-snipeit_db}"
DB_PORT="${MYSQL_PORT_3306_TCP_PORT:-3306}"
DB_NAME="${MYSQL_DATABASE:-snipeit}"
DB_USER="root"
DB_PASS="${MYSQL_ROOT_PASSWORD}"

# Backup configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/snipeit_backup_${DATE}.sql"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-30}"

# Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

echo "Starting SnipeIT database backup..."
echo "Date: $(date)"
echo "Database: ${DB_NAME}"
echo "Host: ${DB_HOST}:${DB_PORT}"

# Create database backup
if mysqldump \
    --host="${DB_HOST}" \
    --port="${DB_PORT}" \
    --user="${DB_USER}" \
    --password="${DB_PASS}" \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --add-drop-table \
    --add-locks \
    --extended-insert \
    --quick \
    --lock-tables=false \
    "${DB_NAME}" > "${BACKUP_FILE}"; then
    
    echo "✅ Database backup completed successfully!"
    echo "📁 Backup file: ${BACKUP_FILE}"
    echo "📊 Backup size: $(du -h "${BACKUP_FILE}" | cut -f1)"
    
    # Compress the backup
    gzip "${BACKUP_FILE}"
    echo "🗜️  Backup compressed: ${BACKUP_FILE}.gz"
    
    # Clean up old backups
    echo "🧹 Cleaning up backups older than ${KEEP_DAYS} days..."
    find "${BACKUP_DIR}" -name "snipeit_backup_*.sql.gz" -type f -mtime +${KEEP_DAYS} -delete
    
    # List remaining backups
    echo "📋 Available backups:"
    ls -lah "${BACKUP_DIR}"/snipeit_backup_*.sql.gz 2>/dev/null || echo "No backups found"
    
else
    echo "❌ Database backup failed!"
    exit 1
fi

echo "Backup process completed at $(date)" 