#!/bin/bash
CONFIG_FILE="/home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf"
echo "Starting qBittorrent config monitor..."
while true; do
  inotifywait -e modify,create,delete,move "$CONFIG_FILE" 2>/dev/null
  echo "Config file changed, restarting qBittorrent..."
  pkill qbittorrent-nox
  sleep 2
  qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon
  echo "qBittorrent restarted"
done
