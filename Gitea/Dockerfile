FROM alpine:3.20

# Install rclone and Postgres client
RUN apk add --no-cache \
    rclone \
    postgresql15-client \
    bash \
    tzdata \
    ca-certificates

ENTRYPOINT ["/bin/sh", "/scripts/backup.sh"]