#!/bin/bash

# Set the path to the objects directory
OBJECTS_DIR="../force-app/main/default/objects"

# Check if the objects directory exists
if [ ! -d "$OBJECTS_DIR" ]; then
    echo "Error: $OBJECTS_DIR directory not found!"
    exit 1
fi

# Create temp directory to store files we want to keep
TEMP_DIR=$(mktemp -d)

# Copy only the files we want to preserve
find "$OBJECTS_DIR" -path "*/fields/*__c.field-meta.xml" -exec cp --parents {} "$TEMP_DIR" \;
find "$OBJECTS_DIR" -name "*__c.object-meta.xml" -exec cp --parents {} "$TEMP_DIR" \;

# Remove everything in objects directory
rm -rf "$OBJECTS_DIR"/*

# Restore preserved files
cp -r "$TEMP_DIR"/* ../force-app/main/default/

# Cleanup temp directory
rm -rf "$TEMP_DIR"

echo "Cleanup completed. Only custom fields and object meta files preserved."