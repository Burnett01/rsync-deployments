# rsync deployments

Forked from [Contention/rsync-deployments](https://github.com/Contention/rsync-deployments)


This GitHub Action deploys files in `GITHUB_WORKSPACE` to a folder on a server via rsync over ssh. 

Use this action in a build/test workflow which leaves deployable code in `GITHUB_WORKSPACE`.

# Inputs

- `swtiches`* - The first is for any initial/required rsync flags, eg: `-avzr --delete`

- `rsh` - Remote shell commands, eg for using a different SSH port: `"-p ${{ secrets.DEPLOY_PORT }}"`

- `path` - The source path. Defaults to GITHUB_WORKSPACE

- `remote_path`* - The deployment target path

- `remote_host`* - The remote host

- `remote_user`* - The remote user

- `remote_key`* - The remote ssh key

``* = Required``

# Required secret

This action needs a `DEPLOY_KEY` secret variable. This should be the private key part of a ssh key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. This should be set in the Github secrets section and then referenced as the  `remote_key` input.

# Example usage

Simple:

```
name: DEPLOY
on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: rsync deployments
      uses: burnett01/rsync-deployments@1.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

Advanced:

```
name: DEPLOY
on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: rsync deployments
      uses: burnett01/rsync-deployments@1.0
      with:
        switches: -avzr --delete --exclude="" --include="" --filter=""
        rsh: "-p ${{ secrets.DEPLOY_PORT }}"
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

For better security, I suggest you create additional secrets for remote_host and remote_user inputs.

```
name: DEPLOY
on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: rsync deployments
      uses: burnett01/rsync-deployments@1.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
```
