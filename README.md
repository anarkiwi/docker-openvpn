# docker-openvpn

A deliberately thin OpenVPN server image: `alpine` + `openvpn` + a trivial
entrypoint that runs a **mounted** config. Nothing site-specific is baked in, so
one image serves any host -- all behaviour (port, `port-share`, pushed routes,
PKI) lives in the config you mount.

Published to Docker Hub as [`anarkiwi/docker-openvpn`](https://hub.docker.com/r/anarkiwi/docker-openvpn).

## What it does (and doesn't)

- Runs `openvpn --config "${OPENVPN_CONFIG:-/etc/openvpn/openvpn.conf}"`.
- Refuses to start if `/dev/net/tun` is missing (a clear error beats a cryptic
  openvpn failure).
- `exec`s openvpn as PID 1 so `docker stop` (SIGTERM) shuts it down cleanly.
- Carries **no** NAT/firewall rules and **no** PKI. Masquerading,
  `ip_forward`, and certificate management are the operator's job on the host.

## Runtime requirements

OpenVPN needs the tun device and `NET_ADMIN`, and a server typically wants the
host's network namespace (to bind a public port and, e.g., share it with another
service). Mount your config + PKI at `/etc/openvpn`.

```yaml
services:
  openvpn:
    image: anarkiwi/docker-openvpn:1.0.0
    network_mode: host
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    volumes:
      - /etc/openvpn:/etc/openvpn:ro   # openvpn.conf + PKI + dh, read-only
```

Equivalent `docker run`:

```sh
docker run -d --name openvpn \
  --network host --cap-add NET_ADMIN --device /dev/net/tun \
  -v /etc/openvpn:/etc/openvpn:ro \
  anarkiwi/docker-openvpn:1.0.0
```

Point at a different config path with `-e OPENVPN_CONFIG=/etc/openvpn/server.conf`.

Logs go to stdout (`docker logs openvpn`); drop `log-append` from your config.

## Building locally

```sh
docker build -t docker-openvpn:test .
docker run --rm --entrypoint openvpn docker-openvpn:test --version
```

## Releasing

CI (`.github/workflows/ci.yml`) lints the Dockerfile (hadolint) and smoke-tests
the build on every push/PR. Pushing a `v*` tag triggers
`.github/workflows/publish.yml`, which builds multi-arch (amd64 + arm64) and
pushes to Docker Hub using the `DOCKER_USERNAME` / `DOCKER_TOKEN` repo secrets.

```sh
git tag v1.0.0
git push origin v1.0.0
```
