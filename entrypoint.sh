#!/bin/bash

set -eu

# Set deploy key
SSH_PATH="$HOME/.ssh"

# Create .ssh dir if it doesn't exist
[ -d "$SSH_PATH" ] || mkdir "$SSH_PATH"

# Place deploy_key into .ssh dir
echo "$INPUT_REMOTE_KEY" > "$SSH_PATH/key"

# Set r+w to user only
chmod 600 "$SSH_PATH/key"

# Do deployment
sh -c "rsync $INPUT_SWITCHES -e 'ssh -i $SSH_PATH/key -o StrictHostKeyChecking=no $INPUT_RSH' $GITHUB_WORKSPACE/$INPUT_PATH $INPUT_REMOTE_USER@$INPUT_REMOTE_HOST:$INPUT_REMOTE_PATH"
