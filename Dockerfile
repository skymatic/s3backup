FROM alpine:3.20

MAINTAINER Sebastian Stenzel <sebastian.stenzel@skymatic.de>

RUN apk --update add s3cmd openssl \
  && rm -rf /var/cache/apk/*

ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
RUN chmod +x /backup.sh
RUN chmod +x /restore.sh

ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_REGION=eu-central-1
ENV AWS_S3_BUCKET_PATH=
ENV AWS_ENDPOINT_URL=
ENV BACKUP_DIRECTORY=/backups
ENV BACKUP_FILE_GLOB=*
ENV RETENTION_POLICIES=
ENV OPENSSL_ENC_PASS=

CMD ["/backup.sh"]
