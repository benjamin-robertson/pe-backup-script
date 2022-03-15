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
  echo "Argument 1 set backup directory"
  echo "Argument 2 set numnber of days to retain backup"
  echo ""
  echo "For example to backup to /root/backup and 7 days retention"
  echo "./pe-backup-script.sh /root/backup 7"
  exit
fi

timestamp=`date +%Y-%m-%d_%H.%M.%S`

# set retain varible
if [ -z $2 ]; then
  echo "Set default 28 days"
  retain=28
else
  retain=$2
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
if [ -z $1 ]; then
  echo "Using default backup location /var/puppetlabs/backups"
  /opt/puppetlabs/bin/puppet-backup create
  tar -cf /var/puppetlabs/backups/secrets-$timestamp.tar /etc/puppetlabs/orchestration-services/conf.d/secrets/
  # clean up old backups
  cleanup_fn "/var/puppetlabs/backups" $2
else
  echo "Using $1 as backup location"
  /opt/puppetlabs/bin/puppet-backup create $1
  tar -cf $1/secrets-$timestamp.tar /etc/puppetlabs/orchestration-services/conf.d/secrets/
  cleanup_fn $1 $2
fi