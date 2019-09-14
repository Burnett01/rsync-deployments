#!/bin/sh

set -eu

# Set deploy key
SSH_PATH="$HOME/.ssh"
mkdir "$SSH_PATH"
echo "$DEPLOY_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"


# Do deployment
sh -c "rsync $INPUT_SWITCHES -e 'ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no' $INPUT_EXLUDES $GITHUB_WORKSPACE/ $INPUT_UPLOAD_PATH"
