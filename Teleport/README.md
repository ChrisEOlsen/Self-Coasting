# Cloudflare Setup

### Create Cloudflare account and get domain
Plenty on this on google and youtube

### Enable Cloudflare SaaS mode 
Click on your domain that you purchased or added to the dashboard and navigate to SSL/TLS > Custom Host Names
From here you should be able to set a custom hostname for each app. 
Your base domain for the Teleport proxy should be something like "teleport.your_domain.com"
Then each custom hostname you add here should be something like "your-app.teleport.your-domain.com"

IMPORTANT: Make sure you add the DCV Delegation for Custom Hostnames record to your domains DNS settings.

### Go to Zero Trust > Network > Tunnels and create a tunnel. 
This tunnel creation will generate the CNAME record automagically. 
##### IMPORTANT SETTINGS:
For each public hostname you want proxied through Teleport <br /> 
including applications like your-app.teleport.your-domain.com: <br /> 
  Make the target URL: https://localhost:443 <br />
  TLS Origin Server Name: The same as your Teleport instances domain. Example: teleport.your-domain.com <br />
  HTTP Host Header: The same as the above <br />

### Run this command on your Linux host
This whole command can be found in your Zero Trust dashboard after creating the tunnel, and will include the token.
```bash
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 

sudo dpkg -i cloudflared.deb && 

sudo cloudflared service install your_token_will_be_here
```
NOTE: Keep this token super safe, and ideally do not save it anywhere. It will always be there on your cloudflare dashboard. <br />
Your cloudflare tunnel should be up and running. <br />
At this point, you should be able to see a green label in the cloudflare dashboard next your tunnel that says "Healthy". <br />


# Teleport Setup
### Download Teleport locally (the docker version is no good unless you enjoy not being able to run commands on the container)
Community Version One-Liner
```bash
curl https://cdn.teleport.dev/install.sh | bash -s 17.4.2
```
### Add the included teleport.yaml file to your /etc folder 
Ensure your make any changes necessary for your personal setup

### Creating Certificates with Certbot:
You will be prompted to add a TXT record to your domains DNS settings. <br />
Ensure you change the domain name in the command below to your domain.
```bash
sudo certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --email your-email@example.com \
  --server https://acme-v02.api.letsencrypt.org/directory \
  --agree-tos \
  -d teleport.domain.com \
  -d '*.teleport.domain.com'
```
Ensure that the path outputted by certbot for your certificates matches that of the paths under https_keypairs in the teleport.yaml file.

### Start Teleport!
```bash
sudo systemctl enable teleport
sudo systemctl start teleport
```

### Once downloaded Teleport successfully
Double check that you have tctl and tsh installed.
```bash
tsh version
tctl version
```
### Create admin.yaml file to define admin role and rules
Suggested path: ~/server/teleport/roles
```yaml
kind: role
version: v5
metadata:
  name: admin
spec:
  allow:
    logins: ['root', 'chris']
    node_labels:
      '*': '*'
    app_labels:
      '*': '*'
    rules:
      - resources: ['*']
        verbs: ['*']
```
### Apply the role and create the user
In the same directory where you created the admin.yaml file, run these commands.
```bash
sudo tctl create -f admin.yaml
sudo tctl users add your_name --roles=admin --logins=root,your_name
```
Follow the link and then create your credentials with your OTP device/app <br />
At this point you should be able to log in to your Teleport Web UI with your credentials at teleport.your-domain.com <br />

# Applications
### Dynamic adding of local applications using tctl
First create a yaml file for your application that is locally hosted
```yaml
kind: app
version: v3
metadata:
  name: app_name
  labels:
    env: admin_dev # Or any label you want (the admin role we added earlier has access to all labels)
spec:
  uri: http://127.0.0.1:8080
  public_addr: your-app.teleport.your-domain.org (This subdomain will need to be added via cloudflare SaaS mode)
```
Dynamically register this application with Teleport
```bash
sudo tctl create path/to/your_app_config.yaml
```
OR when updating an existing application
```bash
sudo tctl create -f path/to/your_app_config.yaml
```
At this point, you should see the application in your Teleport web ui, and if you have set the cloudflare public hostnames, it should be accessible!

### Bonus 
If you are doing this with an Ubuntu laptop like me. <br />
This should allow you to close the lid without going to sleep. <br />
```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
### Downsides to this setup:
Deleting files is damn near impossible if they are on the containers host file system, since there is no interactive shell in the distroless image. This is only a good setup if you want a very quick easy launch, but for more complex server setups, installing Teleport is the way to go. Documentation is also much more helpful for non-docker setups. 
