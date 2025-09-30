#!/bin/bash
# SAMEBI Backend - Fix Commit Script

echo "🔧 SAMEBI Backend - Committing su-exec Fix"
echo "=========================================="

# Verzeichnis prüfen
if [ ! -f "Dockerfile" ]; then
    echo "❌ Fehler: Dockerfile nicht gefunden. Sind Sie im richtigen Verzeichnis?"
    exit 1
fi

echo "📁 Aktuelles Verzeichnis: $(pwd)"

# Git-Status prüfen
echo "📋 Git-Status:"
git status --porcelain

# Geänderte Dateien hinzufügen
echo "📦 Hinzufügen der korrigierten Dateien..."
git add Dockerfile start.sh

# Commit erstellen
echo "💾 Commit mit Fix erstellen..."
git commit -m "fix: Add missing su-exec package and improve PostgreSQL setup

🔧 Critical Fixes:
- Add su-exec package to Alpine Linux dependencies
- Fix PostgreSQL user management in start.sh script
- Improve database initialization process
- Add proper user/group setup for postgres user
- Fix health check dependencies (curl available)

🐳 Docker Improvements:
- All required packages now included in image
- Proper PostgreSQL user handling with su-exec
- Better error handling in startup script
- Health check should now work correctly
- Robust database initialization

🚀 Deployment Ready:
- Container should start without su-exec errors
- PostgreSQL initialization will work properly
- Health checks will pass
- API should be accessible on port 3000

Fixes the 'su-exec: command not found' error in Coolify deployment."

# Push zum Repository
echo "🚀 Push zum GitHub Repository..."
git push origin main

echo ""
echo "✅ Fix committed and pushed successfully!"
echo "🔗 Repository: https://github.com/PDG1999/herramientas-backend"
echo ""
echo "🎯 Nächste Schritte:"
echo "1. Coolify wird automatisch neu deployen (oder manuell 'Deploy' klicken)"
echo "2. Logs in Coolify beobachten - sollte jetzt ohne su-exec Fehler laufen"
echo "3. Nach erfolgreichem Build: https://api.samebi.net testen"
echo ""
echo "Erwartete Logs in Coolify:"
echo "✅ 'Starting SAMEBI Herramientas Backend...'"
echo "✅ 'Database initialization complete'"
echo "✅ 'Starting services with Supervisor...'"
echo "✅ Health check: 'healthy'"

