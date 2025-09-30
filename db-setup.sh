#!/bin/bash
echo "🗄️  SAMEBI Backend - Database Setup"
echo "=================================="

cd "/Volumes/SSD Samsung 970 PDG/PDG-Tools-SAMEBI/herramientas-backend"

echo "📦 Adding database configuration..."
git add postgrest.conf database/init.sql

git commit -m "feat: Add PostgreSQL database configuration for Coolify

🗄️  DATABASE SETUP:
- PostgREST config now uses Coolify environment variables
- Added init.sql with basic API schema
- Created web_anon role for PostgREST
- Added health_check table for API testing

🔧 Environment Variables needed in Coolify:
- PGRST_DB_URI=postgres://postgres:PASSWORD@DB_HOST:5432/herramientas
- PGRST_DB_SCHEMAS=api
- PGRST_DB_ANON_ROLE=web_anon
- PGRST_JWT_SECRET=your-secret-key

Next: Create PostgreSQL database in Coolify!"

echo "🚀 Pushing database setup..."
git push origin main

echo ""
echo "✅ DATABASE CONFIGURATION PUSHED!"
echo ""
echo "🔄 Next steps in Coolify:"
echo "1. Create PostgreSQL database: 'herramientas-db'"
echo "2. Set environment variables in herramientas-backend app"
echo "3. Redeploy herramientas-backend"
echo ""
echo "Expected result: PostgREST connects to database → API works!"

