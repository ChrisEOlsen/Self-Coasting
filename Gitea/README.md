# 💾 **Self-Hosted Gitea + Google Drive Backups**

A fully self-contained Git platform on your own infrastructure with:

* 🚀 Public access via Traefik + Cloudflare Tunnel
* 🔐 Secure SSH pushes via Tailscale
* ☁️ Daily backups to Google Drive via Rclone
* ✅ Optional Google OAuth login
* 🔄 No rate limits, great for CI/CD pipelines

---

## ✅ Prerequisites

Before you begin, ensure you have the following working:

1. **Traefik v3** configured to proxy Docker containers via labels
2. **Cloudflare Tunnel** exposing Gitea (e.g. `gitea.yourdomain.com`)
3. **Tailscale** active on both your dev machine and home server
4. (Optional) Google Cloud project with **Drive API** enabled

---

## 📁 Directory Layout

```
server/
├── gitea/
│   ├── gitea-data/              # Gitea's persistent data
│   ├── postgres/                # PostgreSQL data
│   ├── rclone/                  # Contains rclone.conf
│   ├── backups/                 # Backup destination
│   ├── scripts/
│   │   └── backup.sh            # Automated backup script (chmod +x!)
│   ├── docker-compose.yml       # All services
│   └── .env                     # Secrets and DB credentials
```

---

## 🛠 Setup Instructions

### 1. Clone and Configure

```bash
git clone git@github.com:YourUser/Self-Coasting.git
cd server/gitea
```

Edit your `.env`:

```env
POSTGRES_USER=gitea
POSTGRES_PASSWORD=your_secure_pw
GITEA_DB_USER=gitea
GITEA_DB_PASSWORD=your_secure_pw
PGPASSWORD=your_secure_pw
```

---

### 2. Setup `rclone.conf`

On any GUI-capable machine:

```bash
rclone config
```

When prompted:

* **New remote name**: `G-Drive`
* **Type**: `drive`
* **Scope**: `1` (full access)
* **Client ID/Secret**: *press Enter to use default or set your own*
* **Follow the browser auth flow**
* **Test user**: add your Gmail if asked
* **Save the config**

Copy the generated `rclone.conf` to:

```bash
cp ~/.config/rclone/rclone.conf ./rclone/rclone.conf
```

---

### 3. Make the Script Executable

```bash
chmod +x scripts/backup.sh
```

This is required for the backup container to run correctly.

---

### 4. Deploy Gitea

```bash
docker compose up -d
```

Visit your domain:

```
https://gitea.yourdomain.com
```

Go through the **web installer**, using:

* DB Type: Postgres
* DB User/Pass: from `.env`
* Set your initial admin user

---

### 5. 🔐 Disable Public Registration

After logging in:

1. Go to ⚙️ **Site Admin → Configuration**
2. Find the `[service]` section
3. Set:

   * `DISABLE_REGISTRATION = true`
   * `REQUIRE_SIGNIN_VIEW = true`
4. Restart Gitea:

```bash
docker compose restart gitea
```

---

### 6. (Optional) Google OAuth Login

This is *optional*, and setup is minimal:

1. In [Google Cloud Console](https://console.cloud.google.com):

   * Create a project
   * Enable **Google Drive API**
   * Go to OAuth Credentials → Create OAuth client ID
   * Application type: Web
   * Set it to **External** access
   * Add your test Gmail account

> ✅ *No redirect URI or approval required when using default rclone auth flow or Gitea's basic OAuth*

2. In Gitea → Site Admin → Authentication Sources → Add OAuth2:

   * Provider: `Google`
   * Add Client ID / Secret
   * Enable auto-registration if desired

---

### 7. 🧪 Use SSH for Pushing Code

On your dev machine:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

1. Add the public key to:

   * **Gitea → Profile → Settings → SSH/GPG Keys**

2. In your repo:

```bash
git remote add gitea ssh://git@<tailscale-hostname>:2222/youruser/repo.git
git push -u gitea main
```

---

### 8. ☁️ Backup Behavior

The `rclone-backup` container runs the `scripts/backup.sh` script every 24h:

* Dumps PostgreSQL to `gitea-db.sql`

* Archives `/data` as `gitea-data.tar.gz`

* Uploads both to:

  ```
  G-Drive:gitea-backups/<timestamp>/
  ```

* Automatically **cleans up old backups >7 days** (both local & remote)

---

## 🔄 How to Restore

If disaster strikes:

1. Restore the original directory layout from backup
2. Update `.env` with a *new password* if needed
3. Start just the DB:

```bash
docker compose up -d db
```

4. Restore:

```bash
docker exec -i gitea-db psql -U gitea gitea < /backups/<timestamp>/gitea-db.sql
```

5. Restart everything:

```bash
docker compose up -d
```

---

## 🔚 Summary

**Why use this setup?**

* Full control over your Git server
* Private, rate-limit free, and integrates seamlessly with CI/CD
* Daily offsite backups for peace of mind

