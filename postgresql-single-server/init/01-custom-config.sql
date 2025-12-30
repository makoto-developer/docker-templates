-- ========================================
-- PostgreSQL 18 Custom Configuration
-- ========================================
-- This script applies custom settings via ALTER SYSTEM
-- Runs automatically on first container startup

-- ----------------------------------------
-- CONNECTION SETTINGS
-- ----------------------------------------
ALTER SYSTEM SET max_connections = '100';
ALTER SYSTEM SET superuser_reserved_connections = '3';

-- ----------------------------------------
-- MEMORY SETTINGS
-- ----------------------------------------
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET work_mem = '16MB';
ALTER SYSTEM SET temp_file_limit = '1048576';  -- 1GB in KB

-- ----------------------------------------
-- WAL SETTINGS
-- ----------------------------------------
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET fsync = 'on';
ALTER SYSTEM SET synchronous_commit = 'on';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET checkpoint_timeout = '10min';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET max_wal_size = '1GB';
ALTER SYSTEM SET min_wal_size = '80MB';

-- ----------------------------------------
-- QUERY TUNING
-- ----------------------------------------
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';

-- ----------------------------------------
-- LOGGING
-- ----------------------------------------
ALTER SYSTEM SET log_min_duration_statement = '1000';  -- 1秒以上のクエリをログ
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_duration = 'off';
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';
ALTER SYSTEM SET log_lock_waits = 'on';
ALTER SYSTEM SET log_statement = 'ddl';
ALTER SYSTEM SET log_temp_files = '0';
ALTER SYSTEM SET log_autovacuum_min_duration = '0';

-- ----------------------------------------
-- STATISTICS
-- ----------------------------------------
ALTER SYSTEM SET track_activities = 'on';
ALTER SYSTEM SET track_counts = 'on';
ALTER SYSTEM SET track_io_timing = 'on';
ALTER SYSTEM SET track_functions = 'all';
ALTER SYSTEM SET track_activity_query_size = '2048';

-- Note: pg_stat_statements requires shared_preload_libraries
-- which must be set via environment variable or command line

-- ----------------------------------------
-- AUTOVACUUM
-- ----------------------------------------
ALTER SYSTEM SET autovacuum = 'on';
ALTER SYSTEM SET autovacuum_max_workers = '3';
ALTER SYSTEM SET autovacuum_naptime = '1min';
ALTER SYSTEM SET autovacuum_vacuum_threshold = '50';
ALTER SYSTEM SET autovacuum_analyze_threshold = '50';
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = '0.1';
ALTER SYSTEM SET autovacuum_analyze_scale_factor = '0.05';

-- ----------------------------------------
-- LOCK MANAGEMENT
-- ----------------------------------------
ALTER SYSTEM SET deadlock_timeout = '1s';
ALTER SYSTEM SET max_locks_per_transaction = '64';

-- ----------------------------------------
-- SECURITY & TIMEOUTS
-- ----------------------------------------
ALTER SYSTEM SET statement_timeout = '0';  -- 0 = disabled
ALTER SYSTEM SET lock_timeout = '0';       -- 0 = disabled
ALTER SYSTEM SET idle_in_transaction_session_timeout = '600000';  -- 10 minutes
ALTER SYSTEM SET row_security = 'on';

-- Reload configuration to apply changes
-- Note: Some settings require a restart to take effect
SELECT pg_reload_conf();

-- Display applied configuration
SELECT 'Custom PostgreSQL configuration applied successfully!' AS status;
