#!/bin/sh

if [ -z "$(awk '{$1=$1};1' <<< "$INPUT_REMOTE_PATH")" ]; then
    echo "The remote_path can not be empty. see: github.com/Burnett01/rsync-deployments/issues/44"
    exit 1
fi

# Start the SSH agent and load key.
source agent-start "$GITHUB_ACTION"
echo "$INPUT_REMOTE_KEY" | SSH_PASS="$INPUT_REMOTE_KEY_PASS" agent-add

# Add strict errors.
set -eu

# Variables.
SWITCHES="$INPUT_SWITCHES"
RSH="ssh -o StrictHostKeyChecking=no -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"

# Deploy.
sh -c "rsync $SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"
