FROM ubuntu:latest

# Update
RUN apt-get update

# Install packages
RUN apt-get -yq install rsync openssh-client

# Copy entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
