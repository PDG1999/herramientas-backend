# Einfacher Dockerfile für SAMEBI Herramientas Backend
# Nur PostgREST mit externer PostgreSQL-Verbindung

FROM postgrest/postgrest:v11.2.0

# Curl für Health Checks hinzufügen
USER root
RUN apk add --no-cache curl

# PostgREST-Konfiguration kopieren
COPY postgrest.conf /etc/postgrest.conf

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Port exponieren
EXPOSE 3000

# PostgREST starten
CMD ["postgrest", "/etc/postgrest.conf"]
