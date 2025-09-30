#!/bin/bash
echo "🔧 POSTGREST CONFIG FIX"
echo "======================"

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "📦 Fixing PostgREST configuration..."
git add postgrest.conf

git commit -m "fix: Remove environment variable syntax from PostgREST config

🔧 CONFIG FIX:
- Removed \${VARIABLE} syntax from postgrest.conf
- PostgREST reads environment variables automatically
- Config file now contains only static settings

❌ Previous error: 'unexpected \"{\" in config'
✅ Now: Clean config file, env vars read directly

Environment Variables in Coolify will work automatically!"

echo "🚀 Pushing config fix..."
git push origin main

echo ""
echo "✅ CONFIG FIX PUSHED!"
echo ""
echo "🔄 PostgREST wird jetzt die Environment Variables direkt lesen"
echo "Expected: PostgREST startet erfolgreich mit DB-Verbindung!"

