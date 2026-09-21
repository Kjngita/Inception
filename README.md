*This project has been created as part of the 42 curriculum by gita.*

# Inception

## Description

**Inception** is a system administration project from the 42 curriculum. Its goal is to build a complete web infrastructure using **Docker**, without relying on pre-made images — every service is built from a custom `Dockerfile` and orchestrated with `docker-compose`.

The stack is composed of three services, each in its own container:

- **NGINX** — the single entry point, serving over **HTTPS only** (port 443, TLSv1.2/TLSv1.3).
- **WordPress + PHP-FPM** — the application itself.
- **MariaDB** — the database.

All services run on **Alpine Linux**, communicate over a **custom Docker network**, use **Docker secrets** for credentials, and persist data in **named volumes bind-mounted to `/home/gita/data/`**.

### Project structure

```
inception/
├── Makefile
├── secrets/                 # Passwords (excluded from Git)
└── srcs/
    ├── docker-compose.yml
    ├── .env                 # Non-sensitive config
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

### Main design choices

- **One service per container** — clear separation of concerns.
- **Custom Dockerfiles only** — no images pulled from Docker Hub besides Alpine.
- **Alpine 3.23** — small and fast.
- **Docker secrets** — no passwords in Dockerfiles, compose, or `.env`.
- **Named volumes + bind driver** — data stored at `/home/gita/data/`, managed by Docker.
- **NGINX is the only entrypoint** — MariaDB and WordPress are internal-only.

### Virtual Machines vs Docker

| Aspect | VM | Docker |
|--------|----|--------|
| Isolation | Full OS, own kernel | Process-level, shares host kernel |
| Size | GB | MB |
| Startup | Minutes | Seconds |
| Use case | Full OS isolation | Microservices, CI/CD |

### Secrets vs Environment Variables

| Aspect | Env Vars (`.env`) | Docker Secrets |
|--------|-------------------|----------------|
| Storage | Plain text | Mounted files in `/run/secrets/` |
| Visibility | Visible via `docker inspect` | Only inside the container |
| Best for | Non-sensitive config | Passwords, API keys |

### Docker Network vs Host Network

| Aspect | Bridge (Docker) | Host |
|--------|----------------|------|
| Isolation | Containers isolated | Shares host stack |
| DNS | Service names resolve | None |
| Security | Only exposed ports reachable | Everything exposed |
| In Inception | ✅ Used | ❌ Not allowed |

### Docker Volumes vs Bind Mounts

| Aspect | Volume | Bind Mount |
|--------|--------|-----------|
| Managed by | Docker | Host filesystem |
| Location | `/var/lib/docker/volumes/` | Anywhere on host |
| In Inception | Named volume with `driver_opts` bound to `/home/gita/data/` | Hybrid approach |

## Instructions

### Prerequisites

- Linux VM with Docker, Docker Compose, and `make`
- Domain resolution — add to `/etc/hosts`:

```
127.0.0.1 gita.42.fr
```

### Secrets

From the repository root:
```bash
mkdir -p secrets
touch secrets/mysql_root_pw.txt
touch secrets/mysql_pw.txt
touch secrets/wp_admin_pw.txt
touch secrets/wp_user_pw.txt
```
And put in those files whatever your heart desires for the passwords.

### Run

From the repository root:

```bash
make
```

Then open in the VM's browser:

```
https://gita.42.fr
```

Accept the self-signed certificate warning. Admin panel: `https://gita.42.fr/wp-admin`.

### Make targets

| Target | Description |
|--------|-------------|
| `make` / `up` | Build and start everything |
| `down` | Stop and remove containers |
| `rebuild` | Restart the containers |
| `clean` | Remove containers, networks, volumes |
| `fclean` | `clean` + remove images and build cache |
| `re` | Full rebuild (`fclean` + `up`) |

## Resources

### References

- [Docker Docs](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Alpine Linux](https://docs.alpinelinux.org/)
- [NGINX Docs](https://nginx.org/en/docs/)
- [WordPress Docs](https://wordpress.org/documentation/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Docs](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM Manual](https://www.php.net/manual/en/install.fpm.php)

### AI usage

AI was used for:

- **Learning Docker concepts** — images, containers, volumes, networks.
- **Debugging** — permission errors on bind mounts, IPv6-only PHP-FPM binds, stale `wp-config.php`, 502 errors from port mismatches.
- **Writing shell scripts** — structure of `scriptMaria.sh` and `scriptWP.sh`.
- **Drafting configs** — `nginx.conf`, `www.conf`, `configMaria`.
- **Documentation** — structuring this README, USER_DOC and DEV_DOC.

All AI output was reviewed, tested, and adapted to the Inception subject constraints.

## Technical choices

- **Alpine 3.23** for all images — minimal and fast.
- **No `latest` tags** — explicit versions only.
- **Secrets over env vars** — all credentials in `secrets/`.
- **Named volumes with bind driver** — data persists in `/home/gita/data/`.
- **Only NGINX exposes ports** — 443 (HTTPS) and 80 (rejected with 403).
- **Self-signed TLS cert** generated at build time via OpenSSL (TLSv1.2/TLSv1.3).