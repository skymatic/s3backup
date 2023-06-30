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

cd "${BACKUP_DIRECTORY}";

for FILE in ${BACKUP_FILE_GLOB}
do
  if [ -z "${OPENSSL_ENC_PASS}" ]
  then
    echo "Uploading unencrypted file ${FILE}...";
    if [ -z "${AWS_ENDPOINT_URL}" ]
    then
      aws s3 cp ${FILE} ${AWS_S3_BUCKET_PATH}${FILE};
    else \
      aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp ${FILE} ${AWS_S3_BUCKET_PATH}${FILE};
    fi
  else \
    echo "Encrypting file  ${FILE} using $(openssl version) with AES-128-CTR and iv/key derived from provided password.";
    openssl enc -AES-128-CTR -in ${FILE} -out /tmp/${FILE}.enc -pass pass:${OPENSSL_ENC_PASS};
    echo "Uploading encrypted file ${FILE}.enc...";
    if [ -z "${AWS_ENDPOINT_URL}" ]
    then
      aws s3 cp /tmp/${FILE}.enc ${AWS_S3_BUCKET_PATH}${FILE}.enc;
    else \
      aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp /tmp/${FILE}.enc ${AWS_S3_BUCKET_PATH}${FILE}.enc;
    fi
    rm /tmp/${FILE}.enc;
  fi
done
