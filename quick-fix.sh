#!/bin/bash
echo "🔧 SAMEBI Backend - Quick Fix Push"
echo "================================="

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "📋 Current files:"
ls -la Dockerfile start.sh

echo ""
echo "📦 Adding corrected files..."
git add Dockerfile start.sh

echo "💾 Creating commit with su-exec fix..."
git commit -m "fix: Add su-exec package to resolve startup errors

🔧 Critical Fix:
- Add su-exec package to Alpine dependencies in Dockerfile
- Fix PostgreSQL initialization in start.sh
- Resolve 'su-exec: command not found' error

This should make the container start properly in Coolify."

echo "🚀 Pushing to repository..."
git push origin main

echo ""
echo "✅ Done! Coolify should now rebuild with the fixed Dockerfile."
echo "🔄 Wait 1-2 minutes for automatic deployment or click 'Deploy' in Coolify."
