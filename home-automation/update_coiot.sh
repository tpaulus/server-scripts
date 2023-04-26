#!/bin/bash

for HOST in $HOSTS; do
  # Save Current Settings
  current_settings=$(mktemp)
  curl -X GET http://$HOST/settings --silent --fail > $current_settings

  expected_peer="$PEER:5683"
  current_peer=`cat $current_settings | jq -r '.coiot.peer'`

  if [[ $expected_peer == $current_peer ]]; then
    echo "Peer is already $expected_peer"
  else
    # Update Settings
    curl --location --request GET "http://$HOST/settings?coiot_peer=$expected_peer" \
      --silent \
      --fail > /dev/null

    echo "Settings Updated on $HOST"

    # Reboot
    curl -X GET http://$HOST/reboot \
      --silent \
      --fail > /dev/null
    echo "Issued Reboot Command to $HOST"

    rm $current_settings $new_settings
  fi
done