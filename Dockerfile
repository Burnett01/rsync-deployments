FROM alpine:3.11
MAINTAINER Dr Internet <internet@limelightgaming.net>

# Install RSync and Open SSH.
RUN apk update && apk add --no-cache rsync openssh-client
RUN rm -rf /var/cache/apk/*

# Prepare for SSH keys.
RUN mkdir ~/.ssh

# Copy in our executables.
COPY agent-start /bin/agent-start
COPY agent-add /bin/agent-add
COPY agent-stop /bin/agent-stop
RUN chmod +x /bin/agent-start /bin/agent-stop /bin/agent-add
