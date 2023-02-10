#!/bin/bash

set -e

backup_file=$(mktemp)

echo "Executing Consul Snapshot"
consul snapshot save $backup_file

echo "Uploading Snapshot to NAS"
rsync $backup_file rsync://woodlandpark.brickyard.whitestar.systems:873/raft-backups/consul.snap

rm $backup_file
echo "Done!"