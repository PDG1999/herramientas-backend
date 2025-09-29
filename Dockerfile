# Einfacher Dockerfile für SAMEBI Herramientas Backend
# Nur PostgREST mit externer PostgreSQL-Verbindung

FROM alpine:3.18

# System-Abhängigkeiten installieren (inkl. curl für Health Checks)
RUN apk add --no-cache curl wget

# PostgREST Binary herunterladen
RUN wget -O /tmp/postgrest.tar.xz https://github.com/PostgREST/postgrest/releases/download/v11.2.0/postgrest-v11.2.0-linux-static-x64.tar.xz && \
    cd /tmp && \
    tar -xf postgrest.tar.xz && \
    mv postgrest /usr/local/bin/postgrest && \
    chmod +x /usr/local/bin/postgrest && \
    rm /tmp/postgrest.tar.xz

# PostgREST-Konfiguration kopieren
COPY postgrest.conf /etc/postgrest.conf

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Port exponieren
EXPOSE 3000

# PostgREST starten
CMD ["/usr/local/bin/postgrest", "/etc/postgrest.conf"]
