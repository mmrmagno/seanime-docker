#!/bin/bash
set -e

QB_CONF="/home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf"
if [ ! -f "$QB_CONF" ]; then
    mkdir -p "$(dirname "$QB_CONF")"
    cp /tmp/qbittorrent.conf "$QB_CONF"
fi

qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon

SEANIME_CONF="/home/seanime/.config/Seanime/config.toml"
if [ ! -f "$SEANIME_CONF" ]; then
    mkdir -p "$(dirname "$SEANIME_CONF")"
    printf "[server]\nhost = '0.0.0.0'\n" > "$SEANIME_CONF"
else
    sed -i "s/host = '127.0.0.1'/host = '0.0.0.0'/" "$SEANIME_CONF"
fi

/app/monitor-config.sh &
exec /app/seanime --datadir /home/seanime/.config/Seanime
