# drinternet/rsync@v1.5.1
FROM drinternet/rsync@sha256:e61f4047577b566872764fa39299092adeab691efb3884248dbd6495dc926527

# always force-upgrade rsync to get the latest security fixes
RUN apk update && apk add --no-cache --upgrade rsync openssl
RUN rm -rf /var/cache/apk/*

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
