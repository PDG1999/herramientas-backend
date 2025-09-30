#!/bin/bash
echo "⚡ SAMEBI Backend - Instant PostgreSQL Fix"
echo "========================================"

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "🔧 Fixing PostgreSQL user/group conflict..."
git add Dockerfile

git commit -m "fix: Remove duplicate postgres user/group creation

🔧 Fix Docker build error:
- Remove addgroup/adduser commands for postgres
- PostgreSQL package already creates postgres user/group
- Keep directory creation and permissions
- Resolves 'addgroup: group postgres in use' error

This should complete the Docker build successfully."

echo "🚀 Pushing fix..."
git push origin main

echo ""
echo "✅ PostgreSQL fix pushed!"
echo "🔄 Coolify will rebuild automatically in 1-2 minutes"
echo "📋 Expected: Docker build should complete successfully now"

