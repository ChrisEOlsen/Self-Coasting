### Useful Commands
Use this command to generate credentials
```bash
echo $(htpasswd -nB username) | sed -e s/\\$/\\$\\$/g
```
```bash
docker network create proxy
```

### Example internal application proxying:
```yaml
    labels:
      - "traefik.enable=true"

      # HTTP Router (optional): Redirects HTTP to HTTPS
      - "traefik.http.routers.whoami.entrypoints=web"
      - "traefik.http.routers.whoami.rule=Host(`whoami.crispychrisprivserver.org`)"
      - "traefik.http.routers.whoami.middlewares=redirect-to-https"

      # HTTPS Router
      - "traefik.http.routers.whoami-secure.entrypoints=websecure"
      - "traefik.http.routers.whoami-secure.rule=Host(`whoami.crispychrisprivserver.org`)"
      - "traefik.http.routers.whoami-secure.tls=true"
      - "traefik.http.routers.whoami-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.whoami-secure.middlewares=secure-headers"
      - "traefik.http.routers.whoami-secure.service=whoami-service"

      # Service
      - "traefik.http.services.whoami-service.loadbalancer.server.port=81"
```

