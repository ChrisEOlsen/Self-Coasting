# Ollama Runtime Host (External GPU Machine)

This setup defines the Docker configuration for an external machine (e.g., a desktop with a GPU) to serve as the **runtime backend for Ollama**, which can be securely accessed from a remote home server via Tailscale.

> ✅ **This host is intended to run Ollama only — not serve web UI.**  
> 🧱 A separate machine (your home server) will host the authenticated Open WebUI front-end via Traefik and Authentik.

---

## 🔐 Prerequisites

- A working **Traefik + Authentik reverse proxy** is already configured on your home server.
- You have **Tailscale** installed on both:
  - This external machine (your GPU machine)
  - Your home server

---

## 🛠️ Setup Steps

### 1. Clone or copy the `docker-compose.yml` below into a directory on your external machine:

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities:
                - gpu
    volumes:
      - ./ollama:/root/.ollama
    ports:
      - "11434:11434"  # Expose Ollama's HTTP API to your local network
    tty: true
    restart: unless-stopped
```
## For purely local setup, you can do:
```yaml
services:
  ollama:
    # Uncomment below for GPU support - ensure correct driver
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities:
    #             - gpu
    volumes:
      - ./ollama:/root/.ollama
    # Uncomment below to expose Ollama API outside the container stack
    ports:
      - 11434:11434
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    image: ollama/ollama:latest


  open-webui:
    build:
      context: .
      args:
        OLLAMA_BASE_URL: '/ollama'
      dockerfile: Dockerfile
    image: ghcr.io/open-webui/open-webui:latest
    container_name: open-webui
    volumes:
      - ./open-webui-data:/app/backend/data
    depends_on:
      - ollama
    ports:
      - 3000:8080
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY=example'
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped

volumes:
  ollama: {}
  open-webui: {}
```
