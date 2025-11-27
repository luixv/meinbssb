-- Create api_request_logs table
CREATE TABLE IF NOT EXISTS api_request_logs (
    id SERIAL PRIMARY KEY,
    person_id INTEGER,
    logs JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_api_request_logs_person_id ON api_request_logs(person_id);
CREATE INDEX IF NOT EXISTS idx_api_request_logs_created_at ON api_request_logs(created_at);

-- Grant permissions for PostgREST
GRANT SELECT, INSERT, UPDATE ON api_request_logs TO devuser;
GRANT USAGE ON SEQUENCE api_request_logs_id_seq TO devuser;




