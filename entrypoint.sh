#!/bin/sh
# Thin entrypoint: run a *mounted* OpenVPN config. Nothing site-specific lives in
# the image -- all behaviour (port, port-share, routes, PKI) is in the config the
# operator mounts at /etc/openvpn. Override the path with OPENVPN_CONFIG.
set -e

if [ ! -c /dev/net/tun ]; then
  echo "ERROR: /dev/net/tun missing -- run with devices:[/dev/net/tun] + cap_add:[NET_ADMIN]" >&2
  exit 1
fi

# exec so SIGTERM from `docker stop` reaches openvpn for a clean shutdown.
exec openvpn --config "${OPENVPN_CONFIG:-/etc/openvpn/openvpn.conf}"
