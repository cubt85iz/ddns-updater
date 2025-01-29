# ddns-updater

Uses `dig` to determine the WAN IPv4 address of the current computer and compares against the current IPv4 address the provided domain. If they differ, it executes a `curl` command to update the address of the provided domain.

## Required variables

There are a few variables that need to be defined in order to update the address for a domain.

- `DOMAIN`: 
- `ZONE_ID`:
- `DNS_RECORD_ID`:
- `CLOUDFLARE_EMAIL`:
- `CLOUDFLARE_API_KEY`:
- `PROXIED`:

If deploying using quadlet, I'd suggest using a systemd drop-in for these values. Sample container and timer files are located in the `quadlet` folder.

## References

- [https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/](https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update/)
