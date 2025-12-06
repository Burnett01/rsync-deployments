#!/usr/bin/env bats

setup() {
    # Create dummy binaries for sourcing
    echo 'echo "source"' > source
    echo 'echo "agent started"' > agent-start
    echo 'echo "key added"' > agent-add
    chmod +x source agent-start agent-add

    # Create dummy rsync binary to capture its arguments
    echo 'echo "rsync $@"' > rsync
    chmod +x rsync

    PATH="$PWD:$PATH"
}

teardown() {
    rm -f source agent-start agent-add rsync ssh-keyscan hosts-add
}

@test "fails if INPUT_REMOTE_PATH is empty" {
    export INPUT_REMOTE_PATH=" "
    run ./entrypoint.sh
    [ "$status" -eq 1 ]
    [[ "${output}" == *"can not be empty"* ]]
}

@test "includes legacy RSA switches when allowed" {
    export INPUT_LEGACY_ALLOW_RSA_HOSTKEYS="true"
    export INPUT_REMOTE_PATH="remote/"
    export INPUT_REMOTE_KEY="dummy"
    export INPUT_REMOTE_KEY_PASS="dummy"
    export GITHUB_ACTION="dummy"
    export INPUT_SWITCHES="-avz"
    export INPUT_REMOTE_PORT="22"
    export INPUT_RSH=""
    export INPUT_PATH=""
    export INPUT_REMOTE_USER="user"
    export INPUT_REMOTE_HOST="localhost.local"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@localhost.local"
    export LOCAL_PATH="/tmp/"

    run ./entrypoint.sh

    [[ "${output}" == *"rsync -avz -e ssh -o StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -p 22  /tmp/ user@localhost.local:remote/"* ]]
}

@test "does not include legacy RSA switches when not allowed" {
    export INPUT_LEGACY_ALLOW_RSA_HOSTKEYS="false"
    export INPUT_REMOTE_PATH="remote/"
    export INPUT_REMOTE_KEY="dummy"
    export INPUT_REMOTE_KEY_PASS="dummy"
    export GITHUB_ACTION="dummy"
    export INPUT_SWITCHES="-avz"
    export INPUT_REMOTE_PORT="22"
    export INPUT_RSH=""
    export INPUT_PATH=""
    export INPUT_REMOTE_USER="user"
    export INPUT_REMOTE_HOST="localhost.local"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@localhost.local"
    export LOCAL_PATH="/tmp/"

    run ./entrypoint.sh
    [[ "${output}" == *"rsync -avz -e ssh -o StrictHostKeyChecking=no  -p 22  /tmp/ user@localhost.local:remote/"* ]]
}

@test "includes STRICT_HOSTKEYS_CHECKING switches when allowed" {
    # Set a fake HOME dir
    local -r HOME="/tmp"

    export INPUT_LEGACY_ALLOW_RSA_HOSTKEYS="false"
    export INPUT_STRICT_HOSTKEYS_CHECKING="true"
    export INPUT_REMOTE_PATH="remote/"
    export INPUT_REMOTE_KEY="dummy"
    export INPUT_REMOTE_KEY_PASS="dummy"
    export GITHUB_ACTION="dummy"
    export INPUT_SWITCHES="-avz"
    export INPUT_REMOTE_PORT="22"
    export INPUT_RSH=""
    export INPUT_PATH=""
    export INPUT_REMOTE_USER="user"
    export INPUT_REMOTE_HOST="localhost.local"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@localhost.local"
    export LOCAL_PATH="/tmp/"

    # Generate a mock key pair to test ssh-keyscan (entrypoint.sh:32)
    rm -f "$HOME/mockKeyPair" "$HOME/mockKeyPair.pub" \
    && ssh-keygen -t ed25519 -f "$HOME/mockKeyPair" -N '' -q -C '' \
    && mockPublicKey=$(< "$HOME/mockKeyPair.pub")

    # Create dummy ssh-keyscan binary to return $mockPublicKey
    echo "echo 'localhost.local $mockPublicKey #Mock 1'" > ssh-keyscan
    chmod +x ssh-keyscan

    # Create dummy hosts-add binary to capture its arguments
    echo 'echo "hosts-add $@"' > hosts-add
    chmod +x hosts-add
    
    run ./entrypoint.sh

    [[ "${output}" == *"hosts-add localhost.local ssh-ed25519"* ]]
    [[ "${output}" == *"rsync -avz -e ssh -o UserKnownHostsFile=/tmp/.ssh/known_hosts -o StrictHostKeyChecking=yes  -p 22  /tmp/ user@localhost.local:remote/"* ]]
}

@test "does not includes STRICT_HOSTKEYS_CHECKING switches when not allowed" {
    export INPUT_LEGACY_ALLOW_RSA_HOSTKEYS="false"
    export INPUT_STRICT_HOSTKEYS_CHECKING="false"
    export INPUT_REMOTE_PATH="remote/"
    export INPUT_REMOTE_KEY="dummy"
    export INPUT_REMOTE_KEY_PASS="dummy"
    export GITHUB_ACTION="dummy"
    export INPUT_SWITCHES="-avz"
    export INPUT_REMOTE_PORT="22"
    export INPUT_RSH=""
    export INPUT_PATH=""
    export INPUT_REMOTE_USER="user"
    export INPUT_REMOTE_HOST="localhost.local"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@localhost.local"
    export LOCAL_PATH="/tmp/"
    
    run ./entrypoint.sh

    [[ "${output}" == *"rsync -avz -e ssh -o StrictHostKeyChecking=no  -p 22  /tmp/ user@localhost.local:remote/"* ]]
}
