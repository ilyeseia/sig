# Audit Report - SIG Project

## 1. Executive Summary
The audit of the SIG project reveals several critical security vulnerabilities, particularly in the handling of credentials and the separation of concerns between frontend and backend. The frontend code exposes internal infrastructure details and potentially administrative credentials. The backend contains a critical race condition in the security logic. Infrastructure configuration uses default passwords and exposes unnecessary ports.

## 2. Critical Security Issues
- **[CRITICAL] Credential Exposure in Frontend (`sig_frontend/constants.js`):** The file attempts to load database and GeoServer administrative credentials (`databasePassword`, `GeoServerPassword`) and structure a full database connection object. In a client-side application, these values could be exposed to end-users if injected during the build process.
- **[CRITICAL] Race Condition in Security Logic (`sig_backend/src/main/java/dz/eadn/sig/util/GeoServerRest.java`):** The `GeoServerRest` class is a Singleton (`@Component`) but uses a mutable instance variable `private boolean isPublic` to toggle authentication state. This creates a race condition where concurrent requests could inadvertently elevate privileges or deny access to legitimate users.
- **[HIGH] Hardcoded Secrets in Infrastructure (`docker-compose.yml`):** Default passwords (`Solution.2021!`, `mWeR8Tx7kW-U`) are hardcoded in the file. While environment variables are supported, the defaults are committed to version control.
- **[HIGH] Unnecessary Port Exposure (`docker-compose.yml`):** The PostgreSQL database port (`5432`) is exposed to the host machine, increasing the attack surface.
- **[MEDIUM] Insecure Node.js Options (`sig_frontend`):** The Dockerfile uses `NODE_OPTIONS=--openssl-legacy-provider`, indicating reliance on outdated cryptographic libraries or build tools.

## 3. Code Quality & Maintainability
- **[MAJOR] Frontend Bloat:** The frontend utilizes three different UI frameworks: Bootstrap, Ant Design Vue, and Buefy (Bulma), leading to unnecessary bundle size and inconsistent design.
- **[MAJOR] Dead Code (`sig_backend/src/main/java/dz/eadn/sig/config/BoostrapApp.java`):** The entire file is commented out but contains hardcoded credentials and logic. It should be removed or properly refactored and enabled.
- **[MEDIUM] Build Inefficiency (`sig_backend/Dockerfile`):** The Dockerfile copies `src` immediately after `build.gradle`, invalidating the dependency cache on every code change and significantly slowing down builds.
- **[MEDIUM] Java Version:** The backend executes on Java 8, which is end-of-life for active support. Upgrade to Java 17 or 21 is recommended.

## 4. Recommendations
1.  **Refactor GeoServer Logic:** Move all GeoServer configuration logic from the Frontend to the Backend. The Frontend should proxy requests through the Backend, which holds the credentials securely.
2.  **Fix Race Condition:** Refactor `GeoServerRest.java` to not use instance variables for request-specific state. Pass the `isPublic` flag as a method argument.
3.  **Secure Infrastructure:** Remove hardcoded passwords from `docker-compose.yml`, use `.env` files exclusively. Close port 5432 on the host.
4.  **Clean Up Frontend:** Consolidate UI frameworks and remove sensitive configuration blocks from client-side code.
5.  **Optimize Build:** Adjust `Dockerfile` to copy `build.gradle` and resolve dependencies before copying source code.
