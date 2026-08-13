server {
    server_name position.hilldave.com;

    root /var/www/position.hilldave.com;
    index index.html;

    # HTML must revalidate on every request.
    # Without this nginx sends no Cache-Control at all, so browsers fall back to
    # heuristic caching and can serve a stale page for hours. That is what made a
    # correctly-deployed pixel patch look broken on 2026-08-13: repeat visits ran a
    # cached pre-patch copy (33,343 bytes) while the server had 40,141.
    # "no-cache" still caches, but forces an If-None-Match revalidation, so
    # unchanged pages come back as a cheap 304 rather than a full re-download.
    # The static-asset block below defines its own Cache-Control, which means it
    # does NOT inherit this one (nginx add_header inheritance is all-or-nothing).
    add_header Cache-Control "no-cache" always;

    # Serve /booked (no trailing slash) directly, without a 301 to /booked/.
    location = /booked {
        try_files /booked/index.html =404;
    }

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(mp4|jpg|jpeg|png|svg|webp)$ {
        expires 30d;
        add_header Cache-Control "public";
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/position.hilldave.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/position.hilldave.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = position.hilldave.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name position.hilldave.com;
    return 404; # managed by Certbot


}