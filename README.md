## Manual Backup
To backup contents of your current working directory:

```bash
docker run --rm -v $(pwd):/backups -e "AWS_ACCESS_KEY_ID=..." -e "AWS_SECRET_ACCESS_KEY=.../" -e "AWS_S3_BUCKET_PATH=s3://my-bucket/" skymatic/s3backup
```

## Manual Restore
To restore a backup, run the restore script interactively (note the `-it`):

```bash
docker run -it --rm -v $(pwd):/backups -e "AWS_ACCESS_KEY_ID=..." -e "AWS_SECRET_ACCESS_KEY=.../" -e "AWS_S3_BUCKET_PATH=s3://my-bucket/" skymatic/s3backup ./restore.sh
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
      - /very/important/files:/backups
    deploy:
      restart_policy:
        delay: 1d # run daily
```

## Customize Settings

| Environment Variable | Default Value | Comment |
|:---|:---|:---|
| BACKUP_DIRECTORY | `/backups` | Directory containing the files to upload. |
| BACKUP_FILE_GLOB | `*` | Backup only specific files of your backup dir, e.g. `*.tar.gz` |
| OPENSSL_ENC_PASS |  | Set to non-null value to encrypt file before uploading |
| AWS_DEFAULT_REGION | `eu-central-1` | Specify region |
| AWS_ENDPOINT_URL |  | The endpoint URL is required for non Amazon AWS Object Storages |
| AWS_ACCESS_KEY_ID |  | The API key id of your AWS user |
| AWS_SECRET_ACCESS_KEY |  | The API key of your AWS user |

## Bucket-Credentials
Create an AWS IAM user and grant the following privileges for your bucket objects (e.g. `arn:aws:s3:::my-bucket/*`):
* `s3:PutObject`

For restoring you also need the following permissions on your bucket and bucket objects (e.g. `arn:aws:s3:::my-bucket` and `arn:aws:s3:::my-bucket/*`):
* `s3:GetObject`
* `s3:ListBucket`
