#!/bin/bash

# Enable logging
exec 1> >(tee cleanup.log) 2>&1
echo "Starting cleanup at $(date)"

OBJECTS_DIR="../force-app/main/default/objects"

# Create temp directory
TEMP_DIR=$(mktemp -d)
echo "Created temp dir: $TEMP_DIR"

echo "Copying custom fields without a namespace..."
cd "$OBJECTS_DIR" || exit
find . -path "*/fields/*__c.field-meta.xml" | grep -v "/fields/[A-Z][A-Z0-9]*__" | while read -r file; do
    mkdir -p "$TEMP_DIR/$(dirname "$file")"
    cp "$file" "$TEMP_DIR/$file"
done

echo "Copying objects without a namespace..."
find . -name "*__c.object-meta.xml" | grep -v "/[A-Z][A-Z0-9]*__" | while read -r file; do
    mkdir -p "$TEMP_DIR/$(dirname "$file")"
    cp "$file" "$TEMP_DIR/$file"
done

echo "Copying compactLayouts..."
find . -type d -name "compactLayouts" | while read -r dir; do
    mkdir -p "$TEMP_DIR/$(dirname "$dir")"
    cp -r "$dir" "$TEMP_DIR/$(dirname "$dir")"
done

echo "Copying recordTypes..."
find . -type d -name "recordTypes" | while read -r dir; do
    mkdir -p "$TEMP_DIR/$(dirname "$dir")"
    cp -r "$dir" "$TEMP_DIR/$(dirname "$dir")"
done

echo "Clearing objects directory..."
rm -rf ./*

echo "Restoring preserved files..."
cp -r "$TEMP_DIR/." .

rm -rf "$TEMP_DIR"
echo "Cleanup completed at $(date)"