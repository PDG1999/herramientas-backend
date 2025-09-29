#!/bin/bash
echo "🚨 EMERGENCY: PostgreSQL Fix Push"
echo "================================="

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "📋 Current status:"
git status

echo ""
echo "📦 Adding ALL corrected files..."
git add .

echo "💾 Creating emergency commit..."
git commit -m "EMERGENCY: Fix PostgreSQL startup in Supervisor

🚨 Critical PostgreSQL Fixes:
- Fixed supervisord.conf PostgreSQL command
- Simplified start.sh database initialization  
- Added proper PGDATA environment variable
- Fixed file permissions and user setup

🔧 Changes:
- supervisord.conf: Correct PostgreSQL startup command
- start.sh: Simplified initialization without complex setup
- Removed config file conflicts

This MUST resolve:
❌ 'postgresql entered FATAL state' 
❌ 'pg_ctl: could not start server'
❌ PostgREST connection failures
❌ Health check failures

Expected: PostgreSQL starts → PostgREST connects → API works"

echo "🚀 FORCE pushing to ensure Coolify gets new code..."
git push origin main --force

echo ""
echo "✅ EMERGENCY PUSH COMPLETE!"
echo "🔄 Coolify should now rebuild with NEW image"
echo "📋 Watch for: 'Building new image' (not 'Build step skipped')"
echo ""
echo "Expected new logs:"
echo "✅ 'INFO success: postgresql entered RUNNING state'"
echo "✅ 'INFO success: postgrest entered RUNNING state'"
echo "✅ 'Healthcheck status: healthy'"
