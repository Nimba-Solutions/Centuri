#!/bin/bash

# Create a temporary file for JSON building
json_file="flexipage_usage.json"
echo "{" > $json_file

first=true

for file in force-app/main/default/flexipages/*.flexipage-meta.xml; do
    name=$(basename "$file" .flexipage-meta.xml)
    
    # Search for references in objects directory and subdirectories
    if grep -r "$name" force-app/main/default/objects/ > /dev/null 2>&1; then
        is_used="true"
    else
        is_used="false"
        # Delete unused flexipage
        rm "$file"
    fi
    
    # Add comma for all but first entry
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> $json_file
    fi
    
    # Write entry to JSON
    echo "    \"$name\": $is_used" >> $json_file
done

echo "}" >> $json_file