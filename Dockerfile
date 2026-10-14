FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS base

# Add Alpine edge branch as tagged repository for rsync.
RUN printf '%s\n' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/main' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' \
    >> /etc/apk/repositories

# Install rsync from Alpine edge branch for latest upstream security patches.
# Other packages are installed from Alpine 3.24.2 branch.
RUN apk update && apk add --no-cache --upgrade 'rsync@edge>=3.5.1-r0' openssh openssl busybox

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-* /bin/ssh-* /bin/hosts-*

FROM base AS build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
