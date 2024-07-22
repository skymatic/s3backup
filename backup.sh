#!/bin/sh

if [ -z "${AWS_ACCESS_KEY_ID}" ]
then
  echo "AWS_ACCESS_KEY_ID not set.";
  exit 1;
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]
then
  echo "AWS_SECRET_ACCESS_KEY not set.";
  exit 1;
fi

if [ -z "${AWS_S3_BUCKET_PATH}" ]
then
  echo "AWS_S3_BUCKET_PATH not set.";
  exit 1;
fi

if [ ! -d "${BACKUP_DIRECTORY}" ]
then
  echo "BACKUP_DIRECTORY not a valid directory.";
  exit 1;
fi

if [ -z "${BACKUP_FILE_GLOB}" ]
then
  echo "BACKUP_FILE_GLOB not set.";
  exit 1;
fi

if [ -z "${AWS_ENDPOINT_URL}" ]
then
  echo "AWS_ENDPOINT_URL not set.";
  exit 1;
fi

S3CMD_SYNC_OPTIONS="--multipart-chunk-size-mb=1000 --host=${AWS_ENDPOINT_URL} --host-bucket=${AWS_ENDPOINT_URL}"

if [ -n "${BACKUP_FILE_GLOB}" ]; then
  S3CMD_SYNC_OPTIONS="${S3CMD_SYNC_OPTIONS} --include='${BACKUP_FILE_GLOB}' --exclude='*'"
fi

if [ -n "${AWS_DEFAULT_REGION}" ]; then
  S3CMD_SYNC_OPTIONS="${S3CMD_SYNC_OPTIONS} --bucket-location=${AWS_DEFAULT_REGION}"
fi

if [ -n "${RETENTION_POLICIES}" ]; then
  S3CMD_SYNC_OPTIONS="${S3CMD_SYNC_OPTIONS} --add-header=x-amz-tagging:${RETENTION_POLICIES}"
fi

cd "${BACKUP_DIRECTORY}";

for FILE in ${BACKUP_FILE_GLOB}
do
  if [ -z "${OPENSSL_ENC_PASS}" ]
  then
    echo "Uploading unencrypted file ${FILE}...";
    s3cmd sync ${S3CMD_SYNC_OPTIONS} ${BACKUP_DIRECTORY} ${AWS_S3_BUCKET_PATH};
  else \
    echo "Encrypting file  ${FILE} using $(openssl version) with AES-256-CTR and iv/key derived from provided password.";
    openssl enc -AES-256-CTR -pbkdf2 -iter 1000000 -in ${FILE} -out /tmp/${FILE}.enc -pass pass:${OPENSSL_ENC_PASS};
    echo "Uploading encrypted file ${FILE}.enc...";
    s3cmd sync ${S3CMD_SYNC_OPTIONS} /tmp/${FILE}.enc ${AWS_S3_BUCKET_PATH}${FILE}.enc;
    rm /tmp/${FILE}.enc;
  fi
done
