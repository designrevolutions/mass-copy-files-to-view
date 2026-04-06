# Copy Into Batches

A small Bash CLI tool to collect useful files from a directory and organise them into manageable batch folders for quick preview and review.

---

## Quick Start

Make the script executable:

```bash
chmod +x copy_into_batches.sh
```

Run it:

### Example 1 – Use defaults

```bash
./copy_into_batches.sh
```

### Example 2 – Custom source and destination

```bash
./copy_into_batches.sh \
  --source "/media/drive" \
  --dest "$HOME/output"
```

### Example 3 – Smaller batch size + quiet mode

```bash
./copy_into_batches.sh \
  --source "/media/drive" \
  --batch-size 500 \
  --quiet
```

---

## Why this exists

When preparing to wipe or reuse a drive, important files are often scattered across many directories.

Two common approaches:

### Preserve original structure

* Keeps organisation
* Slow to browse and review

### Copy everything into one folder

* Quick access
* Large folders (10k+ files) become slow and messy

---

## This tool’s approach

A middle-ground solution:

* Flatten files (ignore original structure)
* Split into batch folders

Example:

```
batch_0001/
batch_0002/
batch_0003/
```

Each folder contains a fixed number of files (default: 1000).

This keeps previewing fast and manageable.

---

## Features

* Safe handling of filenames (spaces, special characters)
* Efficient streaming (does not load everything into memory)
* Duplicate-safe copying
* Configurable via CLI flags
* Sensible defaults (can run without any arguments)

---

## Requirements

Install `fd` (Ubuntu uses `fdfind`):

```bash
sudo apt update
sudo apt install fd-find
```

Optional alias:

```bash
alias fd=fdfind
```

---

## Usage

```bash
./copy_into_batches.sh [OPTIONS]
```

---

## Options

| Option               | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| `--source <dir>`     | Source directory (default: `$HOME`)                           |
| `--dest <dir>`       | Destination directory (default: `~/review_backup_candidates`) |
| `--batch-size <num>` | Files per folder (default: 1000)                              |
| `--quiet`            | Disable verbose output                                        |
| `--no-backup`        | Disable duplicate-safe naming                                 |
| `--help`             | Show help                                                     |

---

## Workflow

1. Run the script
2. Open destination in file manager or viewer
3. Preview files
4. Keep or delete

Designed for quick triage, not archival accuracy.

---

## File types included

### Images

jpg, jpeg, png, webp, heic, gif

### Videos

mp4, mov, avi, mkv

### Documents

pdf, doc, docx, xls, xlsx, ppt, pptx

---

## Duplicate handling

Uses:

```bash
cp --backup=numbered
```

Duplicates become:

```
file.jpg
file.jpg.~1~
file.jpg.~2~
```

---

## How it works

* `fdfind` finds matching files
* results are streamed (not stored in memory)
* loop processes files one at a time
* files are grouped into batches using integer division

---

## Example output

```
review_backup_candidates/
├── batch_0001/
├── batch_0002/
├── batch_0003/
```

---

## Future ideas

* Split by file type
* Dry-run mode
* Progress stats
* Parallel copying
* More robust CLI parsing

---

## Summary

This tool is designed for one job:

Quickly gather and review important files before deleting or wiping a drive.

It prioritises speed, simplicity, and usability over perfect structure.