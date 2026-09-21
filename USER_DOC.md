# User Documentation

## What services are provided by the stack

The Inception stack runs three services, each in its own Docker container:

| Service | Role | Accessible from |
|---------|------|-----------------|
| **NGINX** | Web server and single entry point. Handles HTTPS and forwards PHP requests to WordPress. | Browser (port 443) |
| **WordPress + PHP-FPM** | The website and admin panel. | Through NGINX |
| **MariaDB** | The database storing all WordPress content. | Internal only |

You get a working WordPress site served over HTTPS, an admin panel to manage content, and a database that persists across restarts.

## How to start and stop the project

Run all commands from the root of the repository.

| Command | What it does |
|---------|--------------|
| `make` | Build and start everything |
| `make down` | Stop and remove containers (data is kept) |
| `make rebuild` | Restart the services |
| `make clean` | Remove containers, networks, volumes |
| `make fclean` | `clean` + remove images and build cache |
| `make re` | Full rebuild from scratch |

## How to access the website and admin panel

Add this line to `/etc/hosts` inside the VM:

```
127.0.0.1 gita.42.fr
```

Then open in a browser inside the VM:

```
https://gita.42.fr
```

The site uses a self-signed certificate, so accept the browser warning (**Advanced** → **Proceed**).

Admin panel:

```
https://gita.42.fr/wp-admin
```

Log in with the admin credentials (see next section).

## How to locate and manage credentials

Credentials live in `secrets/` at the root of the repository and are mounted into containers at `/run/secrets/`.

| File | Contains |
|------|----------|
| `secrets/mysql_root_pw.txt` | MariaDB root password |
| `secrets/mysql_pw.txt` | WordPress database password |
| `secrets/wp_admin_pw.txt` | WordPress admin password |
| `secrets/wp_user_pw.txt` | WordPress regular user password |

Non-sensitive config (domain, database name, usernames, emails) lives in `srcs/.env`.

To change a password: edit the file, then run `make re`. Changing the MariaDB password after initialization also requires wiping `/home/gita/data/mariadb/` or updating the password in the database.

## How to check that services are running correctly

```bash
# First, navigate to the `srcs/` directory
cd srcs/

# Container status — all three should be Up
docker compose ps

# MariaDB is accepting connections
docker exec -it mariadb mariadb -u root -p$(cat secrets/mysql_root_pw.txt) -e "SELECT 1;"

# WordPress is installed
docker exec -it wordpress wp --allow-root --path=/var/www/html core version

# Site is reachable
curl -k https://gita.42.fr
```
