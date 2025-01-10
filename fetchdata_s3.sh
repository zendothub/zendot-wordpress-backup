#!/bin/bash

# Load environment variables from .env.backup
export $(grep -v '^#' .env.backup | xargs)

# Check if all required environment variables are set
REQUIRED_VARS=(S3_REGION S3_BUCKET S3_OBJECT_NAME)
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in .env.backup"
        exit 1
    fi
done

# Define Local Download Path
LOCAL_DOWNLOAD_PATH="./backup_data"  # Path to save the file locally

# Create the directory to store the downloaded file
mkdir -p "$LOCAL_DOWNLOAD_PATH"

# Fetch data (file) from S3 and save it locally
echo "Downloading object '$S3_OBJECT_NAME' from S3 bucket '$S3_BUCKET'..."
aws s3 cp "s3://$S3_BUCKET/$S3_OBJECT_NAME" "$LOCAL_DOWNLOAD_PATH"

if [ $? -ne 0 ]; then
    echo "Error: Failed to download the object from S3."
    exit 1
else
    echo "Download successful! File saved to: $LOCAL_DOWNLOAD_PATH"
fi
