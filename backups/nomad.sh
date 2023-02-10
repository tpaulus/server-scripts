#!/bin/bash

set -e

cluster_leader=`curl --silent --fail http://127.0.0.1:4646/v1/operator/raft/configuration | jq -r '.Servers[] | select(.Leader) | .Node' | sed -nr "s/([a-zA-Z0-9]+).[a-zA-Z0-9]+/\1/p"`
echo "Cluster Leader: $cluster_leader"

if [[ `hostname` =~ $cluster_leader ]]; then
    backup_file="/tmp/nomad-$(date +%s).snap"

    echo "Executing Nomad Snapshot"
    nomad operator snapshot save $backup_file

    echo "Uploading Snapshot to NAS"
    rsync $backup_file rsync://woodlandpark.brickyard.whitestar.systems:873/raft-backups/nomad.snap

    rm $backup_file
echo "Done!"
else
    echo "Skipping backup as $cluster_leader is the leader"
fi