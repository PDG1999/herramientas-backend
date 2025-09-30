-- SAMEBI Herramientas Backend - Initial Database Schema
-- Einfaches Schema für API-Tests

-- API Schema für PostgREST erstellen
CREATE SCHEMA IF NOT EXISTS api;

-- Web Anonymous Role für PostgREST
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA api TO web_anon;

-- Test-Tabelle für API-Funktionalität
CREATE TABLE IF NOT EXISTS api.health_check (
    id SERIAL PRIMARY KEY,
    status TEXT DEFAULT 'healthy',
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Permissions für web_anon
GRANT SELECT ON api.health_check TO web_anon;

-- Test-Daten einfügen
INSERT INTO api.health_check (status) VALUES ('healthy') ON CONFLICT DO NOTHING;

