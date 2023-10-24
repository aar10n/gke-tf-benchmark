#!/bin/bash
set -e

if [ -z "$BUCKET" ]; then
  echo "ERROR: BUCKET env variable is not set."
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <template>"
  exit 1
fi


template="$1"
if [ ! -f "$template" ]; then
  echo "ERROR: Template file does not exist."
  exit 1
fi

while IFS= read -r line; do
  size=$(echo "$line" | awk '{print $1}')
  path=$(echo "$line" | awk '{print $2}')

    if gsutil -q stat "gs://$BUCKET/$path"; then
      echo "Object gs://$BUCKET/$path already exists. Skipping..."
    else
      # Generate and upload random data
      temp_file=$(mktemp)
      dd if=/dev/urandom of="$temp_file" bs=1 count="$size" status=none

      gsutil cp "$temp_file" "gs://$BUCKET/$path"
      rm "$temp_file"

      echo "Uploaded $path with size $size bytes to GCS"
    fi
done < "$template"
