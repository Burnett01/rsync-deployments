#!/bin/sh

set -euo pipefail

if [ "${INPUT_DEBUG:-false}" = "true" ]; then
    set -x
fi

if [ -z "$(echo "$INPUT_REMOTE_PATH" | awk '{$1=$1};1')" ]; then
    echo "The remote_path can not be empty. see: github.com/Burnett01/rsync-deployments/issues/44"
    exit 1
fi

# Initialize SSH and known hosts.
source ssh-init
source hosts-init

# Start the SSH agent and load key.
source agent-start "$GITHUB_ACTION"
printf '%s' "$INPUT_REMOTE_KEY" | SSH_PASS="${INPUT_REMOTE_KEY_PASS}" agent-add >/dev/null 2>&1

# Variables.
LEGACY_RSA_HOSTKEYS=""
if [ "${INPUT_LEGACY_ALLOW_RSA_HOSTKEYS:-false}" = "true" ]; then
    LEGACY_RSA_HOSTKEYS="-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa"
fi

STRICT_HOSTKEYS_CHECKING="-o StrictHostKeyChecking=no"
if [ "${INPUT_STRICT_HOSTKEYS_CHECKING:-false}" = "true" ]; then
    STRICT_HOSTKEYS_CHECKING="-o StrictHostKeyChecking=yes"

    key="$(ssh-keyscan -p "$INPUT_REMOTE_PORT" "$INPUT_REMOTE_HOST" 2>/dev/null)" || key=""
    if [ -n "$key" ]; then
        # fingerprint verification
        echo "$key" | ssh-keygen -lf -
        # add to known hosts
        echo "$key" | while IFS= read -r line; do hosts-add "$line"; done
    else
        echo "Warning: failed to fetch host key for $INPUT_REMOTE_HOST" >&2
        exit 1
    fi
fi

RSH="ssh $STRICT_HOSTKEYS_CHECKING $LEGACY_RSA_HOSTKEYS -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"

# Deploy.
sh -c "rsync $INPUT_SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"

# Clean up.
source agent-stop "$GITHUB_ACTION"
source hosts-clear

exit 0
