#!/bin/sh

# Exit the script on any error, undefined variable, or in a pipeline.
set -euo pipefail

# Check if the remote path is empty.
if [ -z "$(echo "$INPUT_REMOTE_PATH" | awk '{$1=$1};1')" ]; then
    printf "Error: The remote_path cannot be empty. See: github.com/Burnett01/rsync-deployments/issues/44\n"
    exit 1
fi

# Start the SSH agent and load the key.
if ! source agent-start "$GITHUB_ACTION"; then
    printf "Error: SSH agent could not be started.\n"
    exit 1
fi

if ! echo "$INPUT_REMOTE_KEY" | SSH_PASS="$INPUT_REMOTE_KEY_PASS" agent-add; then
    printf "Error: SSH key could not be added.\n"
    exit 1
fi

# Optionally add Legacy RSA Hostkeys.
LEGACY_RSA_HOSTKEYS=""
if [ "$INPUT_LEGACY_ALLOW_RSA_HOSTKEYS" = "true" ]; then
    LEGACY_RSA_HOSTKEYS="-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa"
fi

# Define variables.
SWITCHES="$INPUT_SWITCHES"
RSH="ssh -o StrictHostKeyChecking=no $LEGACY_RSA_HOSTKEYS -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"

# Perform deployment.
if ! sh -c "rsync $SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"; then
    printf "Error: Deployment failed.\n"
    exit 1
fi

printf "Deployment completed successfully.\n"
