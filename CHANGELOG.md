# Changelog
All notable changes to this project will be documented in this file.

## [0.3.1] - 2025-12-11
### Changed
- Updated MariaDB to version 10.11
- Added the ability to set the timezone in Phorge with an environment variable
- Made it so that Phorge PDH actually can be started with supervisord

## [0.3.0] - 2025-12-05
### Changed
- Renamed the environment variables for better clarity
- Made the tag `latest` the default in the docker compose file.

### Added
- Added init database configuration that implements values phorge wants.


## [0.2.0] - 2025-12-05
### Changed
- Base image: switched from Debian-based image to `php:8.3-fpm-alpine` (Alpine Linux) to produce a smaller, Alpine-based runtime image.
- Package management: replaced `apt-get` installs with `apk` package installation and `apk del` for build deps; package names adjusted for Alpine (e.g., `mariadb-client`, `py3-pygments`, `openssh`, `tini`, `procps`, etc.).
- PHP runtime: upgraded to PHP 8.3 using the official `php:<version>-fpm` image and the `docker-php-ext-configure` / `docker-php-ext-install` helpers; installed and enabled APCu via PECL.
- Build flow: added an explicit `.build-deps` virtual package for build dependencies and removed it after building to reduce image size.
- Git backend and sources: updated repository clone URLs (now cloning `phorge` and `arcanist` from GitHub `phorgeit/*`) and added logic to create a `git-http-backend` symlink from possible locations.
- Default user: changed default `GIT_USER` environment variable to `root` (was previously `git`).
- Config paths: PHP/FPM configuration files use official image paths (`/usr/local/etc/php-fpm.d/`, `/usr/local/etc/php/`), and `php-fpm` invocation adjusted accordingly.
- Supervisord and services: adjusted `supervisord` config and service commands to match Alpine/official PHP image paths and to forward logs to stdout/stderr for container-friendly logging.
- SSH and ssh-key handling: added improved `configs/regenerate-ssh-keys.sh` with safety checks, logging, and empty-directory handling; SSH config handling kept but tuned for Alpine.
- Startup script changes: `scripts/startup.sh` adapted for Alpine tools (`addgroup`/`adduser -S`), creates runtime dirs (`/run/php`, `/run/sshd`, `/usr/libexec`), copies SSH hooks, and applies environment-driven Phorge configuration.
- Environment-driven configuration: startup now sets SMTP, MinIO/S3, MySQL, base URI and other Phorge settings from environment variables during container startup.
- Small fixes: ensured runtime directories ownership, added `tini` and supervisor package usage for process management, and removed Debian-specific artifacts/commands.

### Fixed
- Addressed package and path differences required by Alpine (library names, header locations for PHP extensions) and ensured build dependencies are cleaned up to keep the image small.
- Improved SSH host key generation to be idempotent and to fail early with clear errors when prerequisites are missing.

## [0.2.2] - 2025-12-11
### Fix
- Added missing LDAP PHP modules

## [0.2.1] - 2025-12-05
### Changed
- CI: GitHub Actions workflow now publishes Docker images both with the short SHA tag and the `latest` tag (so the newest image can be pulled with `:latest`).

## [0.1.3] - 2020-06-01
### Fix
- SSH port availability fix

## [0.1.2] - 2020-05-28
### Fix
- Spell fixes in Dockerfile

## [0.1.1] - 2020-03-30
### Added
- Exposed 22 port in docker image
- SSH port forwarding in docker-compose

## [0.1.0] - 2020-03-30
### Added
- Custom config for nginx
- Custom config for mysql
- Custom config for php-fpm
- Docker-compose for `amd64` arch
- Docker-compose for `arm` arch
- Common Dockerfile to build image
- `GitHub` actions configuration to build images


