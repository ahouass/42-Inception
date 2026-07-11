# User Documentation

This document explains how to use the Inception stack day to day, once it
has already been set up by a developer/administrator (see `DEV_DOC.md` for
the initial setup itself).

## What services does this stack provide?

- **A WordPress website**, reachable at `https://ahouass.42.fr`.
- **A WordPress admin panel**, reachable at `https://ahouass.42.fr/wp-admin`.
- **A MariaDB database**, used internally by WordPress to store all site
  content (posts, pages, users, settings). It is not exposed outside the
  Docker network, so it can't be reached directly from your browser or
  from outside the stack.
- **NGINX**, which is the single door into the whole stack: it's the only
  container that listens on a port reachable from outside (443, over TLS),
  and it forwards requests to WordPress internally.

## Starting and stopping the project

Run these from the root of the repository, where the `Makefile` lives:

| I want to...                        | Command       |
|--------------------------------------|---------------|
| Start everything                     | `make`        |
| Stop everything (data is kept)       | `make down`   |
| Pause containers without removing    | `make stop`   |
| Resume paused containers              | `make start`  |
| Watch what's happening (live logs)    | `make logs`   |
| Wipe everything, including all data  | `make fclean` |

## Accessing the website and the administration panel

1. Make sure `ahouass.42.fr` resolves to the machine running the stack —
   add it to `/etc/hosts` if you're testing locally, or configure real DNS
   if the VM is reachable over a network.
2. Open `https://ahouass.42.fr` in a browser to see the site itself.
3. Because the TLS certificate is self-signed (generated locally, not
   issued by a public certificate authority), your browser will show a
   security warning the first time you visit — this is expected for a
   local/school project. Accept the exception to continue.
4. To manage the site — write posts, install themes, change settings — go
   to `https://ahouass.42.fr/wp-admin` and log in with the administrator
   account (its username is set in `srcs/.env` under
   `WORDPRESS_ADMIN_USER`; its password is in
   `secrets/wp_admin_password.txt`).
5. A second, non-administrator account also exists (`WORDPRESS_USER` in
   `.env`, password in `secrets/wp_user_password.txt`) for day-to-day
   authoring without full admin rights.

## Locating and managing credentials

Every password lives under `secrets/` at the root of the repository, and
is never stored in `.env` or committed to Git:

| File                              | Contains                                  |
|-------------------------------------|----------------------------------------------|
| `secrets/db_root_password.txt`      | MariaDB `root` password                       |
| `secrets/db_password.txt`           | Password for the WordPress database user      |
| `secrets/wp_admin_password.txt`     | WordPress administrator account password      |
| `secrets/wp_user_password.txt`      | WordPress secondary (author) account password |

Non-sensitive settings — domain name, database name, usernames, WordPress
title — live in `srcs/.env` and can be reviewed there directly.

To change a password: stop the stack (`make down`), edit the relevant file
under `secrets/`, then rebuild from scratch (`make re`) so the new value is
picked up during initialization. Changing a password after WordPress or
MariaDB has already been initialized once will not automatically update it
inside the running database/site — the entrypoint scripts only set initial
passwords, they don't rotate ones that are already in place. If you need
to change a password without wiping existing site data, do it directly
inside WordPress (Users → your profile) or MariaDB (`ALTER USER ...`)
instead of just editing the secret file.

## Checking that the services are running correctly

- `make ps` (or `docker ps`) should show three containers — `nginx`,
  `wordpress`, `mariadb` — all with a status of `Up`, not `Restarting`.
- `make logs` streams the logs of all three services at once; look near
  the bottom for errors if something looks wrong.
- Visiting `https://ahouass.42.fr` should show the WordPress homepage. A
  connection error usually means the `nginx` container isn't running, or
  port 443 isn't actually reachable from where you're browsing.
- If the homepage loads but looks broken (missing styles, a PHP/database
  error), that's almost always a `wordpress` ↔ `mariadb` connectivity
  issue — check `docker logs wordpress` and `docker logs mariadb`, in
  that order, since WordPress waits on MariaDB at startup.
