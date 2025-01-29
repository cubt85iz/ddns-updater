ARG ALPINE_VERSION=${ALPINE_VERSION:-3.21}

FROM docker.io/library/alpine:${ALPINE_VERSION}

RUN apk add --no-cache bind-tools
COPY update-ddns-address.sh /update-ddns-address.sh
RUN chmod +x /update-ddns-address.sh

ENTRYPOINT ["/update-ddns-address.sh"]