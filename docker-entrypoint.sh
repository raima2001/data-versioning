#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Container is running!!!"

# Activate service account
if ! gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS; then
    echo "Failed to activate service account"
    exit 1
fi

# Create mount point
mkdir -p /mnt/gcs_data

# Mount GCS bucket
if ! gcsfuse --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME /mnt/gcs_data; then
    echo "Failed to mount GCS bucket"
    exit 1
fi
echo 'GCS bucket mounted at /mnt/gcs_data'

# Create cheese_dataset directory
mkdir -p /app/cheese_dataset

# Mount images directory
if ! mount --bind /mnt/gcs_data/dvc_store/images /app/cheese_dataset; then
    echo "Failed to mount images directory"
    exit 1
fi

# Verify mount
if ! ls /app/cheese_dataset; then
    echo "Failed to list contents of /app/cheese_dataset"
    exit 1
fi

# Start pipenv shell
exec pipenv shell