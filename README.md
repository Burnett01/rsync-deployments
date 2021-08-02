# rsync docker image.

A simple alpine based docker image for rsync and ssh deployments.

## Using this image
This image has two primary uses. Firstly, as a deployment image for GitLab CI runs. Secondly, as a base image for other images.

### gitlab-ci.yml
```yml
image: drinternet/rsync:1.0.1
...
before_script:
  - source agent-autostart "$CI_PROJECT_ID-$CI_PIPELINE_ID-$_CI_CONCURRENT_ID"
  - hosts-add "$SSH_KNOWN_HOSTS"

after_script:
  - agent-stop "$CI_PROJECT_ID-$CI_PIPELINE_ID-$_CI_CONCURRENT_ID"
```

### Base image in a `Dockerfile
```dockerfile
FROM drinternet/rsync:1.0.1
COPY some/file or/whatever
```

## Inbuilt commands.

This base image also includes a few shell scripts, to help with managing SSH agents and known hosts files.
### SSH Agent Management
#### agent-start
This command starts the SSH agent, if it isn't already started (SSH_AGENT_PID set or ssh agent ID file found).
It takes one optional argument, for the name of the agent to be started. Defaults to "default".
This program needs to be source'd to work correctly.
`source agent-start "default"`

#### agent-stop
This command stops the SSH agent, if it is started (SSH_AGENT_PID set or ssh agent ID file found).
It takes one optional argument, for the name of the agent to be stopped. Defaults to "default".
`agent-stop "my-agent-name"`

#### agent-add
This command adds a key to the currently running SSH agent. The key is taken from stdin, and the agent used is that in SSH_AGENT_PID.

#### agent-autostart
This command starts the SSH agent and loads the private key from the "SSH_PRIVATE_KEY" environment var. The command takes one optional argument, for the name of the agent to be started. Defaults to "default".
As with agent-start, this command needs to be sourced.

#### agent-askpass
This command is called by ssh-add when the [SSH_ASKPASS](https://man.openbsd.org/ssh-add.1#ENVIRONMENT) variable is set active. The command returns the SSH_PASS to [ssh-askpass(1)](https://man.openbsd.org/ssh-askpass.1).

This command is ignored by ssh-add if the key does not require a passphrase.

### known_hosts management
#### hosts-clear
This command truncates the known_hosts file and sets its permissions.

#### hosts-add
This command adds an entry to the known hosts file, and ensures its permissions are correct. It takes one argument, which is the new key to add.

## Tags
Most numeric tags are simple version numbers for the various scripts. However, there are some special tags.
staging: The latest build from the master branch.
*-rc: release candidate builds, nearly ready but might contain small changes.
*-beta: beta builds, still need testing but shouldn't change too much.
*-alpha: alpha builds, which are likely to change.

## Example gitlab-ci.yml
```yml
image: drinternet/rsync:1.0.1

stages:
  - deploy

before_script:
  - source agent-autostart "$CI_PROJECT_ID-$CI_PIPELINE_ID-$_CI_CONCURRENT_ID"
  - hosts-add "$SSH_KNOWN_HOSTS"

after_script:
  - agent-stop "$CI_PROJECT_ID-$CI_PIPELINE_ID-$_CI_CONCURRENT_ID"

deploy:
  stage: deploy
  script:
    - rsync -zrSlhaO --chmod=D2775,F664 --delete-after . $FTP_USER@$FTP_HOST:/var/www/deployment/
```

## Using with passphrase protected key

You can supply a passphrase with ``SSH_PASS`` to ``agent-add``, ``agent-start`` or ``agent-autostart``.

```
SSH_PASS="THE_PASSPHRASE" agent-add
```
