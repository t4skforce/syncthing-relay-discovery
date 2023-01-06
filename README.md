# syncthing-relay-discovery
Docker Container for the global relay server for the [http://syncthing.net/](http://syncthing.net/) project. I build the container because there was no official one. This build is listening on the gihub project of the relay server and gets updated whenever there is a code change. [relaysrv GitHub repo](https://github.com/syncthing/relaysrv) and [dicosrv GitHub repo](https://github.com/syncthing/discosrv). The container is intended for people who like to roll their own private syncthing "cloud".

The files for this container can be found at my [GitHub repo](https://github.com/t4skforce/syncthing-relay-discovery)

[![](https://images.microbadger.com/badges/image/t4skforce/syncthing-relay-discovery.svg)](http://microbadger.com/images/t4skforce/syncthing-relay-discovery "Get your own image badge on microbadger.com") [![](https://img.shields.io/docker/automated/t4skforce/syncthing-relay-discovery.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay-discovery) [![docker-build-push](https://github.com/t4skforce/syncthing-relay-discovery/actions/workflows/main.yml/badge.svg)](https://github.com/t4skforce/syncthing-relay-discovery/actions/workflows/main.yml) [![](https://images.microbadger.com/badges/version/t4skforce/syncthing-relay-discovery.svg)](http://microbadger.com/images/t4skforce/syncthing-relay-discovery "Get your own version badge on microbadger.com") [![](https://img.shields.io/docker/pulls/t4skforce/syncthing-relay-discovery.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay-discovery) [![](https://img.shields.io/docker/stars/t4skforce/syncthing-relay-discovery.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay-discovery) [![](https://img.shields.io/github/last-commit/t4skforce/syncthing-relay-discovery.svg)](https://github.com/t4skforce/syncthing-relay-discovery) [![](https://img.shields.io/maintenance/yes/2023.svg)](https://github.com/t4skforce/syncthing-relay-discovery) [![](https://img.shields.io/github/issues-raw/t4skforce/syncthing-relay-discovery.svg)](https://github.com/t4skforce/syncthing-relay-discovery/issues) [![](https://img.shields.io/github/issues-pr-raw/t4skforce/syncthing-relay-discovery.svg)](https://github.com/t4skforce/syncthing-relay-discovery/pulls)

[![dockeri.co](http://dockeri.co/image/t4skforce/syncthing-relay-discovery)](https://hub.docker.com/r/t4skforce/syncthing-relay-discovery/)

# About the Container

This build is based on [debian:latest](https://hub.docker.com/_/debian/) and installs the latests successful build of the syncthing relay and discovery server.

# How to use this image

`docker run --name syncthing-relay -d -p 22067:22067 --restart=always t4skforce/syncthing-relay-discovery:latest`

This will store the certificates and all of the data in `/home/syncthing/`. You will probably want to make at least the certificate folder a persistent volume (recommended):

`docker run --name syncthing-relay -d -p 22067:22067 -v /your/home:/home/syncthing/certs --restart=always t4skforce/syncthing-relay-discovery:latest`

If you already have certificates generated and want to use them and protect the folder from being changed by the docker images use the following command:

`docker run --name syncthing-relay -d -p 22067:22067 -v /your/home:/home/syncthing/certs:ro --restart=always t4skforce/syncthing-relay-discovery:latest`

Creating cert directory and setting permissions (docker process is required to have access):
```bash
mkdir -p /your/home/certs
chown -R 1000:1000 /your/home/certs
```

# Container Configuration

There are several configuarion options available. The options are configurable via environment variables (docker default):

Example enabling debug mode:
```bash
export RELAY_OPTS='-debug'
export DISCO_OPTS='-debug'
docker run --name syncthing-relay-discovery -d -p 22067:22067 -p 22026:22026 --restart=always t4skforce/syncthing-relay-discovery:latest
```

or

```bash
docker run --name syncthing-relay-discovery -d -p 22067:22067 -p 22026:22026 -e RELAY_OPTS='-debug' -e DISCO_OPTS='-debug' --restart=always t4skforce/syncthing-relay-discovery:latest
```

## Docker Compose

```bash
---
version: '3'

services:
  syncthing-relay-discovery:
    container_name: syncthing
    restart: always
    image: t4skforce/syncthing-relay-discovery:latest
    environment:
      RELAY_OPTS: '-debug'
      DISC_OPTS: '-debug'
    ports:
      - 22067:22067
      - 22026:22026
```

## Options

* DEBUG: enable debugging (true/false) / default:false

### Syncthing-Relay Server

* RATE_GLOBAL: global maximum speed for transfer / default:10000000 = 10mbps
* RATE_SESSION: maximum speed for transfer per session / default:5000 = 500kbps
* TIMEOUT_MSG: change message timeout / default: 1m45s
* TIMEOUT_NET: change net timeout / default: 3m30s
* PING_INT: change ping timeout / default: 1m15s
* PROVIDED_BY: change provided by string / default:"syncthing-relay"
* RELAY_PORT: port the relay server listens on / default:22067
* STATUS_PORT: disable by default to enable it add `-p 22070:22070` to you `docker run` command  / default:22070
* POOLS: leave empty for private relay use "https://relays.syncthing.net/endpoint" for public relay / default: ""
* RELAY_OPTS: to provide addition options not configurable via env variables above / default: ""
  - example: `-e RELAY_OPTS='-ext-address=:443'`

### Syncthing-Discovery Server
* DISCO_PORT: port the discovery server listens on / default:22026
* DISCO_OPTS: to provide addition options not configurable via env variables above / default: ""
  - example: `-e DISCO_OPTS='-metrics-listen=:19201'`

Have a look at the current doc [GitHub - relaysrv](https://github.com/syncthing/relaysrv/blob/master/README.md) [GitHub - discosrv](https://github.com/syncthing/discosrv/blob/master/README.md)
