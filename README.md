# ddns-updater

Uses `dig` to determine the WAN IPv4 & IPv6 addresses of the current network and compares against the current IPv4 & IPv6 addresses for the provided domain. If they differ, it executes a `curl` command to update the addresses of the provided domain.

## Required variables

There are a few variables that need to be defined in order to update the address for a domain.

- `DOMAIN`: Domain to be updated (ex. mysub.domain.com)
- `ZONE_ID`: Zone identifier for domain
- `CLOUDFLARE_EMAIL`: Cloudflare service email
- `CLOUDFLARE_API_KEY`: Cloudflare Global API key
- `PROXIED`: Proxied? `true` or `false`

If deploying using quadlet, I'd suggest using a systemd drop-in for these values. Sample container and timer files are located in the `quadlet` folder.

## References

- [https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/](https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/)
