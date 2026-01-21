# Script PowerShell - Test et Validation Docker
# Exécution: .\test-docker.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test de Configuration Docker - SIG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier Docker
Write-Host "[1/6] Test: Docker installé..." -ForegroundColor Yellow
try {
    $version = docker --version
    Write-Host "  ✓ PASS: $version" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ FAIL: Docker non installé" -ForegroundColor Red
    exit 1
}

# Test 2: Vérifier Docker Engine
Write-Host "[2/6] Test: Docker Engine actif..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ PASS: Docker Engine fonctionne" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ FAIL: Docker Engine non démarré" -ForegroundColor Red
    Write-Host "  → Action: Démarrer Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Test 3: Vérifier les fichiers essentiels
Write-Host "[3/6] Test: Fichiers de configuration..." -ForegroundColor Yellow
$files = @(
    "docker-compose.yml",
    ".env",
    "sig_backend\Dockerfile",
    "sig_frontend\Dockerfile",
    "sig_frontend\package.json",
    "sig_backend\src\main\resources\application-docker.properties"
)

$allFilesExist = $true
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ $file MANQUANT" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "  ✗ FAIL: Fichiers manquants" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ PASS: Tous les fichiers présents" -ForegroundColor Green

# Test 4: Vérifier docker-compose.yml
Write-Host "[4/6] Test: Validation docker-compose.yml..." -ForegroundColor Yellow
try {
    docker-compose config | Out-Null
    Write-Host "  ✓ PASS: docker-compose.yml valide" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ FAIL: docker-compose.yml invalide" -ForegroundColor Red
    exit 1
}

# Test 5: Vérifier les ports disponibles
Write-Host "[5/6] Test: Ports disponibles..." -ForegroundColor Yellow
$ports = @(80, 8080, 5432)
$portsOk = $true

foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  ✗ Port $port déjà utilisé" -ForegroundColor Red
        $portsOk = $false
    }
    else {
        Write-Host "  ✓ Port $port disponible" -ForegroundColor Green
    }
}

if (-not $portsOk) {
    Write-Host "  ⚠ WARNING: Certains ports sont occupés" -ForegroundColor Yellow
    Write-Host "  → Les services Docker seront indisponibles sur ces ports" -ForegroundColor Yellow
}
else {
    Write-Host "  ✓ PASS: Tous les ports disponibles" -ForegroundColor Green
}

# Test 6: Vérifier l'espace disque
Write-Host "[6/6] Test: Espace disque..." -ForegroundColor Yellow
$drive = Get-PSDrive C
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)

if ($freeSpaceGB -gt 10) {
    Write-Host "  ✓ PASS: $freeSpaceGB GB disponibles" -ForegroundColor Green
}
else {
    Write-Host "  ⚠ WARNING: Seulement $freeSpaceGB GB disponibles" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Tests terminés avec succès!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Prêt pour le déploiement!" -ForegroundColor Cyan
Write-Host "Exécutez: .\deploy-docker.ps1" -ForegroundColor White
Write-Host ""
