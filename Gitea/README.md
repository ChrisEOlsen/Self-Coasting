# Self-Hosted Gitea + Rclone Backup Setup

This repo contains a production-ready self-hosted Gitea setup with:

* 🚀 Public access via Traefik + Cloudflare Tunnel
* 🔑 Google OAuth login (optional)
* 🧠 Rclone backups to Google Drive (daily + 7-day retention)
* 🔒 Secure SSH-based Git push/pull using Tailscale

---

## ✅ Prerequisites

Ensure the following infrastructure is already configured:

1. **Traefik v3** reverse-proxying traffic with dynamic labels.
2. **Cloudflare Tunnel** exposing Gitea (e.g. `gitea.yourdomain.com`).
3. **Tailscale** active on your dev machine and home server.

---

## 📁 Repo Structure

```
server/
├── gitea/
│   ├── gitea-data/              # Gitea's persistent data
│   ├── postgres/                # PostgreSQL data
│   ├── rclone/                  # Contains rclone.conf
│   ├── backups/                 # Backup destination
│   ├── scripts/
│   │   └── backup.sh            # Automated backup script
│   ├── docker-compose.yml       # Main service definition
│   └── .env                     # Secure environment secrets
```

---

## 🔧 Step-by-Step Setup

### 1. Clone & Configure

```bash
git clone git@github.com:YourUser/Self-Coasting.git
cd server/gitea
```

Update `.env` with strong secure values:

```env
POSTGRES_USER=gitea
POSTGRES_PASSWORD=your_strong_db_password
GITEA_DB_USER=gitea
GITEA_DB_PASSWORD=your_strong_db_password
PGPASSWORD=your_strong_db_password
```

---

### 2. Generate `rclone.conf`

On a browser-enabled machine (e.g., your desktop):

```bash
rclone config
```

Steps:

* New remote: `G-Drive`
* Type: `drive`
* Scope: `1` (full access)
* Use default client ID or create your own (recommended)
* Follow the authorization flow
* Save the resulting `rclone.conf` to `./rclone/rclone.conf`

---

### 3. Make the Backup Script Executable

```bash
chmod +x scripts/backup.sh
```

---

### 4. Deploy

```bash
docker compose up -d
```

Then visit:

```
https://gitea.yourdomain.com
```

Complete the **web installer** using:

* DB Type: Postgres
* DB User/Pass: from `.env`
* Admin account: your credentials

---

### 5. 🔐 Disable Public Registration

Once logged in:

1. Go to ⚙️ **Site Admin → Configuration**

2. Scroll to `[service]` and set:

   * `DISABLE_REGISTRATION = true`
   * `REQUIRE_SIGNIN_VIEW = true`

3. Save and restart Gitea:

```bash
docker compose restart gitea
```

You can also edit `gitea/conf/app.ini` directly and restart.

---

### 6. 🔑 (Optional) Google OAuth Login

1. Go to: [https://console.cloud.google.com](https://console.cloud.google.com)
2. Create new OAuth 2.0 Credentials

   * Authorized Redirect URI:
     `https://gitea.yourdomain.com/user/oauth2/google/callback`
3. Copy `Client ID` and `Client Secret`
4. In Gitea:

   * Site Admin → Authentication Sources → Add OAuth2
   * Name: `Google`
   * Provider: `Google`
   * Fill in Client ID / Secret
   * Enable Auto-register if desired

---

### 7. 🧪 Push Code via SSH + Tailscale

#### On your dev machine:

1. Ensure Tailscale is active and connected
2. Generate an SSH key (if needed):

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

3. Add your **public key** to Gitea:
   Profile → Settings → SSH/GPG Keys → Add Key

4. Set up your remote:

```bash
git remote add gitea ssh://git@<your-server-tailscale-domain>:2222/youruser/repo.git
git push -u gitea main
```

---

### 8. 🛡️ Enable 2FA

For extra security:

* Go to: Profile → Settings → Security
* Enable 2FA
* Use your preferred app (Apple Passwords, Bitwarden, etc.)

---

### 9. ☁️ Backup Behavior

The `rclone-backup` container:

* Runs `scripts/backup.sh` every 24h
* Archives:

  * PostgreSQL DB
  * Gitea data
* Uploads to: `G-Drive:gitea-backups/<timestamp>/`
* Deletes backups older than **7 days** (both locally and in GDrive)

To modify retention or behavior, edit `scripts/backup.sh`.

---

## 🎁 Extras

* Want to share a repo?

  * Go to Repo → Settings → Make Public ✅
* Want to share privately?

  * Create a user → Force password change
  * Grant repo access manually

---

