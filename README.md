# rsync deployments

[![CI - Validating, Linting, Testing](https://github.com/Burnett01/rsync-deployments/actions/workflows/ci-validating-linting-testing.yml/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/ci-validating-linting-testing.yml) 
[![Snyk Docker Vulnerability Scan](https://github.com/Burnett01/rsync-deployments/actions/workflows/snyk-docker-vulnerability-scan.yml/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/snyk-docker-vulnerability-scan.yml) 
[![CodeQL](https://github.com/Burnett01/rsync-deployments/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/github-code-scanning/codeql) 
[![Dependabot Updates](https://github.com/Burnett01/rsync-deployments/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/dependabot/dependabot-updates)


This cross-platform GitHub Action deploys files in [`path`](#inputs) (relative to  `GITHUB_WORKSPACE`) to a remote folder via rsync over ssh. 

Use this action in a CD workflow which leaves deployable code in `GITHUB_WORKSPACE`, such [actions/checkout](https://github.com/actions/checkout).

The base-image of this action is very small and based on **Alpine 3.23.0** (no cache) which results in fast deployments.

Alpine version: [3.23.0](https://www.alpinelinux.org/posts/Alpine-3.23.0-released.html)
Rsync version: [3.4.1-r1](https://download.samba.org/pub/rsync/NEWS#3.4.1)

---

## Inputs

- `debug`* - Whether to enable debug output. ("true" / "false") - Default: "false"

- `switches`* - The first is for any initial/required rsync flags, eg: `-avzr --delete`

- `rsh` - Remote shell commands

- `strict_hostkeys_checking` - Enables support for strict hostkeys (fingerprint) checking. ("true" / "false") - Default: "false"

- `legacy_allow_rsa_hostkeys` - Enables support for legacy RSA host keys on OpenSSH 8.8+. ("true" / "false") - Default: "false"

- `path` - The source path. Defaults to GITHUB_WORKSPACE and is relative to it

- `remote_path`* - The deployment target path

- `remote_host`* - The remote host

- `remote_port` - The remote port. Defaults to 22

- `remote_user`* - The remote user

- `remote_key`* - The remote ssh private key

- `remote_key_pass` - The remote ssh private key passphrase (if any)

``* = Required``

## Required secret(s)

This action needs secret variables for the ssh private key of your key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. The secret variable should be set in the Github secrets section of your org/repo and then referenced as the  `remote_key` input.

> Always use secrets when dealing with sensitive inputs!

For simplicity, we are using `REMOTE_*` as the secret variables throughout the examples.

## Current Version: v8 (8.0.0)

### Release channels:

| Version | Purpose          | Immutable  | 
| ------- | ------------------ | ------------------ | 
| ``v8``  |  latest release (pointer to 8.x.x) | no, points to latest MINOR,PATCH |
| 8.0.0  | latest major release | yes |
| 7.1.0   | previous release | yes |

Check [SECURITY.md](SECURITY.md) for support cycles.

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
    - uses: actions/checkout@v6
    - name: rsync deployments
      uses: burnett01/rsync-deployments@v8
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_user: debian
        remote_key: ${{ secrets.REMOTE_PRIVATE_KEY }}
```

Advanced:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v6
    - name: rsync deployments
      uses: burnett01/rsync-deployments@v8
      with:
        switches: -avzr --delete --exclude="" --include="" --filter=""
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_port: 5555
        remote_user: debian
        remote_key: ${{ secrets.REMOTE_PRIVATE_KEY }}
```

For better **security**, I suggest you create additional secrets for remote_host, remote_port, remote_user and remote_path inputs.

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v6
    - name: rsync deployments
      uses: burnett01/rsync-deployments@v8
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.REMOTE_PATH }}
        remote_host: ${{ secrets.REMOTE_HOST }}
        remote_port: ${{ secrets.REMOTE_PORT }}
        remote_user: ${{ secrets.REMOTE_USER }}
        remote_key: ${{ secrets.REMOTE_PRIVATE_KEY }}
```

If your private key is passphrase protected you should use:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v6
    - name: rsync deployments
      uses: burnett01/rsync-deployments@v8
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.REMOTE_PATH }}
        remote_host: ${{ secrets.REMOTE_HOST }}
        remote_port: ${{ secrets.REMOTE_PORT }}
        remote_user: ${{ secrets.REMOTE_USER }}
        remote_key: ${{ secrets.REMOTE_PRIVATE_KEY }}
        remote_key_pass: ${{ secrets.REMOTE_PRIVATE_KEY_PASS }}
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
    - uses: actions/checkout@v6
    - name: rsync deployments
      uses: burnett01/rsync-deployments@v8
      with:
        switches: -avzr --delete
        legacy_allow_rsa_hostkeys: "true"
        path: src/
        remote_path: ${{ secrets.REMOTE_PATH }}
        remote_host: ${{ secrets.REMOTE_HOST }}
        remote_port: ${{ secrets.REMOTE_PORT }}
        remote_user: ${{ secrets.REMOTE_USER }}
        remote_key: ${{ secrets.REMOTE_PRIVATE_KEY }}
```

See [#49](https://github.com/Burnett01/rsync-deployments/issues/49) and [#24](https://github.com/Burnett01/rsync-deployments/issues/24) for more information.

**Note:** Only use this if necessary. It's recommended to upgrade your remote OpenSSH server instead.

--

## Advanced Rsync switches/flags/options

For advanced rsync configuration options and switches, refer to the [rsync manual](https://linux.die.net/man/1/rsync).

---

## Troubleshooting

### SSH Permission Denied Errors

If you encounter "Permission denied (publickey,password)" errors, here are the most common solutions:

#### 1. SSH Key Setup

Ensure your SSH key pair is correctly generated and configured:

```bash
# Generate a new SSH key pair (recommended: Ed25519 or RSA 4096-bit)
ssh-keygen -t ed25519 -C "deploy@yourproject" -f ~/.ssh/deploy_yourproject -N ""
# OR for RSA:
ssh-keygen -t rsa -b 4096 -C "deploy@yourproject" -f ~/.ssh/deploy_yourproject -N ""
```

**Important Steps:**
- Add the **public key** (`.pub` file) to your server's `~/.ssh/authorized_keys`
- Add the **private key** (without `.pub` extension) to GitHub Secrets as `REMOTE_PRIVATE_KEY`
- Ensure correct file permissions on your server:
  ```bash
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/authorized_keys
  ```

For detailed information on creating and managing SSH keys, see [GitHub's SSH Key Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

#### 2. ``remote_path`` permissions

Make sure the ``remote_user`` has write access to ``remote_path``.

See: https://github.com/Burnett01/rsync-deployments/issues/81#issuecomment-3308152891

#### 3. Firewall / GitHub Actions IP Restrictions

If your remote server has firewall restrictions:

- **Option A:** Whitelist [GitHub Actions IP ranges](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#ip-addresses) (Azure-based)
- **Option B:** Use self-hosted runners on your server (recommended for strict firewall environments)

### Excluding files/folders (eg .git) 

By default, rsync copies dot files and folder if present at ``path:``. To exclude them, you can use the ``--exclude`` switch:

```yml
switches: -avzr --delete --exclude='.git/'
```

Other common exclusions:
```yml
switches: -avzr --delete --exclude='.git/' --exclude='node_modules/' --exclude='.env'
```

More advanced examples:

- https://github.com/Burnett01/rsync-deployments/issues/5#issuecomment-667589874
- https://github.com/Burnett01/rsync-deployments/issues/16
- https://github.com/Burnett01/rsync-deployments/issues/71
- https://github.com/Burnett01/rsync-deployments/issues/52

### Missing rsync on Remote Host

If the action fails with "rsync: command not found" or similar errors, rsync is not installed on your remote server. Install it using your system's package manager:

**Ubuntu/Debian:**
```bash
sudo apt-get update && sudo apt-get install rsync
```

**CentOS/RHEL/Rocky/AlmaLinux:**
```bash
sudo yum install rsync
# OR on newer versions:
sudo dnf install rsync
```

**Alpine Linux:**
```bash
sudo apk add rsync
```

---

## Versions

## Version 7.1.0

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/7.1.0  (alpine 3.22.1)
  

## Version 7.0.2 (DEPRECATED)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/7.0.2  (alpine 3.22.1)
  
---

## Version 7.0.0 & 7.0.1 (EOL)

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/7.0.0  (alpine 3.19.1)
- https://github.com/Burnett01/rsync-deployments/tree/7.0.1  (alpine 3.22.1)
  
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

## Media & Pingback

This action was featured in multiple blogs across the globe:

> Disclaimer: The author & co-authors are not responsible for the content of the site-links below.

- https://hosting.xyz/wiki/hosting/other/github-actions/

- https://www.alexander-palm.de/2025/07/22/sichere-rsync-deployments-mit-github-actions-und-rrsync/

- https://lab.uberspace.de/howto_automatic-deployment/

- https://blog.devops.dev/setting-up-an-ubuntu-instance-for-nodejs-apps-in-ovh-cloud-using-nginx-pm2-github-actions-7618c768d081

- https://elijahverdoorn.com/2020/04/14/automating-deployment-with-github-actions/

- https://www.vektor-inc.co.jp/post/github-actions-deploy/

- https://webpick.info/automatiser-avec-github-actions/

- https://matthias-andrasch.eu/blog/2021/tutorial-webseite-mittels-github-actions-deployment-zu-uberspace-uebertragen-rsync/

- https://jishuin.proginn.com/p/763bfbd38928

- https://cloud.tencent.com/developer/article/1786522

