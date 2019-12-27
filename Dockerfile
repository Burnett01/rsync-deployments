FROM alpine:latest

# Update
RUN apk --update --no-cache add rsync bash openssh-client

# Copy entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
