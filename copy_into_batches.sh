#!/usr/bin/env bash

# Enable strict mode:
# - exit on error
# - fail on undefined variables
# - catch pipeline errors
set -euo pipefail

############################################
# DEFAULT CONFIGURATION
############################################

DEFAULT_SOURCE_DIRECTORY="$HOME"
DEFAULT_DESTINATION_DIRECTORY="$HOME/review_backup_candidates"
DEFAULT_BATCH_SIZE=1000

FILE_EXTENSIONS=(
    jpg jpeg png webp heic gif
    mp4 mov avi mkv
    pdf doc docx xls xlsx ppt pptx
)

VERBOSE=true
USE_BACKUP=true

############################################
# HELP
############################################

show_help()
{
    cat << EOF
Usage:
  $0 [OPTIONS]

Options:
  --source <dir>        Source directory (default: $DEFAULT_SOURCE_DIRECTORY)
  --dest <dir>          Destination directory (default: $DEFAULT_DESTINATION_DIRECTORY)
  --batch-size <num>    Files per batch folder (default: $DEFAULT_BATCH_SIZE)

  --quiet               Disable verbose output
  --no-backup           Disable duplicate-safe naming

  --help                Show this help message

Example:
  $0 --source "/media/drive" --dest "$HOME/output" --batch-size 500
EOF
}

############################################
# ARG PARSING
############################################

SOURCE_DIRECTORY="$DEFAULT_SOURCE_DIRECTORY"
DESTINATION_DIRECTORY="$DEFAULT_DESTINATION_DIRECTORY"
BATCH_SIZE="$DEFAULT_BATCH_SIZE"

while [ "$#" -gt 0 ]
do
    case "$1" in
        --source)
            SOURCE_DIRECTORY="$2"
            shift 2
            ;;
        --dest)
            DESTINATION_DIRECTORY="$2"
            shift 2
            ;;
        --batch-size)
            BATCH_SIZE="$2"
            shift 2
            ;;
        --quiet)
            VERBOSE=false
            shift
            ;;
        --no-backup)
            USE_BACKUP=false
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage."
            exit 1
            ;;
    esac
done

############################################
# VALIDATION
############################################

if [ ! -d "$SOURCE_DIRECTORY" ]
then
    echo "Error: source directory does not exist: $SOURCE_DIRECTORY"
    exit 1
fi

if ! [[ "$BATCH_SIZE" =~ ^[1-9][0-9]*$ ]]
then
    echo "Error: batch-size must be a positive integer"
    exit 1
fi

mkdir -p "$DESTINATION_DIRECTORY"

############################################
# BUILD COMMANDS
############################################

FD_ARGS=()
for ext in "${FILE_EXTENSIONS[@]}"
do
    FD_ARGS+=("-e" "$ext")
done

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
# MAIN LOGIC
############################################

file_counter=0

# Stream files safely using null separation
fdfind . "${FD_ARGS[@]}" "$SOURCE_DIRECTORY" -0 |
while IFS= read -r -d '' source_file
do
    # Group files into batch folders using integer division
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