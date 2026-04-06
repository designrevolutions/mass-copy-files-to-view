#!/usr/bin/env bash

set -euo pipefail

############################################
# CONFIGURATION (edit these)
############################################

# Source directory (where files are scanned from)
SOURCE_DIRECTORY="/path/to/source"

# Destination directory (where files are copied to)
DESTINATION_DIRECTORY="$HOME/review_backup_candidates"

# Number of files per batch folder
BATCH_SIZE=1000

# File extensions to include (space-separated)
FILE_EXTENSIONS=(
    jpg jpeg png webp heic gif
    mp4 mov avi mkv
    pdf doc docx xls xlsx ppt pptx
)

# Whether to show verbose output (true/false)
VERBOSE=true

# Whether to use backup numbering for duplicates (true/false)
USE_BACKUP=true

############################################
# END CONFIG
############################################

# Validate source directory
if [ ! -d "$SOURCE_DIRECTORY" ]
then
    echo "Error: source directory does not exist: $SOURCE_DIRECTORY"
    exit 1
fi

# Create destination directory
mkdir -p "$DESTINATION_DIRECTORY"

# Build fd command dynamically from extensions
FD_ARGS=()
for ext in "${FILE_EXTENSIONS[@]}"
do
    FD_ARGS+=("-e" "$ext")
done

# Setup cp flags
CP_FLAGS=()

if [ "$VERBOSE" = true ]
then
    CP_FLAGS+=("-v")
fi

if [ "$USE_BACKUP" = true ]
then
    CP_FLAGS+=("--backup=numbered")
fi

############################################
# MAIN LOOP
############################################

file_counter=0

fdfind . "${FD_ARGS[@]}" "$SOURCE_DIRECTORY" -0 |
while IFS= read -r -d '' source_file
do
    batch_number=$((file_counter / BATCH_SIZE + 1))

    batch_folder=$(printf "%s/batch_%04d" "$DESTINATION_DIRECTORY" "$batch_number")

    mkdir -p "$batch_folder"

    cp "${CP_FLAGS[@]}" "$source_file" "$batch_folder/"

    file_counter=$((file_counter + 1))
done

echo
echo "Done."
echo "Files copied into:"
echo "  $DESTINATION_DIRECTORY"