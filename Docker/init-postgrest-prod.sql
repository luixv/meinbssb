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
    is_deleted BOOLEAN DEFAULT FALSE,
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

-- Create api_request_logs table
CREATE TABLE IF NOT EXISTS api_request_logs (
    id SERIAL PRIMARY KEY,
    person_id INTEGER,
    logs JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create bed_auswahl_typ table (Selection Types/Categories)
CREATE TABLE IF NOT EXISTS bed_auswahl_typ (
    id          SERIAL PRIMARY KEY,
    kurz        TEXT NOT NULL,
    lang        TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT now(),
    deleted_at  TIMESTAMP,
    CONSTRAINT uq_bed_auswahl_typ_kurz UNIQUE (kurz)
);

-- Create bed_auswahl_data table (Selection Data Values)
CREATE TABLE IF NOT EXISTS bed_auswahl_data (
    id          SERIAL PRIMARY KEY,
    typ_id      INT NOT NULL REFERENCES bed_auswahl_typ(id) ON DELETE CASCADE,
    kurz        TEXT NOT NULL,
    lang        TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT now(),
    deleted_at  TIMESTAMP,
    CONSTRAINT uq_typ_kurz UNIQUE (typ_id, kurz)
);

-- Create bed_datei table (File Storage)
CREATE TABLE IF NOT EXISTS bed_datei (
    id              SERIAL PRIMARY KEY,
    created_at      TIMESTAMP DEFAULT now(),
    changed_at      TIMESTAMP,
    deleted_at      TIMESTAMP,
    antragsnummer   TEXT NOT NULL,
    dateiname       TEXT NOT NULL,
    file_bytes      BYTEA NOT NULL
);

-- Create bed_sport table (Shooting Sport Records)
CREATE TABLE IF NOT EXISTS bed_sport (
    id                  SERIAL PRIMARY KEY,
    created_at          TIMESTAMP DEFAULT now(),
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       TEXT NOT NULL,
    schiessdatum         DATE NOT NULL,
    waffenart_id         INT NOT NULL REFERENCES bed_auswahl_data(id),
    disziplin_id         INT NOT NULL REFERENCES bed_auswahl_data(id),
    training             BOOLEAN NOT NULL DEFAULT false,
    wettkampfart_id      INT REFERENCES bed_auswahl_data(id),
    wettkampfergebnis    NUMERIC(7,1)
);

-- Create bed_waffe_besitz table (Weapon Ownership Records)
CREATE TABLE IF NOT EXISTS bed_waffe_besitz (
    id                  SERIAL PRIMARY KEY,
    created_at          TIMESTAMP DEFAULT now(),
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       TEXT NOT NULL,
    wbk_nr              VARCHAR(25) NOT NULL,
    lfd_wbk             VARCHAR(3) NOT NULL,
    waffenart_id        INT NOT NULL REFERENCES bed_auswahl_data(id),
    hersteller          VARCHAR(60),
    kaliber_id          INT NOT NULL REFERENCES bed_auswahl_data(id),
    lauflaenge_id       INT REFERENCES bed_auswahl_data(id),
    gewicht             VARCHAR(10),
    kompensator         BOOLEAN NOT NULL DEFAULT false,
    beduerfnisgrund_id  INT REFERENCES bed_auswahl_data(id),
    verband_id          INT REFERENCES bed_auswahl_data(id),
    bemerkung           VARCHAR(500)
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

CREATE INDEX IF NOT EXISTS idx_api_request_logs_person_id ON api_request_logs(person_id);
CREATE INDEX IF NOT EXISTS idx_api_request_logs_created_at ON api_request_logs(created_at);

-- Indexes for bed_auswahl tables
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_data_typ_id ON bed_auswahl_data(typ_id);
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_typ_kurz ON bed_auswahl_typ(kurz);
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_data_kurz ON bed_auswahl_data(kurz);

-- Indexes for bed_datei table
CREATE INDEX IF NOT EXISTS idx_bed_datei_antragsnummer ON bed_datei(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_datei_dateiname ON bed_datei(dateiname);
CREATE INDEX IF NOT EXISTS idx_bed_datei_created_at ON bed_datei(created_at);
CREATE INDEX IF NOT EXISTS idx_bed_datei_deleted_at ON bed_datei(deleted_at) WHERE deleted_at IS NULL;

-- Indexes for bed_sport table
CREATE INDEX IF NOT EXISTS idx_bed_sport_antragsnummer ON bed_sport(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_sport_schiessdatum ON bed_sport(schiessdatum);
CREATE INDEX IF NOT EXISTS idx_bed_sport_waffenart_id ON bed_sport(waffenart_id);
CREATE INDEX IF NOT EXISTS idx_bed_sport_disziplin_id ON bed_sport(disziplin_id);
CREATE INDEX IF NOT EXISTS idx_bed_sport_wettkampfart_id ON bed_sport(wettkampfart_id);
CREATE INDEX IF NOT EXISTS idx_bed_sport_training ON bed_sport(training);
CREATE INDEX IF NOT EXISTS idx_bed_sport_deleted_at ON bed_sport(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_bed_sport_antragsnummer_schiessdatum ON bed_sport(antragsnummer, schiessdatum);

-- Indexes for bed_waffe_besitz table
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_antragsnummer ON bed_waffe_besitz(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_wbk_nr ON bed_waffe_besitz(wbk_nr);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_lfd_wbk ON bed_waffe_besitz(lfd_wbk);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_waffenart_id ON bed_waffe_besitz(waffenart_id);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_kaliber_id ON bed_waffe_besitz(kaliber_id);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_lauflaenge_id ON bed_waffe_besitz(lauflaenge_id);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_beduerfnisgrund_id ON bed_waffe_besitz(beduerfnisgrund_id);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_verband_id ON bed_waffe_besitz(verband_id);
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_deleted_at ON bed_waffe_besitz(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_bed_waffe_besitz_wbk_nr_lfd_wbk ON bed_waffe_besitz(wbk_nr, lfd_wbk);

-- ========== Grants ==========
GRANT CONNECT ON DATABASE bssbdb TO bssbuser;

GRANT USAGE ON SCHEMA public TO bssbuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE users TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE password_reset TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE user_email_validation TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE api_request_logs TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE bed_auswahl_typ TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE bed_auswahl_data TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE bed_datei TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE bed_sport TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE bed_waffe_besitz TO bssbuser;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bssbuser;

GRANT USAGE ON SCHEMA public TO web_anon;

GRANT SELECT (id, firstname, lastname, created_at, is_verified) ON users TO web_anon;
GRANT SELECT ON bed_auswahl_typ TO web_anon;
GRANT SELECT ON bed_auswahl_data TO web_anon;
GRANT SELECT, INSERT, UPDATE ON bed_datei TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_sport TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_waffe_besitz TO web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO bssbuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO bssbuser;
