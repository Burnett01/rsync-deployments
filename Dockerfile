FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS base

# Add Alpine edge branch as tagged repository for rsync.
RUN printf '%s\n' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/main' \
    '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' \
    >> /etc/apk/repositories

# Install rsync from Alpine edge branch for latest upstream security patches.
# Other packages are installed from Alpine 3.24.3 branch.
RUN apk update && apk add --no-cache --upgrade 'rsync@edge>=3.5.2-r1' 'openssh-client-default@edge>=10.6_p2-r0' openssl busybox

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-* /bin/ssh-* /bin/hosts-*

FROM base AS build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
