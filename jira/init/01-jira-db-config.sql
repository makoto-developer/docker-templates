-- Jira Database Configuration
-- This script runs automatically when PostgreSQL container starts for the first time

-- Set default transaction isolation level (recommended for Jira)
ALTER DATABASE jiradb SET default_transaction_isolation TO 'read committed';

-- Create schema if needed (Jira will use public schema by default)
-- GRANT ALL PRIVILEGES ON SCHEMA public TO jiradb_user;

-- Performance tuning for Jira (optional)
-- These settings can be adjusted based on your server resources

-- Note: Most PostgreSQL tuning should be done via postgresql.conf
-- This file is for database-specific settings only

-- Verify database encoding
DO $$
BEGIN
    RAISE NOTICE 'Jira database initialized successfully';
    RAISE NOTICE 'Database encoding: %', (SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname = 'jiradb');
END $$;
