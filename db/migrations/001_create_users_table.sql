-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(255) NOT NULL,
    lastName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    pass_number VARCHAR(50) NOT NULL UNIQUE,
    verification_token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN DEFAULT FALSE
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_pass_number ON users(pass_number);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token);

-- Grant permissions for PostgREST
GRANT SELECT, INSERT, UPDATE ON users TO devuser;
GRANT USAGE ON SEQUENCE users_id_seq TO devuser; 