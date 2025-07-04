-- Create user_registrations table
CREATE TABLE IF NOT EXISTS user_registrations (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(255) NOT NULL,
    lastName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    pass_number VARCHAR(50) NOT NULL UNIQUE,
    verification_link VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN DEFAULT FALSE
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_registrations_email ON user_registrations(email);
CREATE INDEX IF NOT EXISTS idx_user_registrations_pass_number ON user_registrations(pass_number);
CREATE INDEX IF NOT EXISTS idx_user_registrations_verification_link ON user_registrations(verification_link);

-- Grant permissions for PostgREST
GRANT SELECT, INSERT, UPDATE ON user_registrations TO devuser;
GRANT USAGE ON SEQUENCE user_registrations_id_seq TO devuser; 