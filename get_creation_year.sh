#!/bin/bash

# Check if a directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

# Get the directory path from the first argument
DIR_PATH="$1"

# Check if the directory exists
if [ ! -d "$DIR_PATH" ]; then
  echo "Directory not found: $DIR_PATH"
  exit 1
fi

# Loop through all files in the directory
for FILE in "$DIR_PATH"/*; do
  # Skip if it's not a regular file
  if [ ! -f "$FILE" ]; then
    continue
  fi

  # Get the creation year of the file
  CREATION_YEAR=$(date -r "$FILE" +%Y)

  # Print the file name and creation year
  echo "File: $(basename "$FILE") | Created in: $CREATION_YEAR"
  mkdir -p $1/$CREATION_YEAR
  chmod 755 $1/$CREATION_YEAR
  mv "$FILE" "$1/$CREATION_YEAR/"
done

echo "File organization complete!"