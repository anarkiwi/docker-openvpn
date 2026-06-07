FROM alpine:3.23

# iproute2: openvpn needs `ip` to install the tun route for the server subnet.
# No iptables here -- NAT is the operator's job on the host (host networking).
# hadolint ignore=DL3018
RUN apk add --no-cache openvpn iproute2

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
