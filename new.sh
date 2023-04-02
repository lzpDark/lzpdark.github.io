#!/bin/bash

# Get the title for the new post from the first argument
title=$1

# If no title was provided, exit with an error message
if [ -z "$title" ]; then
  echo "Error: Please provide a title for the new post"
  exit 1
fi

# custom date for the new post
date=$(date +'%Y-%m-%d')

# Get the optional category for the new post from the third argument, if provided
if [ -z "$2" ]; then
  category=""
else
  category="categories: $2"
fi

# Generate the filename from the post title and date
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr '[:space:]' '-' | sed 's/-$//')
filename=$(date -d "$date" +'%Y-%m-%d')-$slug".md"

# Construct the YAML front matter for the new post
front_matter=$(echo -e "---\nlayout: post\ntitle: \"$title\"\ndate: $date\n$category\n---")

# Create the new post file with the front matter
echo -e "$front_matter\n" > "_posts/$filename"
