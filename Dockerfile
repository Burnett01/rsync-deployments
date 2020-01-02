FROM alpine:3.11
MAINTAINER Dr Internet <internet@limelightgaming.net>

# Install RSync and Open SSH.
RUN apk update && apk add --no-cache rsync openssh-client #ca-certificates
# RUN update-ca-certificates
RUN rm -rf /var/cache/apk/*

# Prepare for SSH keys.
RUN mkdir ~/.ssh

# Copy in our executables.
COPY agent-start.sh /bin/agent-start
COPY agent-add.sh /bin/agent-add
RUN chmod +x /bin/agent-start /bin/bin/agent-add
