# Developer Documentation

## Setting up the environment from scratch

### Prerequisites

- A Linux virtual machine (the project must run inside a VM)
- Docker and the Docker Compose plugin
- `make`
- Domain resolution — add this line to `/etc/hosts`:
  ```
  127.0.0.1 gita.42.fr
  ```

### Configuration files

| File | Purpose |
|------|---------|
| `srcs/docker-compose.yml` | Declares the three services, network, volumes, and secrets |
| `srcs/.env` | Non-sensitive config (domain, database name, usernames, emails) |
| `srcs/requirements/mariadb/conf/configMaria` | MariaDB server config |
| `srcs/requirements/nginx/conf/nginx.conf` | NGINX server and FastCGI config |
| `srcs/requirements/wordpress/conf/www.conf` | PHP-FPM pool config |

### Secrets

Create the four secret files at the root of the repository:

```bash
mkdir -p secrets
touch secrets/mysql_root_pw.txt
touch secrets/mysql_pw.txt
touch secrets/wp_admin_pw.txt
touch secrets/wp_user_pw.txt
```
And save the passwords in those files.

These are mounted into containers at `/run/secrets/` and referenced by the entrypoint scripts.

## Building and launching the project

From the repository root:

```bash
make        # build images and start containers
make re     # full rebuild (fclean + up)
```

Under the hood, the Makefile runs:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

### Make targets

| Target | Description |
|--------|-------------|
| `make` / `up` | Build and start everything |
| `down` | Stop and remove containers |
| `rebuild` | Restart the containers |
| `clean` | Remove containers, networks, volumes |
| `fclean` | `clean` + remove images and build cache |
| `re` | Full rebuild (`fclean` + `up`) |

## Managing containers and volumes

```bash
# Show running containers
docker ps

# Enter a container
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh

# Inspect a network
docker network inspect inception_network

# List volumes
docker volume ls

# Inspect a volume and its mountpoint
docker volume inspect mariadb_data
docker volume inspect wordpress_files

# View logs of a specific service
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

## Where data is stored and how it persists

Docker named volumes are configured with a `local` driver and bind-mounted to the host filesystem:

| Volume | Container path | Host path |
|--------|---------------|-----------|
| `mariadb_data` | `/var/lib/mysql` | `/home/gita/data/mariadb/` |
| `wordpress_files` | `/var/www/html` | `/home/gita/data/wordpress/` |

Because the volumes are bind-mounted to `/home/gita/data/`, the data survives:

- Container restarts (`docker compose restart`)
- Container removal (`make down`)
- Image rebuilds (`make re`)

Only deleting `/home/gita/data/` or running `make clean`/`make fclean` will remove the data.

### Permissions

| Directory | Owner (UID) | Why |
|-----------|-------------|-----|
| `/home/gita/data/mariadb/` | `100:100` (`mysql`) | MariaDB runs as `mysql` inside the container |
| `/home/gita/data/wordpress/` | `82:82` (`www-data`) | PHP-FPM runs as `www-data` inside the container |

If permissions get reset, fix them with:

```bash
sudo chown -R 100:100 /home/gita/data/mariadb
sudo chown -R 82:82   /home/gita/data/wordpress
```