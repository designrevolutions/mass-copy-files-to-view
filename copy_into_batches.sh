#!/usr/bin/env bash

# Copy selected file types from a source directory into batch folders.
#
# Why this exists:
# - Sometimes you want to wipe or repurpose a drive
# - Before doing that, you want a quick way to gather likely important files
# - Preserving the full original structure is not always necessary
# - But putting tens of thousands of files into one folder can make previewing awkward
#
# This script solves that by:
# - finding useful file types
# - copying them into flat batch folders
# - limiting each batch folder to a fixed number of files
#
# Example usage:
#   chmod +x copy_into_batches.sh
#   ./copy_into_batches.sh "/media/user/OldDrive/Users/SomeUser" "$HOME/review_backup_candidates"
#
# Optional custom batch size:
#   BATCH_SIZE=1000 ./copy_into_batches.sh "/source/path" "$HOME/review_backup_candidates"

set -euo pipefail

# Validate arguments.
if [ "$#" -ne 2 ]
then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIRECTORY="$1"
DESTINATION_DIRECTORY="$2"

# Allow batch size override via environment variable.
BATCH_SIZE="${BATCH_SIZE:-1000}"

# Make sure the source exists.
if [ ! -d "$SOURCE_DIRECTORY" ]
then
    echo "Error: source directory does not exist: $SOURCE_DIRECTORY"
    exit 1
fi

# Create the destination directory if needed.
mkdir -p "$DESTINATION_DIRECTORY"

# Counter used to decide which batch folder to place the next file into.
file_counter=0

# Use null-separated output from fd/fdfind to safely handle spaces and unusual characters.
#
# Notes:
# - On Ubuntu, the command is often named `fdfind` instead of `fd`
# - If you have aliased `fd=fdfind`, you can replace `fdfind` below with `fd`
fdfind . \
    -e jpg -e jpeg -e png -e webp -e heic -e gif \
    -e mp4 -e mov -e avi -e mkv \
    -e pdf -e doc -e docx -e xls -e xlsx -e ppt -e pptx \
    "$SOURCE_DIRECTORY" -0 |
while IFS= read -r -d '' source_file
do
    # Work out the batch number.
    batch_number=$((file_counter / BATCH_SIZE + 1))

    # Create batch folder names like:
    # batch_0001
    # batch_0002
    batch_folder=$(printf "%s/batch_%04d" "$DESTINATION_DIRECTORY" "$batch_number")

    mkdir -p "$batch_folder"

    # Copy the file into the batch folder.
    #
    # --backup=numbered means:
    # - if a file with the same name already exists in this batch folder,
    #   keep both copies by creating names like:
    #   file.jpg.~1~
    #   file.jpg.~2~
    #
    # -v prints each copied file so you can see activity while it runs
    cp -v --backup=numbered "$source_file" "$batch_folder/"

    file_counter=$((file_counter + 1))
done

echo
echo "Done."
echo "Files copied into batch folders under:"
echo "  $DESTINATION_DIRECTORY"