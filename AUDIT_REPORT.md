# Audit Report - SIG Project (Round 2)

## 1. Executive Summary
Following the initial remediation of critical infrastructure and code issues, a secondary deep-dive audit was conducted. This phase focused on internal configuration files embedded within the backend application. Critical findings include hardcoded credentials in `properties` files that are packaged into the application JAR, posing a significant risk if the artifact is leaked or decompiled.

## 2. Critical Security Issues
- **[CRITICAL] Hardcoded Secrets in `global.properties`:**
  - `redis.password` is hardcoded as `Solution.2021!`.
  - `geoserver.rest.password` is present in cleartext (`Solution.2021!`) essentially overriding the encrypted version on line 38.
  - `jasypt.encryptor.password` is hardcoded as `secret-@-sercret`.
- **[HIGH] Insecure Default Values in `application-docker.properties`:**
  - While environment variables are used, they fall back to insecure defaults (e.g., `${SPRING_DATASOURCE_PASSWORD:Solution.2021!}`). This encourages potential usage of insecure defaults in production if variables are missing.
- **[HIGH] Secrets in `application.properties`:**
  - The default profile contains hardcoded database credentials (`Solution.2021!`).

## 3. Code Quality & Maintainability
- **[MEDIUM] Redundant Configuration:** `global.properties` contains duplicate keys for `geoserver.rest.password`.
- **[LOW] Logging Noise:** `spring.jpa.show-sql=true` is enabled in production-like configurations, which can fill logs with sensitive query data/performance drain.

## 4. Recommendations
1.  **Sanitize Properties Files:** Remove all cleartext passwords. Replace them with strict environment variable references without default values (or with empty/fail-fast defaults).
2.  **Externalize Jasypt Secret:** The encryption password itself should be injected via environment variable, not hardcoded.
3.  **Disable SQL Logging:** Turn off `show-sql` in production profiles.
