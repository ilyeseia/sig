# verify-audit.ps1
Write-Host "Starting Sig System Audit Verification..." -ForegroundColor Cyan

# 1. Check Docker Version
docker --version
if ($?) { Write-Host "Docker is present." -ForegroundColor Green }
else { Write-Error "Docker is not found. Please install Docker Desktop."; exit 1 }

# 2. Build Backend
Write-Host "`nBuilding Backend (Spring Boot 2.7)..." -ForegroundColor Yellow
docker-compose build backend
if ($?) { Write-Host "Backend build successful." -ForegroundColor Green }
else { Write-Error "Backend build failed."; exit 1 }

# 3. Build Frontend
Write-Host "`nBuilding Frontend (Nuxt 2 + Node 18)..." -ForegroundColor Yellow
docker-compose build frontend
if ($?) { Write-Host "Frontend build successful." -ForegroundColor Green }
else { Write-Error "Frontend build failed."; exit 1 }

Write-Host "`nAll builds passed successfully!" -ForegroundColor Green
Write-Host "You can now run 'docker-compose up -d' to start the system." -ForegroundColor Cyan
