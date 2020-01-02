FROM alpine:3.11
MAINTAINER Dr Internet <internet@limelightgaming.net>

# Install RSync and Open SSH.
RUN apk update && apk add --no-cache rsync openssh-client
RUN rm -rf /var/cache/apk/*

# Prepare SSH dir.
RUN mkdir ~/.ssh

# Copy in our executables.
COPY agent-start agent-stop agent-add agent-autostart /bin/
COPY hosts-clear hosts-add /bin/
RUN chmod +x /bin/agent-* /bin/hosts-*

# Prepare for known hosts.
RUN hosts-clear
