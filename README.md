<div align="center">
  <img src="assets/logo.svg" alt="Seanime Logo" width="128" height="128">
</div>

# 🌊 Seanime Docker Image

A lightweight, all-in-one Docker image for the latest [Seanime](https://seanime.rahim.app/) anime streaming app — bundled with `qBittorrent-nox` and ready to use out of the box.

## 🐳 Features

* ✅ Automatically fetches the latest Seanime release
* ⚙️ Preconfigured `qBittorrent` Web UI (`admin:adminadmin`)
* 📦 Based on Alpine Linux for minimal size
* 🔧 Ideal for self-hosted setups with persistent volumes

---

## 📦 Docker Hub

➡️ [View on Docker Hub](https://hub.docker.com/r/mmr757/seanime)

```bash
docker pull mmr757/seanime:latest
```

---

## 🧰 Quick Start (docker-compose)

```yaml
services:
  seanime:
    image: mmr757/seanime:latest
    container_name: seanime
    restart: unless-stopped
    ports:
      - 8080:8080       # qBittorrent WebUI
      - 43211:43211     # Seanime
      - 6881:6881       # BitTorrent TCP
      - 6881:6881/udp   # BitTorrent UDP
      - 10000:10000     # Reserved / optional
    volumes:
      - ./config/seanime:/home/seanime/.config/Seanime
      - ./config/qbittorrent:/home/seanime/.config/qBittorrent
      - ./downloads:/home/seanime/Downloads
      - ./anime:/home/seanime/anime
```

---

## 🔐 Default Credentials

| Service        | Username | Password     |
| -------------- | -------- | ------------ |
| qBittorrent UI | `admin`  | `adminadmin` |

---

## 💡 Credits

* 🎨 [**5rahim**](https://github.com/5rahim) – Creator of [Seanime](https://github.com/5rahim/seanime).
* 🚀 [**hhftechnology**](https://github.com/hhftechnology) – Inspiration.
