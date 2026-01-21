#!/bin/bash
# Script bash pour déploiement Docker sur Linux/Mac
# Alternative au script PowerShell

set -e

echo "========================================"
echo "  Déploiement Docker - Projet SIG"
echo "========================================"
echo ""

# Vérifier Docker
echo "[1/5] Vérification de Docker..."
if ! command -v docker &> /dev/null; then
    echo "✗ Docker n'est pas installé!"
    exit 1
fi
echo "✓ Docker installé: $(docker --version)"

# Vérifier Docker Engine
echo "[2/5] Vérification de Docker Engine..."
if ! docker ps &> /dev/null; then
    echo "✗ Docker Engine n'est pas démarré!"
    echo "Démarrez Docker et relancez ce script."
    exit 1
fi
echo "✓ Docker Engine est démarré"

# Vérifier .env
echo "[3/5] Vérification de la configuration..."
if [ ! -f ".env" ]; then
    echo "⚠ Fichier .env introuvable, copie depuis .env.example..."
    cp .env.example .env
    echo "✓ Fichier .env créé"
else
    echo "✓ Fichier .env existe"
fi

# Construire les images
echo "[4/5] Construction des images Docker..."
echo "   Ceci peut prendre 10-15 minutes..."
docker-compose build

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la construction"
    exit 1
fi
echo "✓ Images construites avec succès"

# Démarrer les services
echo "[5/5] Démarrage des services..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors du démarrage"
    exit 1
fi
echo "✓ Services démarrés"

echo ""
echo "========================================"
echo "  Déploiement terminé avec succès!"
echo "========================================"
echo ""
echo "Services disponibles:"
echo "  • Frontend:     http://localhost:80"
echo "  • Backend API:  http://localhost:8080"
echo "  • Health Check: http://localhost:8080/actuator/health"
echo ""
echo "Commandes utiles:"
echo "  • Voir les logs:        docker-compose logs -f"
echo "  • Arrêter les services: docker-compose down"
echo "  • Statut des services:  docker-compose ps"
echo ""

# Attendre et vérifier
sleep 5
docker-compose ps
