## Using as external runtime
Servers running apps like OpenWebUI or OpenHands can easily connect to an external runtime like this using Tailscale.<br/>
https://tailscale.com/<br/>
After running the Ollama runtime on your GPU powered machine, you can use:
```bash
ollama serve
```
This will make the Ollama instance available at http://ollama-machines-tailscale-ip:11434 for any server that is also connected to your Tailscale account