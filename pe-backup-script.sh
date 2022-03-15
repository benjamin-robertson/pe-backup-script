#!/bin/bash
#
# Script used to backup Puppet Enterprise. Use within crontab.
#
# By default will retain backups for 28 days and use the default location for PE backups.
# Verify you have enough space and confirm backup size before using.
#
if [[ "$1" == "-h" ]]; then
  echo "PE backup wrapper script"
  echo "------------------------------"
  echo "By default backups PE to /var/puppetlabs/backup and retains backups for 28 days"
  echo ""
  echo "-p set backup directory"
  echo "-r set numnber of days to retain backup"
  echo ""
  echo "For example to backup to /root/backup and 7 days retention"
  echo "./pe-backup-script.sh -p /root/backup -r 7"
  exit
fi

timestamp=`date +%Y-%m-%d_%H.%M.%S`

while getopts p:r: flag
do
    case "${flag}" in
        p) path=${OPTARG};;
        r) retain_in=${OPTARG};;
    esac
done

echo $path
echo $retain_in

# set retain varible
if [[ "$retain_in" == "28" ]]; then
  echo "Set default 28 days"
  retain=28
else
  echo "Retain backups for $retain_in"
  retain=$retain_in
fi

# clean up old backup fuction
cleanup_fn () {
    echo "Retaining backups for $2"
    echo "Backup location at $1"
    # clean up pe_backups
    /bin/find $1 -name "pe_backup*" -mtime $2 -exec rm {} \;
    # clean up secrets backup
    /bin/find $1 -name "secrets-*" -mtime $2 -exec rm {} \;
}

# perform backup
if [ -z $path ]; then
  echo "Using default backup location /var/puppetlabs/backups"
  #/opt/puppetlabs/bin/puppet-backup create
  #tar -cf /var/puppetlabs/backups/secrets-$timestamp.tar /etc/puppetlabs/orchestration-services/conf.d/secrets/
  # clean up old backups
  cleanup_fn "/var/puppetlabs/backups" $retain
else
  echo "Using $path as backup location"
  #/opt/puppetlabs/bin/puppet-backup create --dir==$path
  #tar -cf $path/secrets-$timestamp.tar /etc/puppetlabs/orchestration-services/conf.d/secrets/
  cleanup_fn $path $retain
fi