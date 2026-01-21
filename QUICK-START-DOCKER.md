# 🚀 Guide de Démarrage Rapide - Test Docker SIG

## ✅ Ce qui a été créé

Tous les fichiers Docker sont prêts :
- ✅ `docker-compose.yml` - Configuration principale
- ✅ `sig_backend/Dockerfile` - Backend optimisé (avec correction pour Windows)
- ✅ `sig_frontend/Dockerfile` - Frontend optimisé avec nginx
- ✅ `.env` - Variables d'environnement
- ✅ `README-DOCKER.md` - Documentation complète

## 🔧 Problème Corrigé

**Problème initial**: Erreur `exit code 127` avec gradlew  
**Solution appliquée**: Ajout de `dos2unix` dans le Dockerfile pour convertir les fins de ligne Windows (CRLF) en Linux (LF)

## 📝 Étapes pour Tester

### 1. Démarrer Docker Desktop

**IMPORTANT**: Docker Desktop doit être démarré avant de continuer

- Ouvrir "Docker Desktop" depuis le menu Démarrer
- Attendre que l'icône Docker dans la barre des tâches soit verte
- Vérifier que Docker fonctionne:

```powershell
docker ps
```

### 2. Se positionner dans le répertoire du projet

```powershell
cd "c:\Users\seia\Desktop\github repo\sig"
```

### 3. Construire les images Docker

```powershell
# Construire toutes les images
docker-compose build

# OU construire une image spécifique
docker-compose build backend
docker-compose build frontend
```

⏱️ **Temps estimé**: 10-15 minutes pour la première construction

### 4. Démarrer les services

```powershell
docker-compose up -d
```

### 5. Vérifier l'état des conteneurs

```powershell
docker-compose ps
```

Vous devriez voir 3 services en état "Up" :
- ✅ sig_postgres (base de données)
- ✅ sig_backend (API Spring Boot)
- ✅ sig_frontend (Interface Nuxt.js)

### 6. Vérifier les logs

```powershell
# Tous les logs
docker-compose logs

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### 7. Tester les services

```powershell
# Tester le backend
curl http://localhost:8080/actuator/health

# Tester le frontend (ouvrir dans le navigateur)
start http://localhost:80
```

## 🎯 Services Accessibles

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:80 | Interface utilisateur |
| **Backend API** | http://localhost:8080 | API REST |
| **Swagger** | http://localhost:8080/swagger-ui.html | Documentation API |
| **Health Check** | http://localhost:8080/actuator/health | État du serveur |

## 🛑 Arrêter les services

```powershell
# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes (⚠️ SUPPRIME LES DONNÉES)
docker-compose down -v
```

## ❌ Résolution des Problèmes

### Si le build backend échoue

```powershell
# Reconstruire sans cache
docker-compose build --no-cache backend
```

### Si un port est déjà utilisé

```powershell
# Trouver le processus sur le port 8080
netstat -ano | findstr :8080

# Modifier docker-compose.yml pour utiliser un autre port
# Exemple: "8081:8080" au lieu de "8080:8080"
```

### Si Docker Desktop n'est pas démarré

**Erreur**: `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified`

**Solution**: Démarrer Docker Desktop et attendre qu'il soit complètement initialisé

## 📚 Documentation Complète

Pour plus de détails, consultez `README-DOCKER.md`

## ✅ Checklist de Vérification

- [ ] Docker Desktop est démarré et fonctionne
- [ ] Les images se construisent sans erreur
- [ ] Les 3 conteneurs sont démarrés (postgres, backend, frontend)
- [ ] Le backend est accessible sur http://localhost:8080/actuator/health
- [ ] Le frontend est accessible sur http://localhost:80
- [ ] Les logs ne montrent pas d'erreurs critiques
- [ ] L'application fonctionne correctement
