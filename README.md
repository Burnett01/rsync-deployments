# rsync deployments

This GitHub Action deploys files in `GITHUB_WORKSPACE` to a remote folder via rsync over ssh. 

Use this action in a CD workflow which leaves deployable code in `GITHUB_WORKSPACE`.

The underlaying base-image of the docker-image is very small (Alpine (no cache)) which results in fast deployments.

---

## Inputs

- `switches`* - The first is for any initial/required rsync flags, eg: `-avzr --delete`

- `rsh` - Remote shell commands

- `path` - The source path. Defaults to GITHUB_WORKSPACE

- `remote_path`* - The deployment target path

- `remote_host`* - The remote host

- `remote_port` - The remote port. Defaults to 22

- `remote_user`* - The remote user

- `remote_key`* - The remote ssh key

``* = Required``

## Required secret

This action needs a `DEPLOY_KEY` secret variable. This should be the private key part of a ssh key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. This should be set in the Github secrets section and then referenced as the  `remote_key` input.

## Example usage

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
      uses: burnett01/rsync-deployments@4.0
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
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: rsync deployments
      uses: burnett01/rsync-deployments@4.0
      with:
        switches: -avzr --delete --exclude="" --include="" --filter=""
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_port: 5555
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

For better security, I suggest you create additional secrets for remote_host, remote_port and remote_user inputs.

```
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: rsync deployments
      uses: burnett01/rsync-deployments@4.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

For maximum speed limit the checkout action (``actions/checkout@v1``) to a depth of 2:

```
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
      with:
        fetch-depth: 2
    - name: rsync deployments
      uses: burnett01/rsync-deployments@4.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

---

## Version 3.0

Looking for version 3.0?

Check here: https://github.com/Burnett01/rsync-deployments/tree/3.0

Version 3.0 uses the ``alpine:latest`` base-image directly.<br>
Consider upgrading to 4.0 that uses a docker-image ``drinternet/rsync:1.0.1`` that is<br>
based on ``alpine:latest``and heavily optimized for rsync.

## Version 2.0

Looking for version 2.0?

Check here: https://github.com/Burnett01/rsync-deployments/tree/2.0

Version 2.0 uses a larger base-image (``ubuntu:latest``).<br>
Consider upgrading to 3.0 for even faster deployments.

## Version 1.0 (EOL)

Looking for version 1.0?

Check here: https://github.com/Burnett01/rsync-deployments/tree/1.0

Please note that version 1.0 has reached end of life state.

---

## Acknowledgements

+ This project is a fork of [Contention/rsync-deployments](https://github.com/Contention/rsync-deployments)
+ Base image [JoshPiper/rsync-docker](https://github.com/JoshPiper/rsync-docker)


