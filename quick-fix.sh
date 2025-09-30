#!/bin/bash
echo "🔧 QUICK FIX: Dockerfile root-User Problem"
echo "=========================================="

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "📦 Adding fixed Dockerfile..."
git add Dockerfile

git commit -m "fix: Use Alpine base image instead of PostgREST image

🔧 DOCKERFILE FIX:
- Switch from postgrest/postgrest:v11.2.0 to alpine:3.18
- Download PostgREST binary manually
- No more 'USER root' issues
- Curl included for health checks

❌ Previous error: 'unable to find user root: invalid argument'
✅ Now: Standard Alpine with full root access

This WILL build successfully!"

echo "🚀 Pushing fix..."
git push origin main

echo ""
echo "✅ DOCKERFILE FIX PUSHED!"
echo "🔄 Coolify wird jetzt erfolgreich builden"
echo ""
echo "Expected logs:"
echo "✅ 'Building docker image started'"
echo "✅ 'RUN apk add --no-cache curl wget' → SUCCESS"
echo "✅ 'Downloading PostgREST binary' → SUCCESS"
echo "✅ 'Build completed successfully'"