# monero
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![CI](https://github.com/comminutus/monero/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/monero/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/monero)](https://github.com/comminutus/monero/releases/latest)


## Description
This is a [Monero](https://www.getmonero.org/) container image built using the binaries distributed by the Monero team.  The container image runs `monerod`.

Since the distributed Monero binary uses dynamically-linked glibc, it uses the [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) base image.  This is a distroless container, and as such has very little attack surfaces.  It also has no shell, so it's not possible to execute a shell into the container.

## Getting Started
```
podman pull ghcr.io/comminutus/monero
podman run -it --rm ghcr.io/comminutus/monero
```

## Usage
Node that the container image does not set any other command line options other than `--data-dir` (see "Volumes" below).  If you need to run this non-interactively, use the `--non-interactive` command line option (i.e. `podman run -d ghcr.io/comminutus/monero --non-interactive`).

For a full list of command line options, consult the [Monero documentation](https://www.getmonero.org/).

### Persistent Data
The container's persistent data, including configuration and blockchain data are stored at _/var/lib/monero_.

When running the container image with Docker, Kubernetes, OpenShift, etc., mount your volumes at
_/var/lib/monero_.

### User/Group
Because the container uses Chainguard's image as a base, the `monerod` process is run as non-root.

### Ports
The container exposes the following ports:
| Port  | Enabled by Default? | Use                                                                                |
| ----- | :-----------------: | ---------------------------------------------------------------------------------- |
| 18080 | Y                   | peer-to-peer communications; used for nodes to communicate with other nodes        |
| 18081 | Y                   | RPC communications, used for wallets and other tools to communicate with this node |
| 18082 | N                   | JSON-RPC port                                                                      |
| 28080 | N                   | _stagenet_ peer-to-peer communications                                             |
| 28081 | N                   | _stagenet_ RPC communications                                                      |
| 28082 | N                   | _stagenet_ JSON-RPC port                                                           |
| 38080 | N                   | _testnet_ peer-to-peer communications                                              |
| 38081 | N                   | _testnet_ RPC communications                                                       |
| 38082 | N                   | _testnet_ JSON-RPC port                                                            |

## Dependencies
| Name                                         | Version   |
| -------------------------------------------- | --------- |
| [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) | latest |
| [Monero](https://www.getmonero.org/)         | v0.18.3.4 |

## License
The container image portion of this project is licensed under the GNU Affero General Public License v3.0 - see the
[LICENSE](LICENSE) file for details.

The Monero software binaries included with this container image inherit Monero's license - see the 
[MONERO LICENSE](MONERO_LICENSE) file for details.

The Chainguard _glibc-dynamic_ base container image is licensed under the [Apache 2.0 License](https://github.com/chainguard-images/images/blob/main/LICENSE)
