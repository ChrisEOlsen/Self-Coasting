# Traefik Setup for crispychrisprivserver.org

## Environment Variables
Export the following environment variables in your terminal session before running the Traefik setup:

```bash
export CF_TOKEN="your_cloudflare_api_token_here"
export TRAEFIK_DASHBOARD_CREDENTIALS="your_dashboard_credentials_here"
export DOMAIN="yourrootdomain.com"
export EMAIL="your_email_here"
```

- `CF_TOKEN`: Your Cloudflare API token with the required permissions.
- `TRAEFIK_DASHBOARD_CREDENTIALS`: Basic auth credentials for the Traefik dashboard in the format `username:hashed_password`.
- `DOMAIN`: The root domain for your setup (e.g., `crispychrisprivserver.org`).
- `EMAIL`: The email address used for certificate generation.

## Running Traefik
After exporting the environment variables, start Traefik using Docker Compose:

```bash
docker-compose up -d
```

## Notes
- Ensure the `cf-token` file is updated with the correct Cloudflare API token if you prefer using Docker secrets.
- The `acme.json` file must have the correct permissions (`chmod 600 acme.json`) to store certificates securely.