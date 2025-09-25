#!/bin/bash
set -e

max_trimmed_width=0
max_trimmed_height=0
dims_temp_file=$(mktemp)

find "$1" -type f -name "*.png" | while read img_path; do
    read width height <<< $(identify -format "%w %h" "$img_path")
    if (( width > max_trimmed_width )); then
        max_trimmed_width=$width
    fi
    if (( height > max_trimmed_height )); then
        max_trimmed_height=$height
    fi

    echo "$max_trimmed_width $max_trimmed_height" > "$dims_temp_file"
done
cat "$dims_temp_file"
rm "$dims_temp_file"