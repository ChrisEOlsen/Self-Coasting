### Useful Commands
Use this command to generate credentials
```bash
echo $(htpasswd -nB chris) | sed -e s/\\$/\\$\\$/g
```


Use this command to create an external network (this is for swarm modes)
```bash
docker network create --driver overlay --attachable proxy
```
When not using swarm mode:
```bash
docker network create proxy
```

### Example internal application proxying:
```yaml
  frontend-main:
    image: exersites_frontend:latest
    networks:
      - proxy # Ensure the network for the proxy is added
      - exersites_public
      - exersites_api
    command: ["npm", "run", "start"] # ✅ Ensures it runs in dev mode
    deploy:
      replicas: 1
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend-main.entrypoints=http"
      - "traefik.http.routers.frontend-main.rule=Host(`exersites.crispychrisprivserver.org`)"
      - "traefik.http.middlewares.frontend-main-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.frontend-main.middlewares=frontend-main-https-redirect"
      - "traefik.http.routers.frontend-main-secure.entrypoints=https"
      - "traefik.http.routers.frontend-main-secure.rule=Host(`exersites.crispychrisprivserver.org`)" 
      - "traefik.http.routers.frontend-main-secure.tls=true"
      - "traefik.http.routers.frontend-main-secure.service=frontend-main"
      - "traefik.http.services.frontend-main.loadbalancer.server.port=3000"
      - "traefik.docker.network=proxy"
```

### Example internal application proxying with just a prefix for specific endpoints
```yaml
  backend:
    image: exersites_backend:latest
    networks:
      - proxy 
    ports:
      - "8000:8000" # ⬅️ Add this temporarily during DEV - REMOVE FOR PRODUCTION
    volumes:
      - ./fastapi:/fastapi
    command: ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend-webhooks.rule=Host(`exersites.crispychrisprivserver.org`) && PathPrefix(`/webhooks/stripe`)" # Only the webhooks are exposed to the outside world
      - "traefik.http.routers.backend-webhooks.entrypoints=https"
      - "traefik.http.routers.backend-webhooks.tls=true"
      - "traefik.http.services.backend-webhooks.loadbalancer.server.port=8000"
      - "traefik.docker.network=proxy"
```