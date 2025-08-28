# rsync deployments

This GitHub Action (amd64) deploys files in `GITHUB_WORKSPACE` to a remote folder via rsync over ssh. 

Use this action in a CD workflow which leaves deployable code in `GITHUB_WORKSPACE`.

The base-image [drinternet/rsync](https://github.com/JoshPiper/rsync-docker/) of this action is very small and is based on Alpine 3.22.1 (no cache) which results in fast deployments.

Alpine version: [3.22.1](https://alpinelinux.org/posts/Alpine-3.19.8-3.20.7-3.21.4-3.22.1-released.html)
Rsync version: [3.4.0-r0](https://download.samba.org/pub/rsync/NEWS#3.4.0)

---

## Inputs

- `switches`* - The first is for any initial/required rsync flags, eg: `-avzr --delete`

- `rsh` - Remote shell commands

- `legacy_allow_rsa_hostkeys` - Enables support for legacy RSA host keys on OpenSSH 8.8+. ("true" / "false")

- `path` - The source path. Defaults to GITHUB_WORKSPACE and is relative to it

- `remote_path`* - The deployment target path

- `remote_host`* - The remote host

- `remote_port` - The remote port. Defaults to 22

- `remote_user`* - The remote user

- `remote_key`* - The remote ssh key

- `remote_key_pass` - The remote ssh key passphrase (if any)

``* = Required``

## Required secret(s)

This action needs secret variables for the ssh private key of your key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. The secret variable should be set in the Github secrets section of your org/repo and then referenced as the  `remote_key` input.

> Always use secrets when dealing with sensitive inputs!

For simplicity, we are using `DEPLOY_*` as the secret variables throughout the examples.

## Current Version: 7.0.2

## Example usage

Simple:

```yml
name: DEPLOY
on:
  push:
    branches:
    - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.0.2
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

Advanced:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.0.2
      with:
        switches: -avzr --delete --exclude="" --include="" --filter=""
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_port: 5555
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

For better **security**, I suggest you create additional secrets for remote_host, remote_port, remote_user and remote_path inputs.

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.0.2
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

If your private key is passphrase protected you should use:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.0.2
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
        remote_key_pass: ${{ secrets.DEPLOY_KEY_PASS }}
```

---

#### Legacy RSA Hostkeys support for OpenSSH Servers >= 8.8+

If your remote OpenSSH Server still uses RSA hostkeys, then you have to
manually enable legacy support for this by using ``legacy_allow_rsa_hostkeys: "true"``.

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.0.2
      with:
        switches: -avzr --delete
        legacy_allow_rsa_hostkeys: "true"
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_KEY }}
```

See [#49](https://github.com/Burnett01/rsync-deployments/issues/49) and [#24](https://github.com/Burnett01/rsync-deployments/issues/24) for more information.

---

## Version 7.0.0 & 7.0.1 (DEPRECATED)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/7.0.0  (alpine 3.19.1)
- https://github.com/Burnett01/rsync-deployments/tree/7.0.1  (alpine 3.19.1)
  
---

## Version 6.0 (EOL)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/6.0  (alpine 3.17.2)

---

## Version 5.0, 5.1 & 5.2 & 5.x (EOL)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/5.0  (alpine 3.11.x)
- https://github.com/Burnett01/rsync-deployments/tree/5.1  (alpine 3.14.1)
- https://github.com/Burnett01/rsync-deployments/tree/5.2  (alpine 3.15.0)
- https://github.com/Burnett01/rsync-deployments/tree/5.2.1  (alpine 3.16.1)
- https://github.com/Burnett01/rsync-deployments/tree/5.2.2  (alpine 3.17.2)

---

## Version 4.0 & 4.1 (EOL)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/4.0
- https://github.com/Burnett01/rsync-deployments/tree/4.1

Version 4.0 & 4.1 use the ``drinternet/rsync:1.0.1`` base-image.

---

## Version 3.0 (EOL)

Check here: https://github.com/Burnett01/rsync-deployments/tree/3.0

Version 3.0 uses the ``alpine:latest`` base-image directly.<br>
Consider upgrading to 4.0 that uses a docker-image ``drinternet/rsync:1.0.1`` that is<br>
based on ``alpine:latest``and heavily optimized for rsync.

## Version 2.0 (EOL)

Check here: https://github.com/Burnett01/rsync-deployments/tree/2.0

Version 2.0 uses a larger base-image (``ubuntu:latest``).<br>
Consider upgrading to 3.0 for even faster deployments.

## Version 1.0 (EOL)

Check here: https://github.com/Burnett01/rsync-deployments/tree/1.0

Please note that version 1.0 has reached end of life state.

---

## Acknowledgements

+ This project is a fork of [Contention/rsync-deployments](https://github.com/Contention/rsync-deployments)
+ Base image [JoshPiper/rsync-docker](https://github.com/JoshPiper/rsync-docker)

---

## Media

This action was featured in multiple blogs across the globe:

> Disclaimer: The author & co-authors are not responsible for the content of the site-links below.

- https://elijahverdoorn.com/2020/04/14/automating-deployment-with-github-actions/

- https://www.vektor-inc.co.jp/post/github-actions-deploy/

- https://webpick.info/automatiser-avec-github-actions/

- https://matthias-andrasch.eu/blog/2021/tutorial-webseite-mittels-github-actions-deployment-zu-uberspace-uebertragen-rsync/

- https://jishuin.proginn.com/p/763bfbd38928

- https://cloud.tencent.com/developer/article/1786522

