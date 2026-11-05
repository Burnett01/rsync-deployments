FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS base

# Add Alpine edge branch as tagged repository for rsync.
RUN printf '%s\n' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/main' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' \
    >> /etc/apk/repositories

# Install rsync from Alpine edge branch for latest upstream security patches.
# Other packages are installed from Alpine 3.24.3 branch.
RUN apk update && apk add --no-cache --upgrade 'rsync@edge>=3.5.1-r0' openssh openssl busybox

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-* /bin/ssh-* /bin/hosts-*

FROM base AS build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
