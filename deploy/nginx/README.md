# nginx config for position.hilldave.com

`position.hilldave.com` in this directory is a verbatim copy of what runs on the
droplet at `/etc/nginx/sites-available/position.hilldave.com`.

It is kept here because two things in it exist **nowhere else**, and a droplet
rebuild would silently lose both:

1. **`location = /booked`** — serves `booked/index.html` at `/booked` with a real
   200. Without this block the default `try_files $uri $uri/` resolves `/booked`
   to the directory and nginx 301s to `/booked/`. The page would still load in a
   browser, so this breaks quietly rather than obviously.
2. **`add_header Cache-Control "no-cache"`** — without it nginx sends no
   `Cache-Control` on HTML at all and browsers apply heuristic caching. See the
   comment in the file for the incident this caused.

## Restoring after a droplet rebuild

```bash
scp -i ~/.ssh/hilldave_do \
  deploy/nginx/position.hilldave.com \
  root@192.34.59.130:/etc/nginx/sites-available/position.hilldave.com

ssh -i ~/.ssh/hilldave_do root@192.34.59.130 '
  ln -sf /etc/nginx/sites-available/position.hilldave.com \
         /etc/nginx/sites-enabled/position.hilldave.com
  nginx -t && systemctl reload nginx'
```

The `listen 443 ssl` / `ssl_certificate` lines are Certbot-managed and point at
`/etc/letsencrypt/live/position.hilldave.com/`. On a fresh droplet those paths
will not exist yet and `nginx -t` will fail until you re-run certbot. Either run
`certbot --nginx -d position.hilldave.com` first, or temporarily comment the SSL
lines out, bring nginx up on port 80, then let certbot rewrite them.

## Content served

| URL | File |
|---|---|
| `/` | `/var/www/position.hilldave.com/index.html` |
| `/booked` | `/var/www/position.hilldave.com/booked/index.html` |

Both are deployed from `agency-funnel/` in this repo. As of 2026-08-13 the repo
is downstream of production — pull live down before editing, so a deploy never
overwrites a change made directly on the server.

## Known rough edge

The static-asset block sets `expires 30d`, but the assets are **not**
content-hashed (`mark.png`, `mom.jpg`, …). Replacing an asset under its existing
name means returning visitors keep the old one for up to 30 days — the same
staleness class as the HTML bug above, just slower to notice. If assets start
changing regularly, either hash the filenames or drop that window.
