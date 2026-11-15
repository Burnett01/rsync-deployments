#!/bin/sh

set -eu

LOG_LEVEL="${INPUT_LOGLEVEL:-ERROR}"

if [ "${INPUT_DEBUG:-false}" = "true" ]; then
    set -x
    LOG_LEVEL=""
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
echo "$INPUT_REMOTE_KEY" | SSH_PASS="$INPUT_REMOTE_KEY_PASS" agent-add

# Variables.
LEGACY_RSA_HOSTKEYS=""
if [ "${INPUT_LEGACY_ALLOW_RSA_HOSTKEYS:-false}" = "true" ]; then
    LEGACY_RSA_HOSTKEYS="-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa"
fi

STRICT_HOSTKEYS_CHECKING="-o StrictHostKeyChecking=no"
# If no 'known_hosts' input is provided and 'strict_hostkeys_checking: true',
# then use exisiting keyscan functionality. DEPRECATED: Will be no-op in next major.
if [[ -z "${INPUT_KNOWN_HOSTS:-}" && "${INPUT_STRICT_HOSTKEYS_CHECKING:-false}" = "true" ]]; then
    echo "::warning title=DEPRECATION::Input 'strict_hostkeys_checking' will be a no-op in the next major version! Use 'known_hosts'."

    STRICT_HOSTKEYS_CHECKING="-o UserKnownHostsFile=$HOME/.ssh/known_hosts -o StrictHostKeyChecking=yes"

    key="$(ssh-keyscan -p "$INPUT_REMOTE_PORT" "$INPUT_REMOTE_HOST" 2>/dev/null | sed '/^#/d')" || key=""
    if [ -n "$key" ]; then
        # fingerprint verification
        echo "$key" | ssh-keygen -lf -
        # add to known hosts
        echo "$key" | while IFS= read -r line; do hosts-add "$line"; done
    else
        echo "Warning: failed to fetch host key for remote host" >&2
        exit 1
    fi
# If 'known_hosts' is provided, strict hostkeys checking is auto enforced:
elif [ -n "${INPUT_KNOWN_HOSTS:-}" ]; then
    STRICT_HOSTKEYS_CHECKING="-o UserKnownHostsFile=$HOME/.ssh/known_hosts -o StrictHostKeyChecking=yes"

    if [ "$INPUT_REMOTE_PORT" = "22" ]; then
        host_pattern="$INPUT_REMOTE_HOST"
    else
        host_pattern="[$INPUT_REMOTE_HOST]:$INPUT_REMOTE_PORT"
    fi

    printf '%s\n' "$INPUT_KNOWN_HOSTS" | tr -d '\r' | while IFS= read -r line; do
        line="$(echo "$line" | awk '{$1=$1};1')"
        case "$line" in
            ''|'#'*) continue ;;
            ssh-*|ecdsa-*|sk-*) hosts-add "$host_pattern $line" ;;
            *) hosts-add "$line" ;;
        esac
    done

    if ! ssh-keygen -lf "$HOME/.ssh/known_hosts" >/dev/null 2>&1; then
        echo "Error: Input 'known_hosts' contains no valid host key" >&2
        exit 1
    fi
fi

RSH="ssh $LOG_LEVEL $STRICT_HOSTKEYS_CHECKING $LEGACY_RSA_HOSTKEYS -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"

# Deploy.
sh -c "rsync $INPUT_SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"

# Clean up.
source agent-stop "$GITHUB_ACTION"
source hosts-clear

exit 0
