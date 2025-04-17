## Intial Setup
Once docker containers are running and healthy <br/>
Go to: http://authentik.your-domain.com/if/flow/initial-setup/ <br/>
Create an admin account

You should be able to log in to the authentik dashboard at this stage, but not Traefik dashboard just yet.

## Adding Traefik (and other applications) to Authentik

Go to: Applications > Applications and click "Create with Provider"
Choose Proxy provider, pick and authorization flow <br/>
Set the External URL to traefik.your-domain.com <br />
I suggest binding a group like "Authentik Admins" 

## Adding application to Outpost (Embedded outpost)

Go to Applications > Outpost and click "edit" on the Default embedded outpost. <br />
Find the application you just added (Traefik Dashboard) and add it to the outpost.<br />

At this point you should be able to access the traefik dashboard with you admin credentials created with authentik.

## Labels for applications
Protect and application connected to Traefik Proxy with Authentik:
```yaml
labels:
- "traefik.enable=true"

# HTTP Router – redirect to HTTPS
- "traefik.http.routers.myapp.entrypoints=web"
- "traefik.http.routers.myapp.rule=Host(`myapp.crispychrisprivserver.org`)"
- "traefik.http.routers.myapp.middlewares=redirect-to-https"

# HTTPS Router – secured by Authentik + secure headers
- "traefik.http.routers.myapp-secure.entrypoints=websecure"
- "traefik.http.routers.myapp-secure.rule=Host(`myapp.crispychrisprivserver.org`)"
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
  - "traefik.http.routers.myapp.rule=Host(`myapp.crispychrisprivserver.org`)"
  - "traefik.http.routers.myapp.middlewares=redirect-to-https"

  # HTTPS Router – secured with headers only
  - "traefik.http.routers.myapp-secure.entrypoints=websecure"
  - "traefik.http.routers.myapp-secure.rule=Host(`myapp.crispychrisprivserver.org`)"
  - "traefik.http.routers.myapp-secure.tls=true"
  - "traefik.http.routers.myapp-secure.tls.certresolver=cloudflare"
  - "traefik.http.routers.myapp-secure.middlewares=secure-headers" # No authentik here
  - "traefik.http.routers.myapp-secure.service=myapp-service"

  # Service Port
  - "traefik.http.services.myapp-service.loadbalancer.server.port=YOUR_APP_PORT"
```
