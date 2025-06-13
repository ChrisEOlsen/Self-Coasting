## Prerequisites 
1. Cloudflare account created
2. Cloudflare tunnel created from the Zero Trust Networks dashboard. <br/>
Go to: Zero Trust > Networks > Tunnels and click "Create tunnel".

3. Get the tunnel token by copying the install command that looks like:
```bash
docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoi...
```
Then paste into the .env file.

Then run the compose!
```bash
docker compose up -d
```