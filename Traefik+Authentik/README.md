Here is your complete `README.md` with the **Cloudflare API Token** section integrated in a natural location after the “Prerequisites” section, preserving all your original instructions while improving clarity and formatting slightly:

---

# Traefik + Authentik Reverse Proxy Setup

## Prerequisites

- Installed **Docker Engine**
- A **domain** for your server, purchased or transferred to [Cloudflare](https://cloudflare.com)
- Create a Docker network called `proxy` (used for Traefik and all proxied apps):
  ```bash
  docker network create proxy
  ```

* A **Cloudflare Tunnel** running on the server
* **Public hostnames** added to the Cloudflare tunnel (recommended via dashboard)

🛠️ **Note:**
If running your Cloudflare tunnel inside Docker, ensure:

 * The tunnel container is on the same `proxy` network
 * Your public hostnames route to `https://traefik:443` (not `localhost`)
 * In your tunnel settings:
   * `TLS Origin Server Name` = `traefik.yourdomain.com`
   * `HTTP Host Header` = full domain for each app (e.g. `authentik.yourdomain.com`)

* Generate and add secrets to `.env`:

  ```bash
  # 32 bytes → 64 hex characters
  openssl rand -hex 32
  # or  
  openssl rand -base64 48
  ```

  Set these values in `.env`:

  * `AUTHENTIK_SECRET_KEY`
  * `PG_PASS`
  * (others as needed)

---

## 🔐 Setting Up Cloudflare API Token

To enable automatic HTTPS with Let's Encrypt using Cloudflare DNS challenge, you need to create an API token with proper permissions.

### Steps:

1. Go to [Cloudflare Dashboard → API Tokens](https://dash.cloudflare.com/profile/api-tokens)

2. Click **"Create Token"**

3. Choose **"Custom token"**

4. Add these **permissions**:

   | Permission Group | Permission | Resources                            |
   | ---------------- | ---------- | ------------------------------------ |
   | Zone             | DNS        | Include → All zones your domain uses |
   | Zone             | Zone       | Include → All zones your domain uses |

5. Optional (if managing tunnels programmatically):
   Add → **Account → Cloudflare Tunnel → Read**

6. Name your token (e.g. `Traefik DNS Token`)

7. After generating the token, save it in a file named `cf-token` in your project root:

   ```bash
   echo "your-token-here" > cf-token
   ```

> ⚠️ Do **not** commit `cf-token` to git. It's a Docker secret, not an env var.

Traefik reads it via:

```yaml
secrets:
  cf-token:
    file: ./cf-token
```

And uses it in the container via:

```yaml
environment:
  - CLOUDFLARE_DNS_API_TOKEN_FILE=/run/secrets/cf-token
```

---

## Initial Setup

Once the Docker containers are running and healthy:
Visit `http://authentik.<your-domain.com>/if/flow/initial-setup/` and create an admin account.

At this stage, you can access the **Authentik dashboard**, but not yet the **Traefik dashboard**.

---

## Adding Traefik (and Other Apps) to Authentik

1. Go to **Applications → Applications → "Create with Provider"**
2. Choose **Proxy Provider**
3. Pick an **authorization flow** (I suggest **Implicit** for a user-friendly experience)
4. Choose **Forward Auth - Single Application**
5. Set the External URL:

   ```
   https://traefik.your-domain.com
   ```
6. Optionally bind it to a group like `Authentik Admins`

> 🛡️ Want per-app access control?
> Create a new provider per app.
> Otherwise, use the same one for all subdomains (Domain-level works too).

---

## Adding Application to Outpost (Embedded)

1. Go to **Applications → Outpost**
2. Click **Edit** on the "Default Embedded Outpost"
3. Add your newly created Traefik application to the outpost

At this point, you should be able to access **Traefik dashboard** protected by **Authentik**.

---

## Labels for Applications

### 🔒 Protected by Authentik

```yaml
labels:
  - "traefik.enable=true"

  # Redirect HTTP → HTTPS
  - "traefik.http.routers.myapp.entrypoints=web"
  - "traefik.http.routers.myapp.rule=Host(`appname.yourdomain.com`)"
  - "traefik.http.routers.myapp.middlewares=redirect-to-https"

  # HTTPS Router – Authentik + secure headers
  - "traefik.http.routers.myapp-secure.entrypoints=websecure"
  - "traefik.http.routers.myapp-secure.rule=Host(`appname.yourdomain.com`)"
  - "traefik.http.routers.myapp-secure.tls=true"
  - "traefik.http.routers.myapp-secure.tls.certresolver=cloudflare"
  - "traefik.http.routers.myapp-secure.middlewares=authentik,secure-headers"
  - "traefik.http.routers.myapp-secure.service=myapp-service"

  # Internal service port
  - "traefik.http.services.myapp-service.loadbalancer.server.port=YOUR_APP_PORT"
```

---

### 🌐 Public Access (No Authentik)

```yaml
labels:
  - "traefik.enable=true"

  # Redirect HTTP → HTTPS
  - "traefik.http.routers.myapp.entrypoints=web"
  - "traefik.http.routers.myapp.rule=Host(`www.yourapp.com`)"
  - "traefik.http.routers.myapp.middlewares=redirect-to-https"

  # HTTPS Router – secure headers only
  - "traefik.http.routers.myapp-secure.entrypoints=websecure"
  - "traefik.http.routers.myapp-secure.rule=Host(`www.yourapp.com`)"
  - "traefik.http.routers.myapp-secure.tls=true"
  - "traefik.http.routers.myapp-secure.tls.certresolver=cloudflare"
  - "traefik.http.routers.myapp-secure.middlewares=secure-headers"
  - "traefik.http.routers.myapp-secure.service=myapp-service"

  # Internal service port
  - "traefik.http.services.myapp-service.loadbalancer.server.port=YOUR_APP_PORT"
```

---

## 🔄 Applications That Already Have Built-In Login?

If an app already handles authentication (like **Portainer**), but you still want centralized SSO:

* Create an **OAuth Provider** in Authentik instead of a Proxy provider.
* Many apps support **Custom OAuth Providers** natively.
* Otherwise, you can still use their internal login flow with a password manager.

---

```

Let me know if you'd like to split this into multiple `.md` files for clarity (e.g. `docs/cloudflare.md`, `docs/authentik.md`) or generate a `.env.template`.
```
