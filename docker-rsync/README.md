# Scripts

Shell-scripts to help with managing SSH agents and known hosts files.

### SSH Management

#### ssh-init
This command create the ``$HOME/.ssh`` folder with default permissions ``700``.

### SSH-Agent Management

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

#### agent-askpass
This command is called by ssh-add when the [SSH_ASKPASS](https://man.openbsd.org/ssh-add.1#ENVIRONMENT) variable is set active. The command returns the SSH_PASS to [ssh-askpass(1)](https://man.openbsd.org/ssh-askpass.1).

This command is ignored by ssh-add if the key does not require a passphrase.

### known_hosts management

#### hosts-init
This command creates the known_hosts file (``$HOME/.ssh/known_hosts``) with default permission ``600``.

#### hosts-add
This command adds an entry to the known hosts file, and ensures its permissions are correct. It takes one argument, which is the new key to add.

#### hosts-clear
This command truncates the known_hosts file.
