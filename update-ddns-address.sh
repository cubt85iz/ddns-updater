#!/usr/bin/env bash

set -euox pipefail

update_dns_record(){
  # Parse DNS record type
  TYPE="$1"
  if [ -z "$TYPE" ]; then
    echo "DNS record type not provided."
    exit 1
  fi

  # Parse IP address
  IP="$2"
  if [ -z "$IP" ]; then
    echo "IP address not provided."
    exit 1
  fi

  # Get DNS record identifier
  DNS_RECORD_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=${DOMAIN}&type=${TYPE}" \
    -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "X-Auth-Key: $CLOUDFLARE_API_KEY" | jq -r '.result[0].id')

  if [ -n "$DNS_RECORD_ID" ]; then

    # Ref: https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/
    curl https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
        -X PUT \
        -H 'Content-Type: application/json' \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -d "{
          \"type\": \"${TYPE}\",
          \"name\": \"${DOMAIN}\",
          \"content\": \"${IP}\",
          \"ttl\": 3600,
          \"proxied\": ${PROXIED}
        }"
  else
    echo "ERROR: Unable to locate DNS record identifier."
    exit 1
  fi
}

# Retrieve IPv4 address for WAN.
WAN_IPV4=$(/usr/bin/dig @resolver4.opendns.com myip.opendns.com +short -4)
if [ -z "$WAN_IPV4" ]; then
  echo "Unable to retrieve IPv4 address for WAN."
  exit 1
fi

# Retrieve IPv6 address for WAN.
WAN_IPV6=$(/usr/bin/dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6)
if [ -z "$WAN_IPV6" ]; then
  echo "Unable to retrieve IPv6 address for WAN."
fi

# Get IP addresses for specified domain.
DOMAIN_IPV4=$(/usr/bin/dig "$DOMAIN" A +short)
DOMAIN_IPV6=$(/usr/bin/dig "$DOMAIN" AAAA +short)

# Update A-record if there's a mismatch between WAN & DOMAIN IPv4 addresses.
if [ "$WAN_IPV4" != "$DOMAIN_IPV4" ]; then
  update_dns_record "A" "$WAN_IPV4"
else
  echo "Domain IPv4 address is accurate. Skipping update."
fi

if [ "$WAN_IPV6" != "$DOMAIN_IPV6" ]; then
  update_dns_record "AAAA" "$WAN_IPV6"
else
  echo "Domain IPv6 address is accurate. Skipping update."
fi
