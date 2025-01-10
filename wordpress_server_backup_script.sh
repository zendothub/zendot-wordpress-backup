#!/bin/bash

# Load environment variables
export $(grep -v '^#' .env.backup | xargs)

# Check if all required variables are set
REQUIRED_VARS=(S3_BUCKET S3_REGION S3_ACCESS_KEY S3_SECRET_KEY WORDPRESS_PATH BACKUP_NAME RDS_HOST RDS_PORT RDS_USER RDS_PASSWORD RDS_DATABASE)
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in .env.backup"
        exit 1
    fi
done

# Generate current date
CURRENT_DATE=$(date +%Y%m%d%H%M%S)

# Define backup file names with constraints
WP_BACKUP_NAME="${BACKUP_NAME}_wp_data_${CURRENT_DATE}.zip"
DB_BACKUP_NAME="${RDS_DATABASE}_${CURRENT_DATE}.sql"
FINAL_BACKUP_NAME="${BACKUP_NAME}_${CURRENT_DATE}.zip"

# Create temporary directories for backup
TEMP_DIR=$(mktemp -d)
WP_BACKUP_FILE="$TEMP_DIR/$WP_BACKUP_NAME"
DB_BACKUP_FILE="$TEMP_DIR/$DB_BACKUP_NAME"
FINAL_BACKUP_FILE="$TEMP_DIR/$FINAL_BACKUP_NAME"

# Step 1: Backup WordPress folder
echo "Backing up WordPress files..."
zip -r "$WP_BACKUP_FILE" "$WORDPRESS_PATH" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to backup WordPress files."
    exit 1
fi

# Step 2: Backup RDS database
echo "Backing up RDS database..."
mysqldump -h "$RDS_HOST" -P "$RDS_PORT" -u "$RDS_USER" -p"$RDS_PASSWORD" "$RDS_DATABASE" > "$DB_BACKUP_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to backup database."
    exit 1
fi

# Step 3: Combine backups into a single ZIP file
echo "Creating final backup ZIP..."
zip -r "$FINAL_BACKUP_FILE" "$WP_BACKUP_FILE" "$DB_BACKUP_FILE" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to create final backup ZIP."
    exit 1
fi

# Step 4: Upload to S3
echo "Uploading backup to S3..."
AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY" \
aws s3 cp "$FINAL_BACKUP_FILE" "s3://$S3_BUCKET/$FINAL_BACKUP_NAME" --region "$S3_REGION"
if [ $? -ne 0 ]; then
    echo "Error: Failed to upload to S3."
    exit 1
fi

echo "Backup completed successfully and uploaded to S3: $S3_BUCKET/$FINAL_BACKUP_NAME"

# Clean up temporary files
rm -rf "$TEMP_DIR"
