FROM alpine:3.11
MAINTAINER Dr Internet <internet@limelightgaming.net>

# Install RSync and Open SSH.
RUN apk update && apk add --no-cache rsync openssh-client #ca-certificates
# RUN update-ca-certificates
RUN rm -rf /var/cache/apk/*

# Prepare for SSH keys.
RUN mkdir ~/.ssh

# Copy in our executables.
COPY start-agent.sh /bin/start-agent
COPY add-key.sh /bin/add-key
RUN chmod +x /bin/add-key /bin/start-agent
