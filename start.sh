#!/bin/bash
set -e

# SAMEBI Herramientas Backend Startup Script

echo "🚀 Starting SAMEBI Herramientas Backend..."

# Log-Verzeichnisse erstellen
mkdir -p /var/log/supervisor
mkdir -p /var/log/postgresql
chown -R postgres:postgres /var/log/postgresql

# PostgreSQL-Datenverzeichnis initialisieren falls nötig
if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "📊 Initializing PostgreSQL database..."
    
    # PostgreSQL als postgres user initialisieren
    su-exec postgres initdb -D /var/lib/postgresql/data
    
    echo "✅ Database initialization complete"
fi

# Sicherstellen dass postgres user Berechtigung hat
chown -R postgres:postgres /var/lib/postgresql/data

# Environment Variables für PostgREST setzen
export PGRST_DB_URI="postgres://postgres:${POSTGRES_PASSWORD:-secure_password_123}@localhost:5432/herramientas"
export PGRST_DB_SCHEMAS="${PGRST_DB_SCHEMAS:-api}"
export PGRST_DB_ANON_ROLE="${PGRST_DB_ANON_ROLE:-web_anon}"
export PGRST_JWT_SECRET="${JWT_SECRET:-your-jwt-secret-key-here-min-32-chars}"

echo "🔧 Configuration:"
echo "   - Database: herramientas"
echo "   - PostgREST Port: 3000"
echo "   - Redis Port: 6379"
echo "   - PostgreSQL Port: 5432"

echo "🎯 Starting services with Supervisor..."

# Supervisor starten
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf