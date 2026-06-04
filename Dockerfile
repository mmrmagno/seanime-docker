FROM alpine:3.19

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

ARG TARGETARCH
RUN set -eux; \
    TAG=$(curl -s https://api.github.com/repos/5rahim/seanime/releases/latest | jq -r .tag_name); \
    VERSION="${TAG#v}"; \
    case "$TARGETARCH" in \
      arm64) ARCH="arm64" ;; \
      *)     ARCH="x86_64" ;; \
    esac; \
    FILENAME="seanime-${VERSION}_Linux_${ARCH}.tar.gz"; \
    wget "https://github.com/5rahim/seanime/releases/download/${TAG}/${FILENAME}"; \
    tar -xzf "${FILENAME}"; \
    rm "${FILENAME}"; \
    chmod +x seanime

COPY qbittorrent.conf /tmp/qbittorrent.conf
COPY scripts/ /app/
RUN chmod +x /app/start.sh /app/monitor-config.sh

RUN mkdir -p /home/seanime/.config/qBittorrent/qBittorrent/config && \
    mkdir -p /home/seanime/.config/Seanime && \
    mkdir -p /home/seanime/Downloads && \
    mkdir -p /home/seanime/anime

VOLUME ["/home/seanime/.config", "/home/seanime/Downloads", "/home/seanime/anime"]

EXPOSE 43211 8080 43213 43214 6881 6881/udp 10000

CMD ["/app/start.sh"]
