# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-01-23

### Security
- **CRITICAL**: Fixed a race condition in `GeoServerRest.java` that allowed potential privilege escalation between public and secured WMS requests.
- **CRITICAL**: Removed hardcoded default passwords from `docker-compose.yml`.
- **CRITICAL**: Removed client-side exposure of database credentials (defaults) in `constants.js`.
- **CRITICAL**: Removed exposure of PostGIS port 5432 to the host network.
- Corrected internal hardcoded IP addresses in frontend constants.

### Changed
- Refactored `GeoServerRest.java` to use stateless authentication methods.
- Updated `docker-compose.yml` to strictly enforce environment variable usage for secrets.
- Optimized `sig_backend/Dockerfile` to cache Gradle dependencies, speeding up rebuilds.
- Updated documentation (`README.md`) to reflect security hardening.

### Removed
- Deleted dead code `BoostrapApp.java` (backend) which contained hardcoded legacy credentials.
- Removed legacy `isPublic` state management in favor of request-scoped argument passing.
