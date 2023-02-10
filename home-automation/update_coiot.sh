#!/bin/bash

for HOST in $HOSTS; do
  # Save Current Settings
  current_settings=$(mktemp)
  curl -X GET http://$HOST/settings --silent > $current_settings

  expected_peer="$PEER:5683"
  current_peer=`cat $current_settings | jq -r '.coiot.peer'`

  if [[ $expected_peer == $current_peer ]]; then
    echo "Peer is already $expected_peer"
  else
    new_settings=$(mktemp)
    jq ".coiot.peer = \"$expected_peer\"" $current_settings > $new_settings

    # Update Settings
    curl --location --request POST "http://$HOST/settings" \
      --header "Content-Type: application/json" \
      --data-raw @$new_settings \
      --silent > /dev/null

    echo "Settings Updated on $HOST"

    # Reboot
    # curl -X GET http://$HOST/reboot
    echo "Issued Reboot Command to $HOST"

    rm $current_settings $new_settings
  fi
done