#!/bin/bash

set -e

cluster_leader=`curl --silent --fail http://127.0.0.1:8500/v1/operator/raft/configuration | jq -r '.Servers[] | select(.Leader) | .Node'`
echo "Cluster Leader: $cluster_leader"

if [[ `hostname` == $cluster_leader ]]; then
    backup_file=$(mktemp)

    echo "Executing Consul Snapshot"
    consul snapshot save $backup_file

    echo "Uploading Snapshot to NAS"
    rsync $backup_file rsync://woodlandpark.brickyard.whitestar.systems:873/raft-backups/consul.snap

    rm $backup_file
echo "Done!"
else
    echo "Skipping backup as $cluster_leader is the leader"
fi