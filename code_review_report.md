# Code Review Report

## 1. Hardcoded Secrets (Critical)
**Files:**
- `sig_backend/src/main/resources/global.properties`
- `sig_frontend/constants.js.old` (and likely bundled in `store/index.js`)

**Issue:**
Sensitive credentials (passwords, secret keys) are hardcoded in the source code.
- `global.properties`: Contains cleartext passwords for Redis (`Solution.2021!`), GeoServer, and Jasypt encryption (`secret-@-sercret`). The Jasypt password compromises all `ENC(...)` values.
- `constants.js.old`: Contains administrative passwords for GeoServer and Database (`Solution.2021!`). These are imported by the frontend store and likely bundled, exposing them to any user who inspects the client-side code.

**Fixes:**
1. **Environment Variables**: Move all secrets to environment variables. In Spring Boot, use `${ENV_VAR}` placeholders in `application.properties/global.properties`.
2. **Secrets Management**: Use a secret manager (Vault, AWS Secrets Manager, or Kubernetes Secrets) if deploying in a containerized environment.
3. **Frontend Security**: Never embed backend secrets (DB/admin passwords) in frontend code. If the frontend needs to proxy requests, do it through a backend API that holds the potential credentials securely.

## 2. Path Traversal & Arbitrary File Deletion (Critical)
**Files:**
- `sig_backend/src/main/java/dz/eadn/sig/api/v1/UploadFileController.java`
- `sig_backend/src/main/java/dz/eadn/sig/service/impl/UploadFileServiceImpl.java`

**Issue:**
The application allows user-controlled input to dictate where files are read from or deleted.
- `UploadFileController.java`: `folderName` is taken from the URL and used to construct paths. The sanitization `folderName.replace(".", "/")` is insufficient and may actually facilitate traversal or be bypassed.
- `UploadFileServiceImpl.java`: `deleteFolder` and `deleteDirectory` recursively delete files in a directory specified by the user. If a user can manipulate `folderName` to point to a system directory (e.g. via `..` sequences not caught by the replacement), they can delete critical system files.
- `loadFile` accepts `fileName` and `folderName`, allowing arbitrary file reads if traversal characters are successfully passed.

**Fixes:**
1. **Strict Validation**: Whitelist allowed folder names or use an enum/ID system mapping to paths.
2. **Path Sanitization**: Use `java.nio.file.Path.normalize()` and check that the resolved path starts with the intended base directory. Reject any path that escapes the base.
3. **Indirect References**: Do not expose filesystem structures to the API. Use UUIDs or database IDs to reference files/folders.

## 3. Password Hash Leak (Critical)
**Files:**
- `sig_backend/src/main/java/dz/eadn/sig/model/User.java`
- `sig_backend/src/main/java/dz/eadn/sig/api/v1/UserController.java` (and `CommonController`)

**Issue:**
The `User` entity contains a `private String password` field without `@JsonIgnore`.
- APIs such as `GET /api/v1.0/users/{uuid}` (implemented via `CommonController.find`) are documented to return the `User` entity.
- When serialized to JSON, the `password` field (containing the hash) will be included in the response, allowing attackers to attempt offline cracking.

**Fixes:**
1. **@JsonIgnore**: Add `@JsonIgnore` annotation to the `password` field in the `User` entity.
2. **DTO Projection**: Ensure ALL controllers return `UserDto` or a specific projection that excludes sensitive fields, never the raw Entity.
3. **Audit**: Review `CommonController` to ensure it doesn't default to returning raw entities for sensitive types.

## 4. Denial of Service via Memory Exhaustion (High)
**Files:**
- `sig_backend/src/main/java/dz/eadn/sig/service/impl/UploadFileServiceImpl.java` (Lines 220, 225)

**Issue:**
The method `loadFile` uses `Files.readAllBytes(path)` to read a requested file.
- If a user requests a very large file (or a file from `/dev/zero` if traversal is possible), `readAllBytes` will attempt to load the entire content into JVM memory, leading to an `OutOfMemoryError` and crashing the application (DoS).

**Fixes:**
1. **Streaming**: Return an `InputStreamResource` or stream bytes directly to the response output stream instead of loading a byte array.
2. **Range Requests**: Implement support for HTTP byte range requests for large media files.
3. **Size Limits**: Enforce strict file size limits during upload to prevent large files from existing in the system.
