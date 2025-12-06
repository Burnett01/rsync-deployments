FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS base

RUN apk update && apk add --no-cache --upgrade rsync openssh openssl busybox

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-*

FROM base AS build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
