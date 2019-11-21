# rsync deployments

This GitHub Action deploys files in `GITHUB_WORKSPACE` to a folder on a server via rsync over ssh. 

Use this action in a build/test workflow which leaves deployable code in `GITHUB_WORKSPACE`.

# Required SECRETs

This action needs a `DEPLOY_KEY` secret variable. This should be the private key part of a ssh key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. This should be set in the Github secrets section and then referenced as an `env` variable.

# Required ARGs

This action requires 4 args in the `with` block.

1. `swtiches` - The first is for any initial/required rsync flags, eg: `-avzr --delete`

2. `rsh` - Optional remote shell commands, eg for using a different SSH port: `"-p ${{ secrets.DEPLOY_PORT }}"`

3. `path` - The source path, if none; use `""`

4. `upload_path` - The deployment target, and should be in the format: `[USER]@[HOST]:[PATH]`

# Example usage

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
      uses: burnett01/rsync-deployments@master
      with:
        switches: -avzr --delete --exclude="" --include=""
        rsh: "-p ${{ secrets.DEPLOY_PORT }}"
        path: src/
        upload_path: user@example.com:/var/www/html/

      env:
        DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}

```

## Disclaimer

If you're using GitHub Actions, you probably already know that it's still in limited public beta, and GitHub advise against using Actions in production. 

So, check your keys. Check your deployment paths. And use at your own risk.
