#!/bin/bash
set -e

# SAMEBI Herramientas Backend Startup Script

echo "🚀 Starting SAMEBI Herramientas Backend..."

# Log-Verzeichnisse erstellen
mkdir -p /var/log/supervisor
mkdir -p /var/log/postgresql

# PostgreSQL-Datenverzeichnis initialisieren falls nötig
if [ ! -s "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "📊 Initializing PostgreSQL database..."
    su-exec postgres initdb -D /var/lib/postgresql/data
    
    # Schema und Seeds laden
    echo "🗄️ Loading database schema..."
    su-exec postgres pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/postgres.log start
    sleep 5
    
    # Datenbank und Schema erstellen
    su-exec postgres createdb herramientas
    su-exec postgres psql -d herramientas -f /app/database/schema.sql
    
    # Seeds laden falls vorhanden
    if [ -d "/app/database/seeds" ]; then
        echo "🌱 Loading database seeds..."
        for seed_file in /app/database/seeds/*.sql; do
            if [ -f "$seed_file" ]; then
                su-exec postgres psql -d herramientas -f "$seed_file"
            fi
        done
    fi
    
    su-exec postgres pg_ctl -D /var/lib/postgresql/data stop
    echo "✅ Database initialization complete"
fi

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

# Health Check Endpoint erstellen
cat > /tmp/health_check.sh << 'EOF'
#!/bin/bash
# Simple health check
curl -f http://localhost:3000/ > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "healthy"
    exit 0
else
    echo "unhealthy"
    exit 1
fi
EOF
chmod +x /tmp/health_check.sh

echo "🎯 Starting services with Supervisor..."

# Supervisor starten
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
