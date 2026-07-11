*This project has been created as part of the 42 curriculum by ahouass.*

# Inception

## Description

Inception is a system administration project whose goal is to build a
small, self-contained web infrastructure entirely with Docker, orchestrated
with Docker Compose, instead of relying on a single monolithic server or
pre-packaged images. Each service runs in its own container, built from a
Dockerfile written from scratch rather than pulled ready-made from Docker
Hub, using the penultimate stable version of Debian (`bookworm`) as the
base image for all of them.

The stack is made of three containers that together serve a working
WordPress website over HTTPS:

- **NGINX** — the single entrypoint into the whole infrastructure,
  terminating TLSv1.2/TLSv1.3 connections on port 443 and forwarding PHP
  requests to WordPress over FastCGI. No other port is exposed to the
  host.
- **WordPress** (php-fpm only, no bundled web server) — runs the actual
  site, installed and configured automatically on first boot via WP-CLI,
  with an administrator account and a separate regular user account.
- **MariaDB** — the database backing WordPress, initialized and
  provisioned automatically on first boot.

Persistent data (the WordPress files and the MariaDB data directory) lives
in Docker-managed named volumes, so it survives container restarts and
image rebuilds. Every password is injected via Docker secrets rather than
hard-coded anywhere, and non-sensitive configuration (domain name,
database name, usernames) lives in a `.env` file that is safe to commit.

## Instructions

### Requirements

- A Virtual Machine (this project is meant to run on a VM, not bare metal
  or nested inside another container)
- Docker Engine and the Docker Compose plugin
- `make`

### Setup and execution

1. Point your domain at the machine running the stack. On whichever host
   you'll browse from, add to `/etc/hosts` (or the Windows equivalent,
   `C:\Windows\System32\drivers\etc\hosts`, if you're browsing from
   outside WSL):
   ```
   127.0.0.1   ahouass.42.fr
   ```
2. Replace the placeholder passwords in `secrets/*.txt` with real values —
   they ship as `ChangeMe_...` and must not be used as-is.
3. From the root of the repository:
   ```
   make
   ```
   This builds the three images and starts the stack in the background.
4. Visit `https://ahouass.42.fr`. See `USER_DOC.md` for day-to-day usage
   and `DEV_DOC.md` for a full command reference.

## Project description

### Use of Docker and project sources

All application logic that isn't WordPress/MariaDB/NGINX themselves lives
in three places per service, under `srcs/requirements/<service>/`:

- **`Dockerfile`** — builds the image from `debian:bookworm`, installing
  only the packages that service needs.
- **`conf/`** — static configuration (NGINX's server block, MariaDB's
  `bind-address` override, PHP-FPM's pool config).
- **`tools/setup.sh`** — the container's entrypoint script, responsible
  for any first-boot initialization (creating the database, installing
  WordPress, generating a TLS certificate) before handing off to the
  real foreground process (`mysqld`, `php-fpm`, `nginx`).

`srcs/docker-compose.yml` ties the three together on a single bridge
network, and the root `Makefile` wraps the handful of Compose commands
needed day to day (build, up, down, logs, clean).

### Design choices and comparisons

- **Virtual Machines vs Docker**: a VM virtualizes an entire machine —
  hardware, kernel, and OS — through a hypervisor, which makes it heavy to
  boot and to run, since every VM carries its own kernel and OS image.
  Docker containers share the host's kernel and only isolate the process,
  filesystem, and network at the OS level, so they start in milliseconds
  and use a fraction of the resources a VM would. The trade-off is a
  smaller isolation boundary: a hypervisor escape is harder to pull off
  than a container escape, so a VM protects against a wider range of
  attacks. This project runs its containers inside a VM specifically to
  get both: VM-level isolation from the outside world, and container-level
  efficiency for the services themselves.

- **Secrets vs Environment variables**: environment variables set through
  `.env`/`env_file` are visible to any process inside the container and
  can leak through `docker inspect`, logs, or a child process's own
  environment. Docker secrets are instead mounted as files under
  `/run/secrets/` only inside the containers that explicitly declare them,
  never become part of an image layer, and don't show up in `docker
  inspect`. This project uses `.env` only for genuinely non-sensitive
  configuration (domain name, database name, usernames, WordPress title)
  and Docker secrets for every password.

- **Docker Network vs Host network**: with the host network driver, a
  container shares the host's network namespace directly, so there's no
  isolation and port conflicts with the host become possible. A
  user-defined bridge network (used here, `inception`) gives every
  container its own network namespace and IP address, while Docker's
  embedded DNS still lets them reach each other by service name
  (`mariadb`, `wordpress`, `nginx`). Only the one port explicitly
  published — 443, on NGINX — is reachable from outside the stack, which
  is what makes NGINX a real single entrypoint rather than just a
  convention.

- **Docker Volumes vs Bind mounts**: named volumes are fully managed by
  Docker itself (created and stored under Docker's own data directory),
  which makes them portable across machines and avoids tying the setup to
  one specific host path or the permission quirks that come with it. Bind
  mounts instead map an exact host directory into the container — simple
  to inspect by hand, but coupled to that host's filesystem layout, and
  known to behave inconsistently on some Docker backends (notably Docker
  Desktop on WSL2). This project uses two Docker-managed named volumes,
  `wp_data` and `db_data`, declared in `docker-compose.yml` with no
  `driver_opts`.

## Resources

- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- Docker secrets documentation: https://docs.docker.com/engine/swarm/secrets/
- WP-CLI handbook: https://wp-cli.org/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- NGINX documentation: https://nginx.org/en/docs/

### AI usage

An AI assistant (Claude) was used throughout this project:

- **Scaffolding**: generating the initial Makefile, `docker-compose.yml`,
  the three Dockerfiles, and the NGINX/PHP-FPM/MariaDB configuration files.
- **Entrypoint scripts**: writing the `tools/setup.sh` script for each
  service (first-boot database/user creation, WordPress installation via
  WP-CLI, TLS certificate generation), including making the MariaDB and
  WordPress scripts idempotent across restarts after a real bug was found
  where a failed first boot could permanently skip database provisioning.
- **Debugging**: diagnosing build and runtime failures during actual
  testing on a WSL2/Docker Desktop VM — a `curl` SSL error from a missing
  `ca-certificates` package, a Docker Desktop/WSL2 bind-mount bug, and the
  MariaDB provisioning bug mentioned above — by reading `docker logs`
  output and container exec output shared during the session.
- **Documentation**: drafting this README, `USER_DOC.md`, and `DEV_DOC.md`.

All AI-generated configuration and scripts were reviewed against the
subject's requirements and tested on an actual VM before being considered
finished; passwords shipped in `secrets/` are placeholders and must be
replaced before real use.
