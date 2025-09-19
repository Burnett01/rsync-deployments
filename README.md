# rsync deployments

[![CI - Validating, Linting, Testing](https://github.com/Burnett01/rsync-deployments/actions/workflows/ci-validating-linting-testing.yml/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/ci-validating-linting-testing.yml) 
[![Snyk Docker Vulnerability Scan](https://github.com/Burnett01/rsync-deployments/actions/workflows/snyk-docker-vulnerability-scan.yml/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/snyk-docker-vulnerability-scan.yml) 
[![CodeQL](https://github.com/Burnett01/rsync-deployments/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/github-code-scanning/codeql) 
[![Dependabot Updates](https://github.com/Burnett01/rsync-deployments/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/Burnett01/rsync-deployments/actions/workflows/dependabot/dependabot-updates)


This GitHub Action (amd64) deploys files in `GITHUB_WORKSPACE` to a remote folder via rsync over ssh. 

Use this action in a CD workflow which leaves deployable code in `GITHUB_WORKSPACE`.

The base-image [drinternet/rsync](https://github.com/JoshPiper/rsync-docker/) of this action is very small and is based on Alpine 3.22.1 (no cache) which results in fast deployments.

Alpine version: [3.22.1](https://alpinelinux.org/posts/Alpine-3.19.8-3.20.7-3.21.4-3.22.1-released.html)
Rsync version: [3.4.1-r0](https://download.samba.org/pub/rsync/NEWS#3.4.1)

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

For simplicity, we are using `DEPLOY_PRIVATE_KEY` and other `DEPLOY_*` as the secret variables throughout the examples.

## Current Version: 7.1.0

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
      uses: burnett01/rsync-deployments@7.1.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
```

Advanced:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.1.0
      with:
        switches: -avzr --delete --exclude="" --include="" --filter=""
        path: src/
        remote_path: /var/www/html/
        remote_host: example.com
        remote_port: 5555
        remote_user: debian
        remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
```

For better **security**, I suggest you create additional secrets for remote_host, remote_port, remote_user and remote_path inputs.

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.1.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
```

If your private key is passphrase protected you should use:

```yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: rsync deployments
      uses: burnett01/rsync-deployments@7.1.0
      with:
        switches: -avzr --delete
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
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
      uses: burnett01/rsync-deployments@7.1.0
      with:
        switches: -avzr --delete
        legacy_allow_rsa_hostkeys: "true"
        path: src/
        remote_path: ${{ secrets.DEPLOY_PATH }}
        remote_host: ${{ secrets.DEPLOY_HOST }}
        remote_port: ${{ secrets.DEPLOY_PORT }}
        remote_user: ${{ secrets.DEPLOY_USER }}
        remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
```

See [#49](https://github.com/Burnett01/rsync-deployments/issues/49) and [#24](https://github.com/Burnett01/rsync-deployments/issues/24) for more information.

---

## Troubleshooting

### SSH Permission Denied Errors

If you encounter "Permission denied (publickey,password)" errors, this typically indicates authentication issues between GitHub Actions and your server. **This is the most common deployment problem** and usually stems from incorrect SSH key setup, server configuration, or firewall restrictions.

For advanced rsync configuration options and switches, refer to the [rsync manual](https://linux.die.net/man/1/rsync).

Here are the most common solutions:

#### 1. SSH Key Setup Issues

Ensure your SSH key pair is correctly generated and configured. For detailed information on creating and managing SSH keys, see [GitHub's SSH Key Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

```bash
# Generate a new SSH key pair (recommended: Ed25519 or RSA 4096-bit)
ssh-keygen -t ed25519 -C "deploy@yourproject" -f ~/.ssh/deploy_yourproject -N ""
# OR for RSA:
ssh-keygen -t rsa -b 4096 -C "deploy@yourproject" -f ~/.ssh/deploy_yourproject -N ""
```

**Important Steps:**
- Add the **public key** (`.pub` file) to your server's `~/.ssh/authorized_keys`
- Add the **private key** (without `.pub` extension) to GitHub Secrets as `DEPLOY_PRIVATE_KEY`
- Ensure correct file permissions on your server:
  ```bash
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/authorized_keys
  ```

#### 2. Legacy RSA Hostkeys (OpenSSH 8.8+)

If your server uses older OpenSSH versions (&lt; 8.8) with RSA hostkeys, add:

```yml
legacy_allow_rsa_hostkeys: "true"
```

**Note:** Only use this if necessary. It's recommended to upgrade your OpenSSH server instead.

#### 3. GitHub Actions IP Restrictions

If your server has firewall restrictions:

- **Option A:** Whitelist [GitHub Actions IP ranges](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#ip-addresses) (Azure-based)
- **Option B:** Use self-hosted runners on your server (recommended for strict firewall environments)

#### 4. Excluding .git Directory

By default, rsync copies all directories including `.git`. To exclude it:

```yml
switches: -avzr --delete --exclude='.git/'
```

Other common exclusions:
```yml
switches: -avzr --delete --exclude='.git/' --exclude='node_modules/' --exclude='.env'
```

#### 5. Testing SSH Connection

Test your SSH connection independently:

```bash
# Test SSH connection (replace with your details)
ssh -i ~/.ssh/deploy_yourproject -p 22 username@yourserver.com
# Test with legacy RSA support if needed:
ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -i ~/.ssh/deploy_yourproject -p 22 username@yourserver.com
```

#### 6. Common Configuration Example

Here's a complete working example addressing most common issues:

```yml
- name: Deploy files to server
  uses: burnett01/rsync-deployments@7.1.0
  with:
    switches: -avzr --delete --exclude='.git/' --exclude='node_modules/'
    path: ./
    remote_path: ${{ secrets.DEPLOY_PATH }}
    remote_host: ${{ secrets.DEPLOY_HOST }}
    remote_port: ${{ secrets.DEPLOY_PORT }}
    remote_user: ${{ secrets.DEPLOY_USER }}
    remote_key: ${{ secrets.DEPLOY_PRIVATE_KEY }}
    # Only add this line if your server uses OpenSSH < 8.8:
    # legacy_allow_rsa_hostkeys: "true"
```

---

## Version 7.0.2

Check here: 

- https://github.com/Burnett01/rsync-deployments/tree/7.0.2  (alpine 3.19.1)
  
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

