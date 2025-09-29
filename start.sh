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
    
    # PostgreSQL initialisieren
    su-exec postgres initdb -D /var/lib/postgresql/data
    
    # PostgreSQL temporär starten für Setup
    su-exec postgres pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/postgres.log start
    sleep 5
    
    # Datenbank und Schema erstellen
    echo "🗄️ Creating database and schema..."
    su-exec postgres createdb herramientas
    
    # Schema laden
    if [ -f "/app/database/schema.sql" ]; then
        echo "📋 Loading database schema..."
        su-exec postgres psql -d herramientas -f /app/database/schema.sql
    fi
    
    # Seeds laden falls vorhanden
    if [ -d "/app/database/seeds" ]; then
        echo "🌱 Loading database seeds..."
        for seed_file in /app/database/seeds/*.sql; do
            if [ -f "$seed_file" ]; then
                echo "Loading: $seed_file"
                su-exec postgres psql -d herramientas -f "$seed_file"
            fi
        done
    fi
    
    # PostgreSQL stoppen für Supervisor-Start
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

# Simple Health Check Endpoint erstellen
mkdir -p /tmp
cat > /tmp/health_check.sh << 'EOF'
#!/bin/bash
# Simple health check for PostgREST
if curl -f http://localhost:3000/ > /dev/null 2>&1; then
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