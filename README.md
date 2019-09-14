# rsync deployments

This GitHub Action deploys *everything* in `GITHUB_WORKSPACE` to a folder on a server via rsync over ssh. 

This action would usually follow a build/test action which leaves deployable code in `GITHUB_WORKSPACE`.

# Required SECRETs

This action needs a `DEPLOY_KEY` secret variable. This should be the private key part of an ssh key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment. This should be set in the Github secrets section and then referenced as an `env` variable.

# Required ARGs
This action requires 4 args in the `with` block.

1. `swtiches` - The first is for any initial/required rsync flags, eg: `-avzr --delete`

2. `excludes` - Any `--exclude` flags and directory pairs, eg: `--exclude .htaccess --exclude /uploads/`. Use "" if none required.

3. `path` - The path to your desired directory to be deployed, if none; use `""`

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
      uses: mickr/rsync-deployments@master
      with:
        switches: -avzr --delete
        excludes: ""
        path: src/
        upload_path: user@example.com:/var/www/html/

      env:
        DEPLOY_KEY: ${{ secrets.private_key }}

```

## Disclaimer

If you're using GitHub Actions, you'll probably already know that it's still in limited public beta, and GitHub advise against using Actions in production. 

So, check your keys. Check your deployment paths. And use at your own risk.