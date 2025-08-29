#!/usr/bin/env bats

setup() {
    # Create a dummy ssh agent and agent-add for sourcing
    echo 'echo "agent started"' > agent-start
    echo 'echo "key added"' > agent-add
    chmod +x agent-start agent-add

    # Create a dummy rsync to capture its arguments
    echo 'echo "rsync $@"' > rsync
    chmod +x rsync

    PATH="$PWD:$PATH"
}

teardown() {
    rm -f agent-start agent-add rsync
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
    export INPUT_REMOTE_HOST="host"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@host"
    export LOCAL_PATH="/tmp/"

    run ./entrypoint.sh
    [[ "${output}" == *"HostKeyAlgorithms=+ssh-rsa"* ]]
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
    export INPUT_REMOTE_HOST="host"
    export GITHUB_WORKSPACE="/tmp"
    export DSN="user@host"
    export LOCAL_PATH="/tmp/"

    run ./entrypoint.sh
    [[ "${output}" != *"HostKeyAlgorithms=+ssh-rsa"* ]]
}
