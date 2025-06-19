# OpenHands Self-Hosted Setup

This repository contains a `docker-compose.yml` file for deploying [OpenHands](https://github.com/all-hands-ai/openhands) — a self-hosted AI coding agent platform — integrated with a GPU-enabled [Ollama](https://ollama.com) LLM runtime over Tailscale. Its basically like Claude, but self-hosted and private.

---

## 📦 Overview

- **Service:** `all-hands-ai/openhands:0.44`
- **LLM Runtime:** External [Ollama](https://ollama.com) instance (e.g., `gemma`, `llama3`, etc.)
- **Authentication:** Handled by [Authentik](https://goauthentik.io/) via Traefik middleware
- **Networking:** Joined to a shared external `proxy` network managed by [Traefik](https://traefik.io/)

---

## 🔧 Prerequisites

Before deploying, ensure you have the following:

- **Tailscale** installed and configured on:
  - 🧠 **Server A** (this machine): Running OpenHands
  - ⚡ **Server B** (external with GPU): Running Ollama
- **A valid domain** pointed to your Traefik instance (e.g., `openhands.yourdomain.com`)
- Added the OpenHands application to Authentik for secure access.