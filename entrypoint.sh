#!/bin/sh

set -eu

# Set deploy key
SSH_PATH="$HOME/.ssh"
# Create .ssh dir if it doesn't exist
if [ ! -d "$SSH_PATH" ]; then
  mkdir "$SSH_PATH"
fi
# Place deploy_key into .ssh dir
echo "$DEPLOY_KEY" > "$SSH_PATH/deploy_key"
# Set r+w to user only
chmod 600 "$SSH_PATH/deploy_key"

# Do deployment
sh -c "rsync $INPUT_SWITCHES -e 'ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no' $INPUT_EXCLUDES $GITHUB_WORKSPACE/$INPUT_PATH $INPUT_UPLOAD_PATH"
