#!/bin/bash

set -e

cluster_leader=`curl --silent --fail http://127.0.0.1:8500/v1/operator/raft/configuration | jq -r '.Servers[] | select(.Leader) | .Node'`
echo "Cluster Leader: $cluster_leader"

if [[ `hostname` == $cluster_leader ]]; then
    backup_file=$(mktemp)

    echo "Executing Consul Snapshot"
    /usr/bin/consul snapshot save $backup_file

    echo "Uploading Snapshot to NAS"
    mount_dir=$(mktemp -d)

    # Because this script is run as root, the NFS server maps the user to nobody. Ensure that the Share permissions are nobody:operator to allow write access
    sudo mount -t nfs woodlandpark.brickyard.whitestar.systems:/mnt/tank/Server\ Backups/Raft\ Backups/ ${mount_dir}
    cp "${backup_file}" "${mount_dir}/consul.snap"
    umount "${mount_dir}"
    rm "${mount_dir}"

    rm $backup_file

    echo consul_raft_backup_completed $(date +%s) > /var/lib/node_exporter/consul_backup.prom.$$
    mv /var/lib/node_exporter/consul_backup.prom.$$ /var/lib/node_exporter/consul_backup.prom

    echo "Done!"
else
    echo "Skipping backup as $cluster_leader is the leader"
fi