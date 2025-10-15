-- Data Migration Script: Express Backend → PostgREST Backend
-- Source: api-check.samebi.net (PostgreSQL auf nsgccoc4scg8g444c400c840)
-- Target: api.samebi.net (PostgREST Backend)
-- Date: 15. Oktober 2025

-- ============================================================================
-- WICHTIG: DIESES SCRIPT MUSS AUF DEM ZIEL-SERVER (api.samebi.net) AUSGEFÜHRT WERDEN!
-- ============================================================================

-- VORAUSSETZUNGEN:
-- 1. migration_add_counseling.sql wurde bereits ausgeführt
-- 2. Foreign Data Wrapper (postgres_fdw) ist installiert
-- 3. Verbindung zum alten Backend ist möglich

-- ============================================================================
-- SETUP: Foreign Data Wrapper
-- ============================================================================

-- Extension aktivieren
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Server-Verbindung zum alten Backend erstellen
CREATE SERVER IF NOT EXISTS old_express_backend
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host '91.98.93.203',
    port '5432',
    dbname 'postgres' -- Name der alten DB
);

-- User Mapping (Zugangsdaten für alte DB)
-- ACHTUNG: Diese Credentials müssen angepasst werden!
CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER
SERVER old_express_backend
OPTIONS (
    user 'postgres',
    password 'YOUR_OLD_DB_PASSWORD' -- TODO: Echtes Passwort einfügen!
);

-- ============================================================================
-- FOREIGN TABLES: Alte Tabellen als Foreign Tables importieren
-- ============================================================================

-- Import Schema von alter DB
IMPORT FOREIGN SCHEMA public
LIMIT TO (counselors, clients, test_results, test_progress, anonymous_sessions, sessions, audit_logs)
FROM SERVER old_express_backend
INTO public;

-- ============================================================================
-- DATA MIGRATION: Counselors
-- ============================================================================

INSERT INTO api.counselors (
    id, name, email, password_hash, role, license_number, specialization,
    created_at, updated_at, last_login_at, is_active, total_clients, total_tests, latest_test_date
)
SELECT 
    id, name, email, password_hash, 
    COALESCE(role, 'counselor'),
    license_number, specialization,
    created_at, updated_at, last_login_at, is_active,
    COALESCE(total_clients, 0),
    COALESCE(total_tests, 0),
    latest_test_date
FROM public.counselors
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    license_number = EXCLUDED.license_number,
    specialization = EXCLUDED.specialization,
    updated_at = EXCLUDED.updated_at,
    last_login_at = EXCLUDED.last_login_at,
    is_active = EXCLUDED.is_active,
    total_clients = EXCLUDED.total_clients,
    total_tests = EXCLUDED.total_tests,
    latest_test_date = EXCLUDED.latest_test_date;

-- ============================================================================
-- DATA MIGRATION: Clients
-- ============================================================================

INSERT INTO api.clients (
    id, counselor_id, name, email, phone, status, notes,
    created_at, updated_at, last_test_at
)
SELECT 
    id, counselor_id, name, email, phone, status, notes,
    created_at, updated_at, last_test_at
FROM public.clients
ON CONFLICT (id) DO UPDATE SET
    counselor_id = EXCLUDED.counselor_id,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    updated_at = EXCLUDED.updated_at,
    last_test_at = EXCLUDED.last_test_at;

-- ============================================================================
-- DATA MIGRATION: Test Results
-- ============================================================================

INSERT INTO api.test_results (
    id, client_id, counselor_id, responses, public_scores, professional_scores,
    completed_at, session_notes, follow_up_required, follow_up_date,
    risk_level, primary_concern, created_at, updated_at,
    aborted, aborted_at_question, completed_questions, session_data, tracking_data
)
SELECT 
    id, client_id, counselor_id, responses, public_scores, professional_scores,
    completed_at, session_notes, follow_up_required, follow_up_date,
    risk_level, primary_concern, created_at, updated_at,
    COALESCE(aborted, false),
    aborted_at_question,
    completed_questions,
    session_data,
    tracking_data
FROM public.test_results
ON CONFLICT (id) DO UPDATE SET
    client_id = EXCLUDED.client_id,
    counselor_id = EXCLUDED.counselor_id,
    responses = EXCLUDED.responses,
    public_scores = EXCLUDED.public_scores,
    professional_scores = EXCLUDED.professional_scores,
    completed_at = EXCLUDED.completed_at,
    session_notes = EXCLUDED.session_notes,
    follow_up_required = EXCLUDED.follow_up_required,
    follow_up_date = EXCLUDED.follow_up_date,
    risk_level = EXCLUDED.risk_level,
    primary_concern = EXCLUDED.primary_concern,
    updated_at = EXCLUDED.updated_at,
    aborted = EXCLUDED.aborted,
    aborted_at_question = EXCLUDED.aborted_at_question,
    completed_questions = EXCLUDED.completed_questions,
    session_data = EXCLUDED.session_data,
    tracking_data = EXCLUDED.tracking_data;

-- ============================================================================
-- DATA MIGRATION: Test Progress (Optional - nur wenn gewünscht)
-- ============================================================================

INSERT INTO api.test_progress (
    id, session_id, responses, current_question, test_type,
    created_at, updated_at, last_saved_at
)
SELECT 
    id, session_id, responses, current_question, test_type,
    created_at, updated_at, last_saved_at
FROM public.test_progress
WHERE updated_at > NOW() - INTERVAL '7 days' -- Nur letzte 7 Tage
ON CONFLICT (session_id) DO UPDATE SET
    responses = EXCLUDED.responses,
    current_question = EXCLUDED.current_question,
    updated_at = EXCLUDED.updated_at,
    last_saved_at = EXCLUDED.last_saved_at;

-- ============================================================================
-- DATA MIGRATION: Sessions (Optional - nur aktive Sessions)
-- ============================================================================

INSERT INTO api.sessions (
    id, counselor_id, token, expires_at, created_at, is_active
)
SELECT 
    id, counselor_id, token, expires_at, created_at, is_active
FROM public.sessions
WHERE expires_at > NOW() AND is_active = true
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- DATA MIGRATION: Audit Logs (Optional - nur letzte 30 Tage)
-- ============================================================================

INSERT INTO api.audit_logs (
    id, counselor_id, action, resource_type, resource_id, details,
    ip_address, user_agent, created_at
)
SELECT 
    id, counselor_id, action, resource_type, resource_id, details,
    ip_address, user_agent, created_at
FROM public.audit_logs
WHERE created_at > NOW() - INTERVAL '30 days'
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- CLEANUP: Foreign Tables entfernen
-- ============================================================================

DROP FOREIGN TABLE IF EXISTS public.counselors CASCADE;
DROP FOREIGN TABLE IF EXISTS public.clients CASCADE;
DROP FOREIGN TABLE IF EXISTS public.test_results CASCADE;
DROP FOREIGN TABLE IF EXISTS public.test_progress CASCADE;
DROP FOREIGN TABLE IF EXISTS public.anonymous_sessions CASCADE;
DROP FOREIGN TABLE IF EXISTS public.sessions CASCADE;
DROP FOREIGN TABLE IF EXISTS public.audit_logs CASCADE;

-- ============================================================================
-- VERIFICATION: Daten prüfen
-- ============================================================================

DO $$
DECLARE
    counselor_count INTEGER;
    client_count INTEGER;
    test_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO counselor_count FROM api.counselors;
    SELECT COUNT(*) INTO client_count FROM api.clients;
    SELECT COUNT(*) INTO test_count FROM api.test_results;
    
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ MIGRATION ABGESCHLOSSEN!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '📊 Migrierte Daten:';
    RAISE NOTICE '   Berater/Supervisoren: %', counselor_count;
    RAISE NOTICE '   Klienten: %', client_count;
    RAISE NOTICE '   Test-Ergebnisse: %', test_count;
    RAISE NOTICE '============================================';
    RAISE NOTICE '🎯 Nächste Schritte:';
    RAISE NOTICE '   1. Dashboard auf PostgREST umstellen';
    RAISE NOTICE '   2. Alte Express-Backend testen & deprecaten';
    RAISE NOTICE '   3. DNS/Routing aktualisieren';
    RAISE NOTICE '============================================';
END $$;

