#!/bin/bash
if [ -z "$2" ] ; then
    echo "usage: $0 <path to images> <output dir>"
    exit 1
fi

# Make sure output directory exists
mkdir -p "$2"
output_dir="$(realpath $2)"

# Operate from the image directory
cd "$1"

echo "Step 1: Trimming images and finding max dimensions across all subdirectories..."
dims_temp_file=$(mktemp)
trimmed_dir=$(mktemp -d)

# Find the maximum width and height among all trimmed images across all directories
max_trimmed_width=0
max_trimmed_height=0

let image_count=$(find . -type f -name "*.png" | wc -l)
let i=0

# Use find to locate all PNG files recursively
let current_image=0
find . -type f -name "*.png" | while read img_path; do
  let i=$i+1
  echo -ne "Trimming image $i/$image_count...\r"

  # Get the directory of the current image
  dir_name=$(dirname "$img_path")

  # Create a corresponding output directory in the '$output_dir' root
  mkdir -p "$trimmed_dir/$dir_name"

  # Store the 
  file_name=$(basename "$img_path")
  trimmed_img="$trimmed_dir/$dir_name/$file_name"

  magick "$img_path" -trim "$trimmed_img"

  # Get the dimensions of the trimmed image
  read width height <<< $(identify -format "%w %h" "$trimmed_img")

  # Update the maximum dimensions
  if (( width > max_trimmed_width )); then
    max_trimmed_width=$width
  fi
  if (( height > max_trimmed_height )); then
    max_trimmed_height=$height
  fi

  echo "$max_trimmed_width $max_trimmed_height" > "$dims_temp_file"
done
echo ""

read final_canvas_width final_canvas_height < "$dims_temp_file"
rm "$dims_temp_file"

echo "Canvas width: $final_canvas_width"
echo "Canvas height: $final_canvas_height"

echo "Step 2: Scaling and padding images to a uniform size, preserving directory structure..."

# Process the images again, this time creating the final versions
let i=0
cd $trimmed_dir
find . -type f -name "*.png" -print0 | while IFS= read -r -d $'\0' img_path; do
  let i=$i+1
  echo -ne "Trimming image $i/$image_count...\r"

  # Get the directory of the current image
  dir_name=$(dirname "$img_path")

  # Create a corresponding output directory in the '$output_dir' root
  mkdir -p "$output_dir/$dir_name"

  # Define the output file path
  file_name=$(basename "$img_path")
  output_path="$output_dir/$dir_name/$file_name"

  # Scale the trimmed image based on the maximum height
  magick "$img_path" -resize "x${final_canvas_height}" "$img_path"

  # Pad the scaled image to the final canvas size and save to the new directory
  magick "$img_path" -background transparent -gravity center -extent "${final_canvas_width}x${final_canvas_height}" "$output_path"
done
rm -r "$trimmed_dir"
echo ""

echo "Processing complete. The new, uniform sprites are in the '$output_dir/' directory."
