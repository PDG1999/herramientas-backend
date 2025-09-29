# Dockerfile für SAMEBI Herramientas Backend
# PostgreSQL + PostgREST + Redis Stack

FROM postgres:15-alpine AS postgres-base

# PostgREST Binary herunterladen
FROM postgrest/postgrest:v11.2.0 AS postgrest-binary

# Redis Binary
FROM redis:7-alpine AS redis-binary

# Final Image mit allen Services
FROM alpine:3.18

# Abhängigkeiten installieren (su-exec hinzugefügt!)
RUN apk add --no-cache \
    postgresql15 \
    postgresql15-client \
    postgresql15-contrib \
    supervisor \
    curl \
    bash \
    su-exec

# PostgREST Binary kopieren
COPY --from=postgrest-binary /bin/postgrest /usr/local/bin/postgrest

# Redis Binary kopieren  
COPY --from=redis-binary /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=redis-binary /usr/local/bin/redis-cli /usr/local/bin/redis-cli

# Arbeitsverzeichnis
WORKDIR /app

# Database Schema und Seeds kopieren
COPY database/ /app/database/

# Supervisor-Konfiguration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# PostgreSQL-Konfiguration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# PostgREST-Konfiguration
COPY postgrest.conf /app/postgrest.conf

# Startup-Script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# PostgreSQL-Datenverzeichnis erstellen (ohne User-Erstellung - existiert bereits)
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Log-Verzeichnisse erstellen
RUN mkdir -p /var/log/supervisor /var/log/postgresql && \
    chown -R postgres:postgres /var/log/postgresql

# Ports exponieren
EXPOSE 3000 5432 6379

# Health Check (curl ist jetzt installiert)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Supervisor starten
CMD ["/app/start.sh"]