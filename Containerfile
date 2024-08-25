########################################################################################################################
# Configuration / Base Image
########################################################################################################################
# Core Config
ARG monero_version=0.18.3.4

# Ports:
# 18080: mainnet peer-to-peer; for nodes to communicate with other nodes
# 18081: mainnet RPC port
# 18082: mainnet JSON RPC port
# 18083: mainnet ZMQ port
# 28080: stagenet peer-to-peer; for nodes to communicate with other nodes
# 28081: stagenet RPC port
# 28082: stagenet JSON RPC port
# 28083: stagenet ZMQ port
# 38080: testnet peer-to-peer; for nodes to communicate with other nodes
# 38081: testnet RPC port
# 38082: testnet JSON RPC port
# 38083: testnet ZMQ port
ARG ports='18080 18081 18082 18083 28080 28081 28082 28083 38080 38081 38082 38083'

# Defaults
ARG build_dir=/tmp/build
ARG dist_dir=$build_dir/dist
ARG hashes_file=hashes.txt
ARG hashes_url=https://www.getmonero.org/downloads/$hashes_file
ARG data_dir=/var/lib/monero


########################################################################################################################
# Build Image
########################################################################################################################
FROM cgr.dev/chainguard/wolfi-base:latest as build
ARG build_dir dist_dir hashes_file hashes_url monero_version

# Copy assets
WORKDIR $build_dir
COPY binaryfate.asc .
COPY LICENSE
COPY MONERO_LICENSE

ARG build_packages='gpg wget'
RUN apk add $build_packages

# Download hashes and verify
RUN wget -q "$hashes_url"
ARG gpg_options='--batch --no-default-keyring'
RUN gpg $gpg_options --dearmor binaryfate.asc
RUN gpg $gpg_options --keyring ./binaryfate.asc.gpg --verify "$hashes_file"

RUN set -ex                                                   && \
  platform="$(uname -a | awk '{print tolower($1)}')"          && \
  arch="$(uname -m | sed 's/x86_64/x64/g')"                   && \
  archive="monero-$platform-$arch-v${monero_version}.tar.bz2" && \
  echo "$archive" > archive.txt

# Download Monero
RUN wget -q "https://downloads.getmonero.org/cli/$(cat archive.txt)"

# Verify Monero
RUN grep "$(cat archive.txt)" "$hashes_file" | sha256sum -c

# Extract archive
RUN mkdir -p "$dist_dir" && tar -xj --strip-components 1 -C "$dist_dir" -f "$(cat archive.txt)"


########################################################################################################################
# Final image
########################################################################################################################
FROM cgr.dev/chainguard/glibc-dynamic as final
ARG dist_dir ports

# Install binaries
COPY --from=build $dist_dir /usr/local/bin

# Setup a volume for blockchain
VOLUME /var/lib/monero

# Expose ports
EXPOSE $ports

# Run entrypoint script
ENTRYPOINT ["/usr/local/bin/monerod", "--data-dir", "/var/lib/monero"]
