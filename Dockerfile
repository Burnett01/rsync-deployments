FROM alpine:3.22.1 as base

RUN apk update && apk add --no-cache --upgrade rsync openssh-client openssl

RUN rm -rf /var/cache/apk/*

COPY docker-rsync/* /bin/
RUN chmod +x /bin/agent-*

FROM base as build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
