FROM alpine:3.22.2@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS base

RUN apk update && apk add --no-cache rsync openssh openssl busybox

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-*

FROM base AS build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
