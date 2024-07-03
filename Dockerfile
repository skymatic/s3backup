FROM alpine:3.20

MAINTAINER Sebastian Stenzel <sebastian.stenzel@skymatic.de>

# latest aws cli version: https://pypi.org/project/awscli/#description
ARG AWS_CLI_VERSION=2.12.4

RUN apk --update add aws-cli openssl \
  && rm -rf /var/cache/apk/*
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
RUN chmod +x /backup.sh
RUN chmod +x /restore.sh
RUN aws configure set default.s3.multipart_threshold 1GB \
  && aws configure set default.s3.multipart_chunksize 1GB

ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_REGION=eu-central-1
ENV AWS_S3_BUCKET_PATH=
ENV AWS_ENDPOINT_URL=
ENV BACKUP_DIRECTORY=/backups
ENV BACKUP_FILE_GLOB=*
ENV OPENSSL_ENC_PASS=

CMD ["/backup.sh"]
