#!/bin/bash

# Prompt the user for the post title
read -p "Enter the post title: " title

# Generate the filename from the title
filename=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Generate the current date in YYYY-MM-DD format
date=$(date +%Y-%m-%d)

# Create the Markdown file with the necessary front matter
echo "---" > "_posts/$date-$filename.md"
echo "layout: post" >> "_posts/$date-$filename.md"
echo "title: \"$title\"" >> "_posts/$date-$filename.md"
echo "date: $date" >> "_posts/$date-$filename.md"
echo "---" >> "_posts/$date-$filename.md"
