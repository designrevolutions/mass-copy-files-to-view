#!/usr/bin/env bash

# Enable strict mode:
# - exit immediately if a command fails
# - treat unset variables as errors
# - fail a pipeline if any command in it fails
set -euo pipefail

############################################
# FILE TYPES TO INCLUDE
############################################

# File extensions to include in the copy.
# Add or remove extensions here as needed.
FILE_EXTENSIONS=(
    jpg jpeg png webp heic gif
    mp4 mov avi mkv
    pdf doc docx xls xlsx ppt pptx
)

############################################
# COPY BEHAVIOUR
############################################

# Show each file as it is copied.
VERBOSE=true

# If two files with the same name end up in the same batch folder,
# keep both by creating numbered backup names.
USE_BACKUP=true

############################################
# ARGUMENT VALIDATION
############################################

# Expected arguments:
#   1. Source directory
#   2. Destination directory
#   3. Batch size
if [ "$#" -ne 3 ]
then
    echo "Usage: $0 <source_directory> <destination_directory> <batch_size>"
    exit 1
fi

SOURCE_DIRECTORY="$1"
DESTINATION_DIRECTORY="$2"
BATCH_SIZE="$3"

# Make sure the source directory exists.
if [ ! -d "$SOURCE_DIRECTORY" ]
then
    echo "Error: source directory does not exist: $SOURCE_DIRECTORY"
    exit 1
fi

# Make sure batch size is a positive whole number.
if ! [[ "$BATCH_SIZE" =~ ^[1-9][0-9]*$ ]]
then
    echo "Error: batch_size must be a positive integer"
    exit 1
fi

# Create the destination directory if it does not already exist.
mkdir -p "$DESTINATION_DIRECTORY"

############################################
# BUILD COMMAND ARGUMENTS
############################################

# Build the fd arguments from the configured list of file extensions.
FD_ARGS=()
for extension in "${FILE_EXTENSIONS[@]}"
do
    FD_ARGS+=("-e" "$extension")
done

# Build the cp arguments from the configured copy options.
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

# Count how many files have been processed so far.
file_counter=0

# Stream matching files from fdfind into the loop using null separators.
# This safely handles spaces and other unusual characters in file names.
fdfind . "${FD_ARGS[@]}" "$SOURCE_DIRECTORY" -0 |
while IFS= read -r -d '' source_file
do
    # Work out which batch folder this file belongs in.
    # Integer division groups files into batches of BATCH_SIZE.
    batch_number=$((file_counter / BATCH_SIZE + 1))

    # Create folder names like:
    #   batch_0001
    #   batch_0002
    batch_folder=$(printf "%s/batch_%04d" "$DESTINATION_DIRECTORY" "$batch_number")

    # Create the batch folder if needed.
    mkdir -p "$batch_folder"

    # Copy the current file into the batch folder.
    cp "${CP_FLAGS[@]}" "$source_file" "$batch_folder/"

    # Increment the processed file count.
    file_counter=$((file_counter + 1))
done

echo
echo "Done."
echo "Files copied into:"
echo "  $DESTINATION_DIRECTORY"