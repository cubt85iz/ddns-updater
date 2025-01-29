#!/usr/bin/env ash

set -euo pipefail

# Retrieve IPV4 address for WAN.
WAN_IPV4=$(/usr/bin/dig @resolver4.opendns.com myip.opendns.com +short -4)
if [ -z "$WAN_IPV4" ]; then
  echo "Unable to retrieve IPv4 address for WAN."
  exit 1
fi

DOMAIN_IPV4=$(/usr/bin/dig +short "${DOMAIN}")
if [ "$WAN_IPV4" != "$DOMAIN_IPV4" ]; then
  # Ref: https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/
  curl https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
      -X PUT \
      -H 'Content-Type: application/json' \
      -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
      -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
      -d "{
        \"comment\": \"Domain verification record\",
        \"content\": \"${WAN_IPV4}\",
        \"name\": \"${DOMAIN}\",
        \"proxied\": ${PROXIED},
        \"settings\": {
          \"ipv4_only\": true,
          \"ipv6_only\": true
        },
        \"tags\": [
          \"owner:dns-team\"
        ],
        \"ttl\": 3600,
        \"type\": \"A\"
      }"
    echo "IPs are different"
else
  echo "Domain IPv4 address is accurate. Skipping update."
fi
