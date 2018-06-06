## Manual Backup
To backup contents of your current working directory:

```bash
docker run --rm -v $(pwd):/workdir -e "AWS_ACCESS_KEY_ID=..." -e "AWS_SECRET_ACCESS_KEY=.../" -e "AWS_S3_BUCKET_PATH=s3://my-bucket/ skymatic/s3backup
```

## Scheduled Backup
Use compose to schedule backups to run [daily](https://docs.docker.com/compose/compose-file/#specifying-durations):

```yml
version: '3.2'
services:
  # ...
  backups:
    image: skymatic/s3backup
    environment:
      - AWS_ACCESS_KEY_ID=...
      - AWS_SECRET_ACCESS_KEY=...
      - AWS_S3_BUCKET_PATH=s3://my-bucket/
    volumes:
      - /very/important/files:/workdir
    deploy:
      restart_policy:
        delay: 1d # run daily
```

## Customize Settings

| Environment Variable | Default Value | Comment |
|:---|:---|:---|
| BACKUP_FILE_GLOB | * | Backup only specific files of your backup dir, e.g. `*.tar.gz` |
| OPENSSL_ENC_PASS |  | Set to non-null value to encrypt file before uploading |
| AWS_DEFAULT_REGION | eu-central-1 | Specify region |
| AWS_STORAGE_CLASS | REDUCED_REDUNDANCY | Specify storage class |

## Bucket-Credentials
Create an AWS IAM user and grant the following privileges for your bucket (e.g. `arn:aws:s3:::my-bucket/*`):
* `s3:GetObject`
* `s3:PutObject`
* `s3:RestoreObject`
* `s3:GetObjectVersion`
