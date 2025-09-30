#!/bin/bash
echo "🔧 SAMEBI Backend - PostgreSQL Startup Fix"
echo "========================================"

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "🔧 Fixing PostgreSQL startup issues..."
git add supervisord.conf start.sh

git commit -m "fix: Resolve PostgreSQL startup issues in Supervisor

🔧 Critical PostgreSQL Fixes:
- Fix PostgreSQL command in supervisord.conf
- Add PGDATA environment variable
- Simplify database initialization in start.sh
- Fix file permissions for postgres user
- Remove complex database setup that was causing crashes

🐳 Supervisor improvements:
- Correct PostgreSQL startup command
- Better error handling and logging
- Proper user permissions
- Dependencies between services

This should resolve:
- 'postgresql entered FATAL state' error
- 'pg_ctl: could not start server' error
- PostgREST connection issues
- Health check failures

Expected result: All services start properly and API responds on port 3000."

echo "🚀 Pushing PostgreSQL fix..."
git push origin main

echo ""
echo "✅ PostgreSQL fix committed and pushed!"
echo "🔄 Coolify will rebuild automatically"
echo ""
echo "Expected logs after fix:"
echo "✅ 'PostgreSQL started successfully'"
echo "✅ 'PostgREST connected to database'"
echo "✅ 'Health check: healthy'"
echo "✅ 'API available on port 3000'"

