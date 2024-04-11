#!/bin/bash
set -eo pipefail

args=(                                              \
    --data-dir          "$MONERO_DATA_DIR"          \
    --log-level         "$MONERO_LOG_LEVEL"         \
    --p2p-bind-ip       "$MONERO_P2P_BIND_IP"       \
    --p2p-bind-port     "$MONERO_P2P_BIND_PORT"     \
    --p2p-external-port "$MONERO_P2P_EXTERNAL_PORT" \
    --rpc-bind-ip       "$MONERO_RPC_BIND_IP"       \
    --rpc-bind-port     "$MONERO_RPC_BIND_PORT"     \
)

if [[ ! "$MONERO_RPC_BIND_IP" == 127.* ]]; then
    args+=(--confirm-external-bind)
fi

if [[ ! -z "$MONERO_DISABLE_DNS_CHECKPOINTS" ]]; then
    args+=(--disable-dns-checkpoints)
fi

if [[ ! -z "$MONERO_ENABLE_DNS_BLOCKLIST" ]]; then
    args+=(--enable-dns-blocklist)
fi

if [[ ! -z "$MONERO_NON_INTERACTIVE" ]]; then
    args+=(--non-interactive)
fi

if [[ ! -z "$MONERO_RPC_RESTRICTED_BIND_IP" ]]; then
    args+=(--restricted-bind-ip "$MONERO_RPC_RESTRICTED_BIND_IP")
fi

if [[ ! -z "$MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS" ]]; then
    args+=(--rpc-restricted-bind-ipv6-address "$MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS")
fi

if [[ ! -z "$MONERO_TX_PROXY" ]]; then
    args+=(--tx-proxy "$MONERO_TX_PROXY")
fi

if [[ ! -z "$MONERO_ZMQ_PUB" ]]; then
    args+=(--zmq-pub "$ZMQ_PUB")
fi

if [ "$MONERO_ADDITIONAL_ARGS" ]; then
    read -ra additional_args <<< "$MONERO_ADDITIONAL_ARGS"
    args+=("${additional_args[@]}")
fi

echo "$MONERO_INSTALL_DIR/monerod" "${args[@]}"
exec "$MONERO_INSTALL_DIR/monerod" "${args[@]}"
