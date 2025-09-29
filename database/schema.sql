-- Herramientas Backend Database Schema
-- SAMEBI Marketing Tools für Psychologen

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Schemas
CREATE SCHEMA IF NOT EXISTS api;
CREATE SCHEMA IF NOT EXISTS private;

-- Roles
CREATE ROLE web_anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;

-- Grant usage
GRANT USAGE ON SCHEMA api TO web_anon, authenticated;

-- Users Table
CREATE TABLE IF NOT EXISTS api.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stress Tests Table
CREATE TABLE IF NOT EXISTS api.stress_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES api.users(id),
    session_id VARCHAR(255),
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    answers JSONB NOT NULL,
    recommendations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Rate Calculations Table  
CREATE TABLE IF NOT EXISTS api.rate_calculations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES api.users(id),
    session_id VARCHAR(255),
    monthly_expenses DECIMAL(10,2) NOT NULL,
    desired_salary DECIMAL(10,2) NOT NULL,
    work_hours_per_week INTEGER NOT NULL,
    vacation_weeks INTEGER DEFAULT 4,
    calculated_rate DECIMAL(10,2) NOT NULL,
    recommended_rate DECIMAL(10,2) NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Location Analysis Table
CREATE TABLE IF NOT EXISTS api.location_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES api.users(id),
    session_id VARCHAR(255),
    address TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    competitor_count INTEGER,
    demographic_score INTEGER CHECK (demographic_score >= 0 AND demographic_score <= 100),
    accessibility_score INTEGER CHECK (accessibility_score >= 0 AND accessibility_score <= 100),
    total_score INTEGER CHECK (total_score >= 0 AND total_score <= 100),
    recommendations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Burnout Tests Table
CREATE TABLE IF NOT EXISTS api.burnout_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES api.users(id),
    session_id VARCHAR(255),
    emotional_exhaustion_score INTEGER,
    depersonalization_score INTEGER,
    personal_accomplishment_score INTEGER,
    total_score INTEGER CHECK (total_score >= 0 AND total_score <= 100),
    risk_level VARCHAR(20) CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    answers JSONB NOT NULL,
    recommendations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Generation Table
CREATE TABLE IF NOT EXISTS api.content_generations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES api.users(id),
    session_id VARCHAR(255),
    topic VARCHAR(255) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    generated_content TEXT NOT NULL,
    hashtags TEXT[],
    engagement_prediction INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lead Captures Table
CREATE TABLE IF NOT EXISTS api.lead_captures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    tool_used VARCHAR(100) NOT NULL,
    test_result_id UUID,
    marketing_consent BOOLEAN DEFAULT FALSE,
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics Events Table
CREATE TABLE IF NOT EXISTS api.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(255),
    event_type VARCHAR(100) NOT NULL,
    tool_name VARCHAR(100),
    event_data JSONB,
    user_agent TEXT,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_stress_tests_created_at ON api.stress_tests(created_at);
CREATE INDEX IF NOT EXISTS idx_stress_tests_session_id ON api.stress_tests(session_id);
CREATE INDEX IF NOT EXISTS idx_rate_calculations_created_at ON api.rate_calculations(created_at);
CREATE INDEX IF NOT EXISTS idx_location_analyses_created_at ON api.location_analyses(created_at);
CREATE INDEX IF NOT EXISTS idx_burnout_tests_created_at ON api.burnout_tests(created_at);
CREATE INDEX IF NOT EXISTS idx_content_generations_created_at ON api.content_generations(created_at);
CREATE INDEX IF NOT EXISTS idx_lead_captures_email ON api.lead_captures(email);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at ON api.analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_events_tool_name ON api.analytics_events(tool_name);

-- Row Level Security Policies
ALTER TABLE api.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.stress_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.rate_calculations ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.location_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.burnout_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE api.content_generations ENABLE ROW LEVEL SECURITY;

-- Policies for anonymous access (session-based)
CREATE POLICY "Allow anonymous read own session" ON api.stress_tests
    FOR SELECT TO web_anon
    USING (session_id = current_setting('request.jwt.claims', true)::json->>'session_id');

CREATE POLICY "Allow anonymous insert" ON api.stress_tests
    FOR INSERT TO web_anon
    WITH CHECK (true);

-- Similar policies for other tables
CREATE POLICY "Allow anonymous read own session" ON api.rate_calculations
    FOR SELECT TO web_anon
    USING (session_id = current_setting('request.jwt.claims', true)::json->>'session_id');

CREATE POLICY "Allow anonymous insert" ON api.rate_calculations
    FOR INSERT TO web_anon
    WITH CHECK (true);

-- Grant permissions
GRANT SELECT, INSERT ON api.stress_tests TO web_anon;
GRANT SELECT, INSERT ON api.rate_calculations TO web_anon;
GRANT SELECT, INSERT ON api.location_analyses TO web_anon;
GRANT SELECT, INSERT ON api.burnout_tests TO web_anon;
GRANT SELECT, INSERT ON api.content_generations TO web_anon;
GRANT SELECT, INSERT ON api.lead_captures TO web_anon;
GRANT SELECT, INSERT ON api.analytics_events TO web_anon;

-- Functions for updated_at timestamps
CREATE OR REPLACE FUNCTION private.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON api.users
    FOR EACH ROW
    EXECUTE FUNCTION private.set_updated_at();
