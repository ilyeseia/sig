# Script PowerShell pour déployer SIG avec Docker
# Auteur: Assistant Antigravity
# Date: 2026-01-20

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Déploiement Docker - Projet SIG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Docker est installé
Write-Host "[1/5] Vérification de Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "✓ Docker installé: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker n'est pas installé!" -ForegroundColor Red
    Write-Host "Installez Docker Desktop depuis: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Vérifier si Docker est en cours d'exécution
Write-Host "[2/5] Vérification de Docker Engine..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$dockerRunning = $false

while ($retryCount -lt $maxRetries -and -not $dockerRunning) {
    try {
        docker ps | Out-Null
        $dockerRunning = $true
        Write-Host "✓ Docker Engine est démarré" -ForegroundColor Green
    } catch {
        if ($retryCount -eq 0) {
            Write-Host "✗ Docker Engine n'est pas démarré!" -ForegroundColor Red
            Write-Host "Démarrage de Docker Desktop..." -ForegroundColor Yellow
            Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
            Write-Host "Attente du démarrage de Docker Engine (max 60 secondes)..." -ForegroundColor Yellow
        }
        Start-Sleep -Seconds 2
        $retryCount++
        Write-Host "." -NoNewline
    }
}

if (-not $dockerRunning) {
    Write-Host ""
    Write-Host "✗ Docker Engine n'a pas pu démarrer!" -ForegroundColor Red
    Write-Host "Veuillez démarrer Docker Desktop manuellement et relancer ce script." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Vérifier si le fichier .env existe
Write-Host "[3/5] Vérification de la configuration..." -ForegroundColor Yellow
if (-Not (Test-Path ".env")) {
    Write-Host "⚠ Fichier .env introuvable, copie depuis .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✓ Fichier .env créé" -ForegroundColor Green
} else {
    Write-Host "✓ Fichier .env existe" -ForegroundColor Green
}

# Construire les images
Write-Host "[4/5] Construction des images Docker..." -ForegroundColor Yellow
Write-Host "   Ceci peut prendre 10-15 minutes la première fois..." -ForegroundColor Cyan
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Erreur lors de la construction des images" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Images construites avec succès" -ForegroundColor Green

# Démarrer les services
Write-Host "[5/5] Démarrage des services..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Erreur lors du démarrage des services" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Services démarrés" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Déploiement terminé avec succès!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services disponibles:" -ForegroundColor Cyan
Write-Host "  • Frontend:     http://localhost:80" -ForegroundColor White
Write-Host "  • Backend API:  http://localhost:8080" -ForegroundColor White
Write-Host "  • Health Check: http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host "  • Swagger:      http://localhost:8080/swagger-ui.html" -ForegroundColor White
Write-Host ""
Write-Host "Commandes utiles:" -ForegroundColor Cyan
Write-Host "  • Voir les logs:        docker-compose logs -f" -ForegroundColor White
Write-Host "  • Arrêter les services: docker-compose down" -ForegroundColor White
Write-Host "  • Statut des services:  docker-compose ps" -ForegroundColor White
Write-Host ""

# Attendre que les services soient prêts
Write-Host "Vérification de l'état des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker-compose ps

Write-Host ""
Write-Host "Ouverture du frontend dans le navigateur..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Start-Process "http://localhost:80"
