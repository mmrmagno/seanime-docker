FROM alpine:3.19

# Install all required packages
RUN apk add --no-cache \
    mpv \
    vim \
    qbittorrent-nox \
    curl \
    ca-certificates \
    wget \
    tar \
    jq \
    bash \
    ffmpeg \
    libstdc++ \
    boost-system \
    boost-program_options \
    qt5-qtbase \
    libtorrent-rasterbar \
    inotify-tools

WORKDIR /app

# Fetch latest Seanime release dynamically
RUN set -eux; \
    TAG=$(curl -s https://api.github.com/repos/5rahim/seanime/releases/latest | jq -r .tag_name); \
    VERSION="${TAG#v}"; \
    FILENAME="seanime-${VERSION}_Linux_x86_64.tar.gz"; \
    wget "https://github.com/5rahim/seanime/releases/download/${TAG}/${FILENAME}"; \
    tar -xzf "${FILENAME}"; \
    rm "${FILENAME}"; \
    chmod +x seanime

# Copy custom qBittorrent config
COPY qbittorrent.conf /tmp/qbittorrent.conf

# Create directories
RUN mkdir -p /home/seanime/.config/qBittorrent/qBittorrent/config && \
    mkdir -p /home/seanime/.config/Seanime && \
    mkdir -p /home/seanime/Downloads && \
    mkdir -p /home/seanime/anime

# Define volumes for persistent data
VOLUME ["/home/seanime/.config", "/home/seanime/Downloads", "/home/seanime/anime"]

# Declare ports (internal only)
EXPOSE 43211 8080 43213 43214 6881 6881/udp 10000

# Create config monitor script
RUN echo '#!/bin/bash' > /app/monitor-config.sh && \
    echo 'CONFIG_FILE="/home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf"' >> /app/monitor-config.sh && \
    echo 'echo "Starting qBittorrent config monitor..."' >> /app/monitor-config.sh && \
    echo 'while true; do' >> /app/monitor-config.sh && \
    echo '  inotifywait -e modify,create,delete,move "$CONFIG_FILE" 2>/dev/null' >> /app/monitor-config.sh && \
    echo '  echo "Config file changed, restarting qBittorrent..."' >> /app/monitor-config.sh && \
    echo '  pkill qbittorrent-nox' >> /app/monitor-config.sh && \
    echo '  sleep 2' >> /app/monitor-config.sh && \
    echo '  qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon' >> /app/monitor-config.sh && \
    echo '  echo "qBittorrent restarted"' >> /app/monitor-config.sh && \
    echo 'done' >> /app/monitor-config.sh && \
    chmod +x /app/monitor-config.sh

# Create startup script to fix host binding and apply qBittorrent config
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon' >> /app/start.sh && \
    echo 'sleep 3' >> /app/start.sh && \
    echo 'pkill qbittorrent-nox' >> /app/start.sh && \
    echo 'sleep 1' >> /app/start.sh && \
    echo 'if [ ! -f /home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf ] || ! grep -q "Password_PBKDF2" /home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf; then' >> /app/start.sh && \
    echo '  cat /tmp/qbittorrent.conf > /home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo 'qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon' >> /app/start.sh && \
    echo '/app/monitor-config.sh &' >> /app/start.sh && \
    echo './seanime --datadir /home/seanime/.config/Seanime &' >> /app/start.sh && \
    echo 'sleep 2' >> /app/start.sh && \
    echo 'if [ -f /home/seanime/.config/Seanime/config.toml ]; then' >> /app/start.sh && \
    echo '  sed -i "s/host = '\''127.0.0.1'\''/host = '\''0.0.0.0'\''/" /home/seanime/.config/Seanime/config.toml' >> /app/start.sh && \
    echo '  pkill seanime' >> /app/start.sh && \
    echo '  sleep 1' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo './seanime --datadir /home/seanime/.config/Seanime' >> /app/start.sh && \
    chmod +x /app/start.sh

# Run startup script
CMD ["/app/start.sh"]
