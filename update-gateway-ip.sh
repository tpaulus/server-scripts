#!/usr/bin/env bash

# === How to create a compatible API Token ===
# curl -X POST "https://api.cloudflare.com/client/v4/user/tokens" \
#     -H "X-Auth-Key:<Your API Key>" \
#     -H "X-Auth-Email:<Your Email>" \
#     -H "Content-Type: application/json" \
#     --data '{"name":"Gateway IP Updater", "status":"active", "policies":[{"effect":"allow", "resources": {
#           "com.cloudflare.api.account.*": "*"}, "permissions": ["com.cloudflare.team.gateway.edit", "com.cloudflare.team.gateway.read"]}]}' | jq .result.value

# === How to get your Gateway Location ID ===
# curl -X GET "https://api.cloudflare.com/client/v4/accounts/9b7fd46c9c7d159384c97ecf5f55cbae/gateway/locations" \
#      -H "Authorization: Bearer <Generated API Token>"

api_token="$CF_API_TOKEN"
cf_account_id="$CF_ACCOUNT_ID"
gateway_location_id="$CF_GATEWAY_LOCATION"


public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "Our Public IP is ${public_ip}"

# Get current Gateway Location IP
current_gateway_location_ip=`curl -X GET -s "https://api.cloudflare.com/client/v4/accounts/${cf_account_id}/gateway/locations/${gateway_location_id}" \
     -H "Authorization: Bearer ${api_token}" \
     -H "Content-Type: application/json" | jq .result.networks[0].network -r`

if [[ "${public_ip}/32" == "${current_gateway_location_ip}" ]]; then
  echo "Gateway Network IP matches current public IP, no update necessary."
else
  echo "Gateway Network IP is out of date (current: ${current_gateway_location_ip}), updating!"

  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/${cf_account_id}/gateway/locations/${gateway_location_id}" \
       -H "Authorization: Bearer ${api_token}" \
       -H "Content-Type: application/json" \
       --data "{\"name\":\"Home\",\"networks\":[{\"network\": \"${public_ip}/32\"}],\"client_default\":true,\"ecs_support\":true}"
fi
