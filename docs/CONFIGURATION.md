# Configuration Guide

This document covers how to configure the Kasm Workspaces instance running within Pterodactyl.

## Environment Variables

These variables can be adjusted in the Pterodactyl Panel under the **Startup** tab for the server:

- `SERVER_PORT`: The allocation port Pterodactyl assigns to your node. The container naturally proxies this to Kasm's internal 443 port natively, meaning Kasm will seamlessly run regardless of the random port you assign it.
- `PUBLIC_HOSTNAME`: The external IP or Domain name used to access Kasm.
- `ADMIN_PASS`: (Auto-generated) The read-only startup variable that overrides the password for the `admin@kasm.local` user dynamically on boot.
- `USER_PASS`: (Auto-generated) The read-only startup variable that overrides the password for the `user@kasm.local` user dynamically on boot.

## Reverse Proxy / SSL

By default, Kasm generates its own self-signed certificates. If you are putting Kasm behind a reverse proxy (like NGINX or Cloudflare Tunnels), you will need to configure Kasm to be aware of the proxy, or handle SSL termination at the proxy.

### NGINX Reverse Proxy Example

If you want to proxy `kasm.yourdomain.com` to your Pterodactyl container running on port `8443`:

```nginx
server {
    listen 80;
    server_name kasm.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name kasm.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/kasm.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/kasm.yourdomain.com/privkey.pem;

    location / {
        proxy_pass https://<PTERODACTYL_NODE_IP>:8443;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Required for WebSockets
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```
