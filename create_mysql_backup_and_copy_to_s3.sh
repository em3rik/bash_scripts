#!/bin/bash

### The following variables should be located in ~/.my.cnf ####
#dbuser=<db_username>
#dbpass=<db_pass>

export AWS_ACCESS_KEY_ID=<access_key>
export AWS_SECRET_ACCESS_KEY=<secret_key>
export AWS_DEFAULT_REGION=eu-central-1

s3bucket="<3-bucket-name>"
dbendpoint="<rds-endpoint>"
backup_name="$(echo $dbendpoint | cut -d '.' -f1)"-$(date "+%Y-%m-%d").sql

### Create mysql backup, bzip the file, and remove the original
mysqldump -h $dbendpoint --all-databases --triggers --routines --events > $backup_name

### Compress the .sql file
tar -cvjf $backup_name.bzip2 $backup_name

### Copy bzzzipped file to S3 bucket
aws s3 cp $backup_name.bzip2 s3://$s3bucket

### Clean up
rm $backup_name
rm $backup_name.bzip2
