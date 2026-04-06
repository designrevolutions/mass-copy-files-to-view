# Copy Into Batches

A tiny Bash utility for gathering likely important files from a drive and copying them into flat batch folders for quick manual review.

## Why I made this

A common problem when reusing, wiping, or reinstalling a drive is that you may still have useful personal files scattered across many folders.

Typical examples include:

- images
- videos
- PDFs
- Word documents
- spreadsheets
- presentations

The first instinct is often either:

1. preserve the full original directory structure, or
2. dump everything into one single folder

Both approaches have drawbacks.

### Preserving the full structure

This is useful if you care about where each file originally lived, but it can make quick review slow and fiddly. You end up drilling through lots of nested folders just to inspect files.

### Copying everything into one folder

This is convenient at first, especially if the goal is simply to preview files before deciding what to keep or delete.

However, very large flat folders can become awkward. If you copy tens of thousands of files into a single directory, thumbnail generation, browsing, and previewing can become slower and more cluttered in GUI file managers and viewers.

## The idea behind this script

This script takes a middle-ground approach:

- it does **not** preserve the original directory structure
- it does **not** put everything into one giant folder
- instead, it copies files into flat **batch folders**

For example:

- `batch_0001`
- `batch_0002`
- `batch_0003`

Each folder contains up to a fixed number of files, such as 1000.

This keeps previewing practical while still making the copied files easy to browse.

## Intended use case

The intended workflow is:

1. identify likely useful file types from a source directory
2. copy them into batch folders
3. open the destination in a GUI viewer or file manager
4. preview the files quickly
5. decide what to keep and what to delete

This is especially useful when the goal is triage rather than archival perfection.

## File types currently included

The script currently searches for these extensions:

### Images
- `jpg`
- `jpeg`
- `png`
- `webp`
- `heic`
- `gif`

### Videos
- `mp4`
- `mov`
- `avi`
- `mkv`

### Documents
- `pdf`
- `doc`
- `docx`
- `xls`
- `xlsx`
- `ppt`
- `pptx`

You can edit the script if you want to add or remove extensions.

## Requirements

On Ubuntu, install `fd` like this:

```bash
sudo apt update
sudo apt install fd-find