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
    libtorrent-rasterbar

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

# Create directories and generate qBittorrent config with password
RUN mkdir -p /home/seanime/.config/qBittorrent/qBittorrent/config && \
    mkdir -p /home/seanime/.config/Seanime && \
    mkdir -p /home/seanime/Downloads && \
    mkdir -p /home/seanime/anime && \
    qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent & \
    sleep 3 && \
    pkill qbittorrent-nox && \
    echo 'WebUI\\Password_PBKDF2=@ByteArray(ARQ77eY1NUZaQsuDHbIMCA==:0WMRkYTUWVT9wVvdDtHAjU9b3b7uB8NR1Gur2hmQCvCDpm39Q+PsJRJPaCU51dEiz+dTzh8qbPsL8WkFljQYFQ==)' \
    >> /home/seanime/.config/qBittorrent/qBittorrent/config/qBittorrent.conf

# Define volumes for persistent data
VOLUME ["/home/seanime/.config", "/home/seanime/Downloads", "/home/seanime/anime"]

# Declare ports (internal only)
EXPOSE 43211 8080 43213 43214 6881 6881/udp 10000

# Run both qBittorrent and Seanime
CMD ["bash", "-c", "qbittorrent-nox --webui-port=8080 --profile=/home/seanime/.config/qBittorrent --daemon && ./seanime --datadir /home/seanime/.config/Seanime"]
