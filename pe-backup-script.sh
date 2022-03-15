#!/bin/bash

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

if [ -z $1 ]; then
  echo "Using default backup location /var/puppetlabs/backup"
  /opt/puppetlabs/bin/puppet-backup create
  #tar -cf 
else
  echo "Using $1 as backup location"
  /opt/puppetlabs/bin/puppet-backup create $1
fi

