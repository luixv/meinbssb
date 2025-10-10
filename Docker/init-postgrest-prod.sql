-- ========== Revoke privileges (safe starting state) ==========
REVOKE ALL ON SCHEMA public FROM public;
REVOKE ALL ON SCHEMA public FROM web_anon;
REVOKE ALL ON SCHEMA public FROM bssbuser;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM web_anon;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM bssbuser;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM public;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM web_anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM bssbuser;

-- prevent public from creating objects in public schema by default
REVOKE CREATE ON SCHEMA public FROM public;

-- ========== Roles ==========
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'web_anon') THEN
      CREATE ROLE web_anon NOLOGIN;
   END IF;
END
$$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bssbuser') THEN
      CREATE ROLE bssbuser NOINHERIT;
   END IF;
END
$$;

-- ========== Table definitions ==========
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(255),
    lastname VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    pass_number VARCHAR(50) UNIQUE,
    person_id VARCHAR(50) UNIQUE,
    verification_token VARCHAR(255) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ,
    is_verified BOOLEAN DEFAULT FALSE,
    profile_photo BYTEA
);

-- Create password_reset table
CREATE TABLE IF NOT EXISTS password_reset (
    id SERIAL PRIMARY KEY,
    person_id VARCHAR(50),
    verification_token VARCHAR(255) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMPTZ,
    is_used BOOLEAN DEFAULT FALSE
);

-- Create user_email_validation table
CREATE TABLE IF NOT EXISTS user_email_validation (
    id SERIAL PRIMARY KEY,
    person_id VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    emailtype VARCHAR(20) NOT NULL CHECK (emailtype IN ('private', 'business')),
    verification_token VARCHAR(255) UNIQUE NOT NULL,
    created_on TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    validated_on TIMESTAMPTZ,
    validated BOOLEAN DEFAULT FALSE
);

-- ========== Indexes ==========
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_pass_number ON users(pass_number);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token);

CREATE INDEX IF NOT EXISTS idx_password_reset_person_id ON password_reset(person_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_verification_token ON password_reset(verification_token);

CREATE INDEX IF NOT EXISTS idx_user_email_validation_person_id ON user_email_validation(person_id);
CREATE INDEX IF NOT EXISTS idx_user_email_validation_verification_token ON user_email_validation(verification_token);
CREATE INDEX IF NOT EXISTS idx_user_email_validation_email ON user_email_validation(email);

-- ========== Grants ==========
GRANT CONNECT ON DATABASE bssbdb TO bssbuser;

GRANT USAGE ON SCHEMA public TO bssbuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE users TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE password_reset TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE user_email_validation TO bssbuser;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bssbuser;

GRANT USAGE ON SCHEMA public TO web_anon;

GRANT SELECT (id, firstname, lastname, created_at, is_verified) ON users TO web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO bssbuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO bssbuser;
