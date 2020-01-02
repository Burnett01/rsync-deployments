FROM alpine:3.11
MAINTAINER Dr Internet <internet@limelightgaming.net>

RUN apk update
RUN apk add --no-cache rsync openssh-client ca-certificates
RUN update-ca-certificates
RUN rm -rf /var/cache/apk/*
