```text
  _________      .__   _____         _________                        __  ._.
 /   _____/ ____ |  |_/ ____\        \_   ___ \  _________    _______/  |_| |
 \_____  \_/ __ \|  |\   __\  ______ /    \  \/ /  _ \__  \  /  ___/\   __\ |
 /        \  ___/|  |_|  |   /_____/ \     \___(  <_> ) __ \_\___ \  |  |  \|
/_______  /\___  >____/__|            \______  /\____(____  /____  > |__|  __
        \/     \/                            \/           \/     \/        \/
```

# 🚀 Self-Hosted Applications

> ⚠️ **NOTE:** Many of these services rely on the `Traefik+Authentik` stack for secure reverse proxying and authentication. A free Cloudflare account is necessary for these configurations to work right out of the gate. <br/>
https://www.cloudflare.com/

## 🧠 AI & LLMs

- **Ollama**<br/>
  An app used to easily download and run local LLM's. See models available here: https://ollama.com/library

- 🤖 **OpenWebUI**  
  A sleek frontend for interacting with local LLMs like Gemma using Ollama as the runtime. You can also add OpenAI API-Keys for pay as you go usage for enterprise models.

- 🤲 **OpenHands**<br/>
  An AI assissted coding platform that can interact with local LLM's for full privacy and control.

---

## 🧩 Core Infrastructure

- 🧩 **Traefik+Authentik**  
  Reverse proxy + SSO middleware for routing and securing all internal services.

- ⚙️ **Traefikv3**  
  An updated configuration for Traefik v3. Designed for advanced setups or production use.

- 🌐 **Cloudflare-Tunnel**  
  Securely expose local services through Cloudflare without opening ports on your router.

- 🛡️ **Teleport**  
  Access management for SSH, Kubernetes, and web apps — with RBAC, auditing, and session recording.

---

## ⚙️ DevOps & System Management

- 🛠️ **Portainer**  
  A sleek web UI to manage your Docker containers, images, volumes, and networks.

- 📊 **Netdata**  
  Real-time performance monitoring and visualization for systems and applications.


- 💾 **Gitea: Self-Hosted Git with Google Drive Backups**<br>
  A private, full-featured Git service with automated daily backups — no limits, no vendor lock-in, better CI/CD integration.

- 📀 **rclone: Server wide backups to Google Drive** <br>
    A simle way to backup all of your servers data straight into Google Drive!

---

## 👨‍💻 Development Tools

- 📓 **JupyterLab**  
  A powerful web-based IDE for coding, data exploration, and running interactive notebooks.

- 🧰 **IT-Tools**  
  A self-hosted collection of handy web utilities — encoders, hash generators, formatters, and more.

- 🧑‍💻 **Neovim** <br>
  A simple yet effective minimalisitic neovim configuration with skeleton code keymaps for Nextjs and FastAPI

---


## 🎮 Games & Fun

- ⛏️ **Minecraft**  
  A containerized, self-hosted Minecraft server for solo or multiplayer adventures.

---

## 🔐 Utilities

- 📦 **Enclosed**  
  A self-hosted app for creating one-time secret message links — great for secure sharing.

- 🔒 **Vaultwarden** <br>
    A self hosted Bitwarden cloud.

---
