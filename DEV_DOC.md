# Developer Documentation

## Setting up the environment from scratch

### Prerequisites

- A Virtual Machine running a Linux distribution (the subject requires
  this project to run on a VM, not bare metal or nested inside another
  container).
- Docker Engine and the Docker Compose plugin installed on that VM.
- `make`.

### Configuration files

| Path                                  | Purpose                                                       |
|-----------------------------------------|-------------------------------------------------------------------|
| `Makefile`                              | Entry point: build/start/stop/clean the whole stack               |
| `srcs/docker-compose.yml`               | Defines the three services, network, volumes, and secrets         |
| `srcs/.env`                             | Non-sensitive configuration (domain, DB name, usernames, ...)     |
| `secrets/*.txt`                         | Passwords, consumed as Docker secrets — never commit real ones    |
| `srcs/requirements/*/Dockerfile`        | One custom Dockerfile per service, built from `debian:bookworm`   |
| `srcs/requirements/*/conf/`             | Service-specific static configuration                             |
| `srcs/requirements/*/tools/setup.sh`    | Entrypoint script: first-boot init, then execs the real process   |

Before running anything:

1. Replace the placeholder values in `secrets/*.txt` with real passwords.
2. Review `srcs/.env` and adjust the domain, database name, and WordPress
   usernames/title to match your setup.
3. Confirm the domain in `.env` resolves to this machine from wherever
   you'll browse (see `USER_DOC.md`).

## Building and launching the project

```sh
make          # build the images (if needed) and start the stack
```

Under the hood, `make` (equivalent to `make up`) runs:

```sh
docker-compose -f srcs/docker-compose.yml up -d
```

which builds the `mariadb`, `wordpress`, and `nginx` images from their
respective Dockerfiles if they don't already exist, then starts all three
containers in the background, attached to the `inception` bridge network.

Other Makefile targets:

| Target        | Effect                                                          |
|----------------|----------------------------------------------------------------|
| `make build`   | Build the images without starting containers                    |
| `make up`      | Start the stack (building first if needed)                      |
| `make down`    | Stop and remove the containers (volumes are kept)                |
| `make stop`    | Stop containers without removing them                            |
| `make start`   | Resume previously stopped containers                             |
| `make logs`    | Follow logs from all three services                              |
| `make ps`      | Show container status                                            |
| `make clean`   | `down` + prune unused images (volumes/data kept)                  |
| `make fclean`  | `down` + prune unused images **and volumes** (wipes all data)     |
| `make re`      | `fclean` + `up` — a full rebuild from zero                       |

## Managing containers and volumes

- `docker ps` / `make ps` — list running containers and their status.
- `docker logs <container>` or `make logs` (all three at once) — inspect
  service output; useful for confirming MariaDB finished initializing,
  WordPress connected and installed, or NGINX started correctly.
- `docker exec -it <container> bash` — get a shell inside a running
  container, e.g. to inspect `wp-config.php`, check PHP-FPM's status, or
  run `mysql` manually inside `mariadb`.
- `docker volume ls` — lists the two named volumes this project declares,
  `wp_data` and `db_data` (prefixed with the Compose project name, e.g.
  `srcs_wp_data`).
- `docker volume inspect <volume>` — shows the actual path on the host
  where Docker stores a given volume's data, if you need to look at the
  raw files directly.
- `docker network inspect inception` (prefixed similarly, e.g.
  `srcs_inception`) — confirms all three containers are attached to the
  same bridge network and can resolve each other by service name.

## Where project data is stored and how it persists

- WordPress files (core, themes, plugins, uploads, `wp-config.php`) live
  in the `wordpress` container at `/var/www/html`, backed by the
  Docker-managed named volume `wp_data`. The same volume is also mounted
  read-through in `nginx`, since NGINX needs direct filesystem access to
  serve static assets and to resolve PHP script paths for `wordpress` to
  execute.
- The MariaDB data directory lives in the `mariadb` container at
  `/var/lib/mysql`, backed by the Docker-managed named volume `db_data`.

Both volumes are declared under the top-level `volumes:` key in
`srcs/docker-compose.yml` with no `driver_opts` — they are plain
Docker-managed volumes, not bind mounts to a specific host path. Because
of that, the data survives `docker-compose down`, container restarts, and
`docker-compose build --no-cache`; it is only removed by an explicit
`docker volume rm`, or by `make fclean` (which runs `docker system prune
-af --volumes`).

### Notes on the entrypoint scripts

Each service's `tools/setup.sh` follows the same overall pattern: check
whether first-boot initialization is needed, perform it if so (or, for
MariaDB/WordPress, re-run the idempotent parts of it safely even on a
restart), then `exec` the real foreground process so it becomes PID 1 and
`docker stop` behaves correctly:

- **mariadb**: runs `mariadb-install-db` only if `/var/lib/mysql/mysql`
  doesn't exist yet, then always (re)creates the `wordpress` database and
  `wp_user` account via `CREATE ... IF NOT EXISTS`, and only changes the
  root password if it isn't already set to the configured value — this
  makes it safe to restart the container at any point without leaving the
  database half-configured.
- **wordpress**: waits until MariaDB is actually queryable, then uses
  `wp core is-installed` to decide whether to run the full install
  (download core, write `wp-config.php`, `wp core install`, create the
  second user) or skip straight to starting `php-fpm`.
- **nginx**: generates a self-signed TLS certificate on first boot if one
  doesn't already exist in the image, substitutes `_PLACEHOLDER` tokens in
  `nginx.conf` with real values from `.env` using `sed`, then starts
  `nginx` in the foreground.
