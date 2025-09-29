# Herramientas Backend - SAMEBI Tools

## 🎯 Übersicht
Zentrales Backend für alle SAMEBI Marketing-Tools für Psychologen.

## 🛠️ Tech Stack
- **Database:** PostgreSQL 15
- **API:** PostgREST (Auto-generated REST API)
- **Authentication:** JWT + Row Level Security
- **Hosting:** Hetzner Cloud + Coolify
- **Domain:** api.samebi.net

## 📊 Unterstützte Tools
1. **Stress-Checker** - Stress-Level Assessment
2. **Rate-Calculator** - Stundensatz-Optimierung  
3. **Burnout-Test** - Burnout-Risiko Bewertung
4. **Location-Analyzer** - Praxis-Standort Analyse
5. **Content-Generator** - Social Media Content

## 🚀 Quick Start

### Lokale Entwicklung
```bash
# Repository klonen
git clone https://github.com/PDG1999/herramientas-backend.git
cd herramientas-backend

# Docker Setup
docker-compose up -d

# Database Migration
npm run migrate

# API starten
npm run dev
```

### Coolify Deployment
```bash
# Automatisches Deployment bei Git Push
git push origin main
# → Deployed auf api.samebi.net
```

## 📁 Projekt Struktur
```
herramientas-backend/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── schema.sql
├── api/
│   ├── routes/
│   ├── middleware/
│   └── config/
├── docker-compose.yml
├── Dockerfile
└── coolify.json
```

## 🔐 Umgebungsvariablen
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/herramientas
JWT_SECRET=your-jwt-secret
CORS_ORIGIN=https://herramientas.samebi.net
```

## 📈 API Endpoints
- `GET /api/stress-tests` - Stress-Test Ergebnisse
- `POST /api/stress-tests` - Neuer Stress-Test
- `GET /api/rate-calculations` - Stundensatz-Berechnungen
- `POST /api/rate-calculations` - Neue Berechnung
- `GET /api/locations` - Standort-Analysen
- `POST /api/locations` - Neue Standort-Analyse

## 🔄 Development Workflow
1. Feature Branch erstellen
2. Lokale Entwicklung + Tests
3. Pull Request erstellen
4. Merge → Auto-Deploy via Coolify

## 📞 Support
- **Entwickler:** PDG1999
- **Projekt:** SAMEBI Marketing Tools
- **Status:** Active Development
