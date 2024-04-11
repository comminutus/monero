########################################################################################################################
# Configuration / Base Image
########################################################################################################################
# Core Config
ARG fedora_tag=39
ARG monero_version=0.18.3.3

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
ARG uid=10000
ARG build_dir=/tmp/build
ARG dist_dir=$build_dir/dist
ARG hashes_file=hashes.txt
ARG hashes_url=https://www.getmonero.org/downloads/$hashes_file
ARG install_dir=/usr/local/bin
ARG data_dir=/var/lib/monero

FROM fedora-minimal:$fedora_tag as base


########################################################################################################################
# Build Image
########################################################################################################################
FROM base as build
ARG build_dir dist_dir hashes_file hashes_url monero_version

# Update build image and install packages necessary for build
RUN microdnf update -y

# Copy assets
WORKDIR $build_dir
COPY . .

ARG build_packages='bzip2 gnupg2 tar wget'
RUN microdnf install -y $build_packages
#ARG build_packages='bzip2 ca-certificates gpg gpg-agent wget'

# Download hashes and verify
RUN gpg --import *.asc && \
    wget "$hashes_url" && \
    gpg --verify "$hashes_file"

RUN set -ex                                                   && \
  platform="$(uname -a | awk '{print tolower($1)}')"          && \
  arch="$(uname -m | sed 's/x86_64/x64/g')"                   && \
  archive="monero-$platform-$arch-v${monero_version}.tar.bz2" && \
  echo "$archive" > archive.txt

# Download Monero
RUN wget "https://downloads.getmonero.org/cli/$(cat archive.txt)"

# Verify Monero
RUN grep "$(cat archive.txt)" "$hashes_file" | sha256sum -c

# Extract archive
RUN mkdir -p "$dist_dir" && tar -xj --strip-components 1 -C "$dist_dir" -f "$(cat archive.txt)"


########################################################################################################################
# Final image
########################################################################################################################
FROM base as final
ARG data_dir dist_dir gid install_dir ports uid

WORKDIR /home/monero

# Update final image packages
RUN microdnf update -y

# Install necessary packages
ARG runtime_packages='shadow-utils'
RUN microdnf install -y $runtime_packages

# Environment variables, overridable from container
ENV MONERO_ADDITIONAL_ARGS=
ENV MONERO_DATA_DIR=$data_dir
ENV MONERO_LOG_LEVEL=0
ENV MONERO_DISABLE_DNS_CHECKPOINTS=
ENV MONERO_ENABLE_DNS_BLOCKLIST=true
ENV MONERO_INSTALL_DIR=$install_dir
ENV MONERO_NON_INTERACTIVE=true
ENV MONERO_P2P_BIND_IP=0.0.0.0
ENV MONERO_P2P_BIND_PORT=18080
ENV MONERO_P2P_EXTERNAL_PORT=0
ENV MONERO_RPC_BIND_IP=0.0.0.0
ENV MONERO_RPC_BIND_PORT=18081
ENV MONERO_RPC_RESTRICTED_BIND_IP=
ENV MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS=
ENV MONERO_TX_PROXY=
ENV MONERO_ZMQ_PUB=

# Install binaries
RUN mkdir -p "$install_dir" "$data_dir"
COPY --from=build $dist_dir $MONERO_INSTALL_DIR

# Create Monero user
RUN useradd -ms /bin/bash monero -u "$uid"


# Copy container entrypoint script into container
COPY entrypoint.bash .

# Change ownership of all files in user dir and data dir
RUN chown -R monero:monero "$data_dir" /home/monero

# Setup volume for blockchain
VOLUME $data_dir

# Expose ports
EXPOSE $ports

# Run as monero
USER monero

# Run entrypoint script
ENTRYPOINT ["./entrypoint.bash"]
