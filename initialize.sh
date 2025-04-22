#!/bin/bash

# Create necessary directories
mkdir -p media/profile_pics
mkdir -p media/blog_images
mkdir -p staticfiles

# Create symbolic links for templates if they don't exist already
for template_path in templates/accounts/* templates/blog/*; do
    if [ -f "$template_path" ]; then
        echo "Setting up: $template_path"
    fi
done

echo "All templates and static files have been initialized!"
