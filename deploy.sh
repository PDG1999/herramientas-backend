#!/bin/bash
# SAMEBI Herramientas Backend - Git Deployment Script

echo "🚀 SAMEBI Herramientas Backend - Git Deployment"
echo "================================================"

# Verzeichnis prüfen
if [ ! -f "Dockerfile" ]; then
    echo "❌ Fehler: Dockerfile nicht gefunden. Sind Sie im richtigen Verzeichnis?"
    exit 1
fi

echo "📁 Aktuelles Verzeichnis: $(pwd)"
echo "📋 Dateien die committed werden:"
ls -la

# Git-Repository initialisieren falls nötig
if [ ! -d ".git" ]; then
    echo "🔧 Git-Repository initialisieren..."
    git init
fi

# Remote-Repository hinzufügen/aktualisieren
echo "🔗 Remote-Repository konfigurieren..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/PDG1999/herramientas-backend.git

# Alle Dateien hinzufügen
echo "📦 Dateien zum Commit hinzufügen..."
git add .

# Commit erstellen
echo "💾 Commit erstellen..."
git commit -m "feat: Complete Docker configuration for Coolify deployment

✨ New Features:
- All-in-one Dockerfile with PostgreSQL + PostgREST + Redis
- Supervisor configuration for multi-service container
- Coolify-optimized docker-compose.yml
- SSL-ready configuration with health checks
- Automatic database initialization with schema

🐳 Docker Components:
- PostgreSQL 15 (port 5432)
- PostgREST API (port 3000) 
- Redis Cache (port 6379)
- Supervisor process management
- Health check endpoints

🔧 Configuration Files:
- Dockerfile: Multi-stage build optimized
- supervisord.conf: Process management
- postgrest.conf: API configuration
- postgresql.conf: Database tuning
- pg_hba.conf: Authentication setup
- start.sh: Initialization script

🚀 Deployment Ready:
- Coolify labels configured
- Domain: api.samebi.net
- Auto-SSL with Let's Encrypt
- Health monitoring enabled
- Production-ready setup

🔐 Security Features:
- Row Level Security (RLS)
- JWT authentication
- CORS configuration
- Secure password handling

📊 Database Schema:
- Users, stress_tests, rate_calculations
- Lead captures, analytics events
- Indexes for performance
- Seed data support

Ready for immediate Coolify deployment!"

# Zum Repository pushen
echo "🚀 Push zum GitHub Repository..."
git push -u origin main --force

echo ""
echo "✅ Deployment abgeschlossen!"
echo "🔗 Repository: https://github.com/PDG1999/herramientas-backend"
echo "🎯 Nächster Schritt: Coolify neu deployen"
echo ""
echo "In Coolify Dashboard:"
echo "1. Ihre herramientas-backend App auswählen"
echo "2. 'Deploy' Button klicken"
echo "3. Logs beobachten - sollte jetzt Dockerfile finden"
echo "4. Nach erfolgreichem Build: https://api.samebi.net testen"

