## Prerequisites
- Installed Docker Engine
- Domain for your server purchased on Cloudflare (or transferred from other provider like Namecheap).
- Create a network called "proxy" for any application you want traefik to direct traffic to.
```bash
docker network create proxy
```
- Cloudflare tunnel running on the server. <br/>
- Public hostnames added to cloudflare tunnel (best done via dashboard). <br/>
NOTE: If running on docker-container, ensure that the tunnel is on a network "proxy", and that the public hostnames are pointing to https://traefik:443 instead of https://localhost:443. <br/>
In addition, set <br/>
**Additional Application Settings > TLS Origin Server Name**<br/>
and <br/>
**HTTP Settings > HTTP Host Header** <br/>
to the full domain for those containers - traefik.yourdomain.com, authentik.yourdomain.com
- Generate and add values for AUTHENTIK_SECRET_KEY and PG_PASS to .env
```bash
# 32 bytes → 64 hex characters
openssl rand -hex 32
# or  
openssl rand -base64 48
```

## Intial Setup
Once docker containers are running and healthy <br/>
Go to: http://authentik.<your-domain.com>/if/flow/initial-setup/ <br/>
Create an admin account <br/>

You should be able to log in to the authentik dashboard at this stage, but not Traefik dashboard just yet.

## Adding Traefik (and other applications) to Authentik

Go to: Applications > Applications and click "Create with Provider" <br/>
Choose Proxy provider, pick an authorization flow (I suggest implicit for user friendly flow)<br/>
Choose Forward Auth Single Application. <br/>
Set the External URL to https://traefik.your-domain.com <br />
I suggest binding a group like "Authentik Admins" <br /> 

For each new application you will need to create a new provider if you want to maintain per-app access controls.<br />
If you just want the same authentication flow and group for every subdomain, choose domain level.<br />

## Adding application to Outpost (Embedded outpost)

Go to Applications > Outpost and click "edit" on the Default embedded outpost. <br />
Find the application you just added (Traefik Dashboard) and add it to the outpost.<br />

At this point you should be able to access the traefik dashboard with your admin credentials created with authentik.

## Labels for applications
Protect and application connected to Traefik Proxy with Authentik:
```yaml
labels:
- "traefik.enable=true"

# HTTP Router – redirect to HTTPS
- "traefik.http.routers.myapp.entrypoints=web"
- "traefik.http.routers.myapp.rule=Host(`appname.yourdomain.com`)"
- "traefik.http.routers.myapp.middlewares=redirect-to-https"

# HTTPS Router – secured by Authentik + secure headers
- "traefik.http.routers.myapp-secure.entrypoints=websecure"
- "traefik.http.routers.myapp-secure.rule=Host(`appname.yourdomain.com`)"
- "traefik.http.routers.myapp-secure.tls=true"
- "traefik.http.routers.myapp-secure.tls.certresolver=cloudflare"
- "traefik.http.routers.myapp-secure.middlewares=authentik,secure-headers"
- "traefik.http.routers.myapp-secure.service=myapp-service"

# Service Port
- "traefik.http.services.myapp-service.loadbalancer.server.port=YOUR_APP_PORT"
```

Publicly accessible (no authentik protection)
```yaml
labels:
  - "traefik.enable=true"

  # HTTP Router – redirect to HTTPS
  - "traefik.http.routers.myapp.entrypoints=web"
  - "traefik.http.routers.myapp.rule=Host(`www.yourapp.com`)"
  - "traefik.http.routers.myapp.middlewares=redirect-to-https"

  # HTTPS Router – secured with headers only
  - "traefik.http.routers.myapp-secure.entrypoints=websecure"
  - "traefik.http.routers.myapp-secure.rule=Host(`www.yourapp.com`)"
  - "traefik.http.routers.myapp-secure.tls=true"
  - "traefik.http.routers.myapp-secure.tls.certresolver=cloudflare"
  - "traefik.http.routers.myapp-secure.middlewares=secure-headers" # No authentik here
  - "traefik.http.routers.myapp-secure.service=myapp-service"

  # Service Port
  - "traefik.http.services.myapp-service.loadbalancer.server.port=YOUR_APP_PORT"
```


# Adding applications that aleady have authentication built in, but still want Authentik? 
Create an OAuth Provider instead of a Proxy provider. Most appliations (like portainer) offer a custom OAuth Provider tab where you can configure this.<br/>
OR, you could just go with their built in login flow and the google chrome password manager...
