#!/bin/bash

# Sets a personalized greeting
# Configures SQLite options
# Creates run aliases
# Author: Matt Rudge

# Check if the GITPOD_GIT_USER_NAME environment variable is set
if [ -z "$GITPOD_GIT_USER_NAME" ]; then
  echo "Error: GITPOD_GIT_USER_NAME is not set. Please set your Git user name in Gitpod."
  exit 1
fi

# Replace placeholder with the actual Gitpod user name in README.md
sed -i "s/USER_NAME/$GITPOD_GIT_USER_NAME/g" "${GITPOD_REPO_ROOT}/README.md"

echo "Creating .sqliterc file for SQLite configuration"

# Create the .sqliterc file with configuration options
cat << EOF > ~/.sqliterc
.headers on
.mode column
EOF

echo "Your workspace is ready to use. Happy coding!"
