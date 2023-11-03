<a name="readme-top"></a>
<br />
<!--ts-->
* [Prerequisites](#prerequisites)
* [Development](#development)
  * [Running dev environment locally](#running-dev-environment-locally)
* [letsencrypt certbot usage](#letsencrypt-certbot-usage)
  * [ask for a new letsencrypt certificate:](#ask-for-a-new-letsencrypt-certificate)
  * [SSL dhparam generation](#ssl-dhparam-generation)
  * [Final TLS setup](#final-tls-setup)
* [Production setup](#production-setup)
* [Miscellaneous, references](#miscellaneous-references)
<!--te-->

# Prerequisites

* [docker] with [docker-compose]
* working AWS ECR access]
* working Gitlab Container registry access

# Development

[dev-setup/](dev-setup/) directory contains development setup.

## Running dev environment locally

use [docker-compose]:

```
cd dev-setup/
docker compose up
```

# letsencrypt certbot usage

## ask for a new letsencrypt certificate:

Assume that you're going to ask for a primary domain `dev.example.org` with
an optional alias `www.dev.example.org`:

* check that everything is working with `--dry-run` test:
```
./certbot.sh certonly -n -d dev.example.org,www.dev.example.org --dry-run
```

* ask for a certificate
```
./certbot.sh certonly -n -d dev.example.org,www.dev.example.org
```

This results in the following new files being generated:
```
conf/live/dev.example.org/cert.pem
conf/live/dev.example.org/chain.pem
conf/live/dev.example.org/fullchain.pem
conf/live/dev.example.org/privkey.pem
```

These files are now accessible in nginx frontend as `/etc/letsencrypt/live/dev.example.org` folder

Expand details **for full certbot commands**.
<details>

* check that everything is working with `--dry-run` test:
```
docker compose run certbot certonly \
  --agree-tos \
  --email info@example.org \
  --webroot \
  -w /var/www/certbot   \
  -n \
  --dry-run \
  -d dev.example.org,www.dev.example.org
```

* ask for a certificate
```
docker compose run certbot certonly \
  --agree-tos \
  --email info@example.org \
  --webroot \
  -w /var/www/certbot   \
  -n \
  -d dev.example.org,www.dev.example.org

[+] Building 0.0s (0/0)                                                                                                                                                                                                      docker:default
[+] Building 0.0s (0/0)                                                                                                                                                                                                      docker:default
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Account registered.
Requesting a certificate for dev.example.org and www.dev.example.org

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/dev.example.org/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/dev.example.org/privkey.pem
This certificate expires on 2024-01-28.
These files will be updated when the certificate renews.
```

This results in the following new files being generated:
```
conf/live/dev.example.org/cert.pem
conf/live/dev.example.org/chain.pem
conf/live/dev.example.org/fullchain.pem
conf/live/dev.example.org/privkey.pem
```

These files are now accessible in nginx frontend as `/etc/letsencrypt/live/dev.example.org` folder

</details>

## SSL dhparam generation

For each new site that has its own certificate and implements [https] we should also generate `dhparam` file

**simplified command**:
```
./certbot-dhparam.sh dev.example.org
```

Expand details **for full certbot commands**.
<details>

```
docker compose run --entrypoint= certbot \
  openssl \
  dhparam \
  -out /etc/letsencrypt/live/dev.example.org/dhparam.pem \
  2048
```

</details>

## Final TLS setup

The steps above allow us to come up with a final TLS enabled site server configuration:

```nginx
server {
  include       "extra/listening-port-https.conf";
  server_name   dev.example.org www.dev.example.org
                dev.example.lan.local www.dev.example.lan.local;

  ##################################################
  # SSL/TLS
  include                   "extra/tls-common.conf";
  ssl_certificate           "/etc/letsencrypt/live/dev.example.org/fullchain.pem";
  ssl_certificate_key       "/etc/letsencrypt/live/dev.example.org/privkey.pem";
  ssl_trusted_certificate   "/etc/letsencrypt/live/dev.example.org/chain.pem";
  ssl_dhparam               "/etc/letsencrypt/live/dev.example.org/dhparam.pem";

  # ocsp stapling
  include             "extra/tls-ocsp-stapling.conf";
  # hsts
  include             "extra/tls-hsts.conf";
  ##################################################
```

# Production setup

TODO

# Miscellaneous, references

* [mkcert] :: tool for easy creation of trusted development certificates
* [mkcert usage example](./dev-setup/data/frontend/nginx/tls/)

[docker]: https://docker.com
[docker-compose]: https://docs.docker.com/compose/
[mkcert]: https://github.com/FiloSottile/mkcert
[letsencrypt]: https://letsencrypt.org/
[https]: https://en.wikipedia.org/wiki/HTTPS
[mkcert]: https://github.com/FiloSottile/mkcert
