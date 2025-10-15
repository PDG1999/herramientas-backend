-- Migration: Add Counseling/Dashboard Tables to PostgREST Backend
-- Purpose: Konsolidierung vom alten Express-Backend (api-check.samebi.net) zu PostgREST (api.samebi.net)
-- Date: 15. Oktober 2025

-- ============================================================================
-- COUNSELING TABLES (from tool-sucht-indentifizieren-anonym/backend)
-- ============================================================================

-- Counselors table (Berater & Supervisoren)
CREATE TABLE IF NOT EXISTS api.counselors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'counselor' CHECK (role IN ('counselor', 'supervisor', 'admin')),
    license_number VARCHAR(50),
    specialization TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    total_clients INTEGER DEFAULT 0,
    total_tests INTEGER DEFAULT 0,
    latest_test_date TIMESTAMP WITH TIME ZONE
);

-- Clients table (Klienten)
CREATE TABLE IF NOT EXISTS api.clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    counselor_id UUID NOT NULL REFERENCES api.counselors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_test_at TIMESTAMP WITH TIME ZONE
);

-- Test results table (Sucht-Screening Ergebnisse)
CREATE TABLE IF NOT EXISTS api.test_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES api.clients(id) ON DELETE CASCADE,
    counselor_id UUID NOT NULL REFERENCES api.counselors(id) ON DELETE CASCADE,
    responses JSONB NOT NULL,
    public_scores JSONB NOT NULL,
    professional_scores JSONB NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    session_notes TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date TIMESTAMP WITH TIME ZONE,
    risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('low', 'moderate', 'high', 'critical')),
    primary_concern VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Tracking & Analytics
    aborted BOOLEAN DEFAULT FALSE,
    aborted_at_question INTEGER,
    completed_questions INTEGER,
    session_data JSONB,
    tracking_data JSONB
);

-- Test progress table (Auto-Save intermediate state)
CREATE TABLE IF NOT EXISTS api.test_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(255) UNIQUE NOT NULL,
    responses JSONB NOT NULL DEFAULT '[]'::jsonb,
    current_question INTEGER DEFAULT 0,
    test_type VARCHAR(50) DEFAULT 'screening',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Anonymous sessions table (Session-Tracking ohne Login)
CREATE TABLE IF NOT EXISTS api.anonymous_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(255) UNIQUE NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    test_type VARCHAR(50),
    user_agent TEXT,
    ip_address INET,
    referrer TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test session metrics (Detaillierte Session-Analytik)
CREATE TABLE IF NOT EXISTS api.test_session_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_result_id UUID REFERENCES api.test_results(id) ON DELETE CASCADE,
    session_id VARCHAR(255) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    total_duration_seconds INTEGER,
    resume_count INTEGER DEFAULT 0,
    device_type VARCHAR(50),
    browser VARCHAR(100),
    os VARCHAR(100),
    screen_resolution VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Question metrics (Fragen-Level Analytik)
CREATE TABLE IF NOT EXISTS api.question_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_result_id UUID REFERENCES api.test_results(id) ON DELETE CASCADE,
    question_id VARCHAR(50) NOT NULL,
    time_spent_seconds INTEGER,
    answer_changed_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions table (Auth-Tokens für Berater)
CREATE TABLE IF NOT EXISTS api.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    counselor_id UUID NOT NULL REFERENCES api.counselors(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Audit log table (Security & Compliance)
CREATE TABLE IF NOT EXISTS api.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    counselor_id UUID REFERENCES api.counselors(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_counselors_email ON api.counselors(email);
CREATE INDEX IF NOT EXISTS idx_counselors_role ON api.counselors(role);
CREATE INDEX IF NOT EXISTS idx_clients_counselor_id ON api.clients(counselor_id);
CREATE INDEX IF NOT EXISTS idx_clients_status ON api.clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_email ON api.clients(email);
CREATE INDEX IF NOT EXISTS idx_test_results_client_id ON api.test_results(client_id);
CREATE INDEX IF NOT EXISTS idx_test_results_counselor_id ON api.test_results(counselor_id);
CREATE INDEX IF NOT EXISTS idx_test_results_risk_level ON api.test_results(risk_level);
CREATE INDEX IF NOT EXISTS idx_test_results_completed_at ON api.test_results(completed_at);
CREATE INDEX IF NOT EXISTS idx_test_results_created_at ON api.test_results(created_at);
CREATE INDEX IF NOT EXISTS idx_test_progress_session_id ON api.test_progress(session_id);
CREATE INDEX IF NOT EXISTS idx_test_progress_updated_at ON api.test_progress(updated_at);
CREATE INDEX IF NOT EXISTS idx_anonymous_sessions_session_id ON api.anonymous_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_sessions_counselor_id ON api.sessions(counselor_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON api.sessions(token);
CREATE INDEX IF NOT EXISTS idx_audit_logs_counselor_id ON api.audit_logs(counselor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON api.audit_logs(created_at);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Updated_at triggers (bereits definiert in schema.sql, hier nur für neue Tabellen)
CREATE TRIGGER set_updated_at_counselors
    BEFORE UPDATE ON api.counselors
    FOR EACH ROW
    EXECUTE FUNCTION private.set_updated_at();

CREATE TRIGGER set_updated_at_clients
    BEFORE UPDATE ON api.clients
    FOR EACH ROW
    EXECUTE FUNCTION private.set_updated_at();

CREATE TRIGGER set_updated_at_test_results
    BEFORE UPDATE ON api.test_results
    FOR EACH ROW
    EXECUTE FUNCTION private.set_updated_at();

CREATE TRIGGER set_updated_at_test_progress
    BEFORE UPDATE ON api.test_progress
    FOR EACH ROW
    EXECUTE FUNCTION private.set_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE api.counselors ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.test_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.sessions ENABLE ROW LEVEL SECURITY;

-- Anonymous access für Test-Submission (ohne Login)
CREATE POLICY "Allow anonymous test submission" ON api.test_results
    FOR INSERT TO web_anon
    WITH CHECK (true);

CREATE POLICY "Allow anonymous test progress save" ON api.test_progress
    FOR INSERT TO web_anon
    WITH CHECK (true);

CREATE POLICY "Allow anonymous test progress update" ON api.test_progress
    FOR UPDATE TO web_anon
    USING (true)
    WITH CHECK (true);

-- Authenticated access für Berater
CREATE POLICY "Counselors see own clients" ON api.clients
    FOR SELECT TO authenticated
    USING (counselor_id = current_setting('request.jwt.claims', true)::json->>'counselor_id'::uuid);

CREATE POLICY "Counselors see own test results" ON api.test_results
    FOR SELECT TO authenticated
    USING (counselor_id = current_setting('request.jwt.claims', true)::json->>'counselor_id'::uuid);

-- Supervisors see ALL
CREATE POLICY "Supervisors see all clients" ON api.clients
    FOR SELECT TO authenticated
    USING (
        (current_setting('request.jwt.claims', true)::json->>'role') = 'supervisor'
        OR 
        counselor_id = current_setting('request.jwt.claims', true)::json->>'counselor_id'::uuid
    );

CREATE POLICY "Supervisors see all test results" ON api.test_results
    FOR SELECT TO authenticated
    USING (
        (current_setting('request.jwt.claims', true)::json->>'role') = 'supervisor'
        OR 
        counselor_id = current_setting('request.jwt.claims', true)::json->>'counselor_id'::uuid
    );

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

-- Anonymous can submit tests & save progress
GRANT SELECT, INSERT, UPDATE ON api.test_results TO web_anon;
GRANT SELECT, INSERT, UPDATE ON api.test_progress TO web_anon;
GRANT SELECT, INSERT ON api.anonymous_sessions TO web_anon;
GRANT SELECT, INSERT ON api.test_session_metrics TO web_anon;
GRANT SELECT, INSERT ON api.question_metrics TO web_anon;

-- Authenticated users (counselors/supervisors)
GRANT SELECT ON api.counselors TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON api.clients TO authenticated;
GRANT SELECT, INSERT, UPDATE ON api.test_results TO authenticated;
GRANT SELECT ON api.sessions TO authenticated;
GRANT SELECT ON api.audit_logs TO authenticated;

-- ============================================================================
-- VIEWS (Optional - für bessere API Ergonomie)
-- ============================================================================

-- View: Test Results mit Client & Counselor Namen
CREATE OR REPLACE VIEW api.test_results_full AS
SELECT 
    tr.*,
    c.name as client_name,
    c.email as client_email,
    co.name as counselor_name,
    co.email as counselor_email,
    co.role as counselor_role
FROM api.test_results tr
LEFT JOIN api.clients c ON tr.client_id = c.id
LEFT JOIN api.counselors co ON tr.counselor_id = co.id;

GRANT SELECT ON api.test_results_full TO web_anon, authenticated;

-- View: Dashboard Statistics (für Supervisor)
CREATE OR REPLACE VIEW api.dashboard_stats AS
SELECT 
    COUNT(DISTINCT tr.id) as total_tests,
    COUNT(DISTINCT c.id) as total_clients,
    COUNT(DISTINCT co.id) as total_counselors,
    AVG(CASE WHEN tr.completed_questions IS NOT NULL 
        THEN tr.completed_questions::float / 40 * 100 
        ELSE 100 END) as avg_completion_rate,
    COUNT(CASE WHEN tr.aborted = true THEN 1 END)::float / 
        NULLIF(COUNT(tr.id), 0) * 100 as abort_rate,
    COUNT(CASE WHEN tr.risk_level = 'critical' THEN 1 END) as critical_cases,
    COUNT(CASE WHEN tr.risk_level = 'high' THEN 1 END) as high_risk_cases
FROM api.test_results tr
LEFT JOIN api.clients c ON tr.client_id = c.id
LEFT JOIN api.counselors co ON tr.counselor_id = co.id;

GRANT SELECT ON api.dashboard_stats TO authenticated;

-- ============================================================================
-- DEMO DATA (Optional - für Testing)
-- ============================================================================

-- Insert System Account (für anonyme Tests)
INSERT INTO api.counselors (id, name, email, password_hash, role, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'System Account',
    'system@samebi.net',
    '$2a$10$dummyhashforsystemaccount',
    'admin',
    true
)
ON CONFLICT (email) DO NOTHING;

-- Insert Supervisor Account (für Demo)
INSERT INTO api.counselors (id, name, email, password_hash, role, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'Supervisor Demo',
    'supervisor@samebi.net',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- SuperPass2024!
    'supervisor',
    true
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================

COMMENT ON TABLE api.counselors IS 'Berater und Supervisoren (migriert von Express Backend)';
COMMENT ON TABLE api.clients IS 'Klienten (migriert von Express Backend)';
COMMENT ON TABLE api.test_results IS 'Sucht-Screening Test-Ergebnisse (migriert von Express Backend)';
COMMENT ON TABLE api.test_progress IS 'Auto-Save intermediate test state (migriert von Express Backend)';
COMMENT ON TABLE api.anonymous_sessions IS 'Session-Tracking für anonyme Tests (migriert von Express Backend)';

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Migration abgeschlossen!';
    RAISE NOTICE '📊 Neue Tabellen: counselors, clients, test_results, test_progress, anonymous_sessions';
    RAISE NOTICE '🔐 RLS Policies aktiviert für sichere Multi-Tenant Architektur';
    RAISE NOTICE '🎯 Nächster Schritt: Daten vom alten Express-Backend migrieren';
END $$;

