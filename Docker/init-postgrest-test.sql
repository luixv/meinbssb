-- Create anonymous role (used by PostgREST for unauthenticated access)
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_roles WHERE rolname = 'web_anon'
   ) THEN
      CREATE ROLE web_anon NOLOGIN;
   END IF;
END
$$;

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
    kuerzel     TEXT NOT NULL,
    beschreibung TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT now(),
    deleted_at  TIMESTAMP,
    CONSTRAINT uq_bed_auswahl_typ_kuerzel UNIQUE (kuerzel)
);

-- Create bed_auswahl table (Selection Data Values)
CREATE TABLE IF NOT EXISTS bed_auswahl (
    id          SERIAL PRIMARY KEY,
    typ_id      INT NOT NULL REFERENCES bed_auswahl_typ(id) ON DELETE CASCADE,
    kuerzel     TEXT NOT NULL,
    beschreibung TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT now(),
    deleted_at  TIMESTAMP,
    CONSTRAINT uq_typ_kuerzel UNIQUE (typ_id, kuerzel)
);

-- Create bed_datei table (File Storage)
CREATE TABLE IF NOT EXISTS bed_datei (
    id              SERIAL PRIMARY KEY,
    created_at      TIMESTAMP DEFAULT now(),
    changed_at      TIMESTAMP,
    deleted_at      TIMESTAMP,
    antragsnummer   BIGINT NOT NULL,
    dateiname       TEXT NOT NULL,
    file_bytes      BYTEA NOT NULL
);

-- Create bed_sport table (Shooting Sport Records)
CREATE TABLE IF NOT EXISTS bed_sport (
    id                  SERIAL PRIMARY KEY,
    created_at          TIMESTAMP DEFAULT now(),
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT NOT NULL,
    schiessdatum         DATE NOT NULL,
    waffenart_id         INT NOT NULL REFERENCES bed_auswahl(id),
    disziplin_id         INT NOT NULL REFERENCES bed_auswahl(id),
    training             BOOLEAN NOT NULL DEFAULT false,
    wettkampfart_id      INT REFERENCES bed_auswahl(id),
    wettkampfergebnis    NUMERIC(7,1),
    bemerkung            TEXT
);

-- Create bed_waffe_besitz table (Weapon Ownership Records)
CREATE TABLE IF NOT EXISTS bed_waffe_besitz (
    id                  SERIAL PRIMARY KEY,
    created_at          TIMESTAMP DEFAULT now(),
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT NOT NULL,
    wbk_nr              VARCHAR(25) NOT NULL,
    lfd_wbk             VARCHAR(3) NOT NULL,
    waffenart_id        INT NOT NULL REFERENCES bed_auswahl(id),
    hersteller          VARCHAR(60),
    kaliber_id          INT NOT NULL REFERENCES bed_auswahl(id),
    lauflaenge_id       INT REFERENCES bed_auswahl(id),
    gewicht             VARCHAR(10),
    kompensator         BOOLEAN NOT NULL DEFAULT false,
    beduerfnisgrund_id  INT REFERENCES bed_auswahl(id),
    verband_id          INT REFERENCES bed_auswahl(id),
    bemerkung           VARCHAR(500)
);

-- Create sequence for antragsnummer starting at 100000
CREATE SEQUENCE IF NOT EXISTS seq_antragsnummer START WITH 100000;

-- Create bed_antrag_status table (Application Status)
CREATE TABLE IF NOT EXISTS bed_antrag_status (
    id              SERIAL PRIMARY KEY,
    status          TEXT NOT NULL,
    beschreibung    TEXT,
    deleted_at      TIMESTAMP,
    CONSTRAINT uq_bed_antrag_status_status UNIQUE (status)
);

-- Create bed_antrag table (Application/Request)
CREATE TABLE IF NOT EXISTS bed_antrag (
    id                  SERIAL PRIMARY KEY,
    created_at          TIMESTAMP DEFAULT now(),
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT NOT NULL DEFAULT nextval('seq_antragsnummer'),
    person_id           INT NOT NULL,
    status_id           INT REFERENCES bed_antrag_status(id),
    wbk_neu             BOOLEAN DEFAULT false,
    wbk_art             TEXT CHECK (wbk_art IN ('gelb', 'gruen')),
    beduerfnisart       TEXT CHECK (beduerfnisart IN ('langwaffe', 'kurzwaffe')),
    anzahl_waffen       INTEGER,
    verein_genehmigt    BOOLEAN DEFAULT false,
    email               TEXT,
    bankdaten           JSONB,
    abbuchung_erfolgt   BOOLEAN DEFAULT false,
    bemerkung           TEXT,
    CONSTRAINT uq_bed_antrag_antragsnummer UNIQUE (antragsnummer)
);

-- History tables for bed_* entities
CREATE TABLE IF NOT EXISTS his_bed_auswahl_typ (
    id          INT,
    kuerzel     TEXT,
    beschreibung TEXT,
    created_at  TIMESTAMP,
    deleted_at  TIMESTAMP,
    action      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_auswahl (
    id          INT,
    typ_id      INT,
    kuerzel     TEXT,
    beschreibung TEXT,
    created_at  TIMESTAMP,
    deleted_at  TIMESTAMP,
    action      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_datei (
    id              INT,
    created_at      TIMESTAMP,
    changed_at      TIMESTAMP,
    deleted_at      TIMESTAMP,
    antragsnummer   BIGINT,
    dateiname       TEXT,
    file_bytes      BYTEA,
    action          TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_sport (
    id                  INT,
    created_at          TIMESTAMP,
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT,
    schiessdatum        DATE,
    waffenart_id        INT,
    disziplin_id        INT,
    training            BOOLEAN,
    wettkampfart_id     INT,
    wettkampfergebnis   NUMERIC(7,1),
    bemerkung           TEXT,
    action              TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_waffe_besitz (
    id                  INT,
    created_at          TIMESTAMP,
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT,
    wbk_nr              VARCHAR(25),
    lfd_wbk             VARCHAR(3),
    waffenart_id        INT,
    hersteller          VARCHAR(60),
    kaliber_id          INT,
    lauflaenge_id       INT,
    gewicht             VARCHAR(10),
    kompensator         BOOLEAN,
    beduerfnisgrund_id  INT,
    verband_id          INT,
    bemerkung           VARCHAR(500),
    action              TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_antrag_status (
    id              INT,
    status          TEXT,
    beschreibung    TEXT,
    deleted_at      TIMESTAMP,
    action          TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS his_bed_antrag (
    id                  INT,
    created_at          TIMESTAMP,
    changed_at          TIMESTAMP,
    deleted_at          TIMESTAMP,
    antragsnummer       BIGINT,
    person_id           INT,
    status_id           INT,
    wbk_neu             BOOLEAN,
    wbk_art             TEXT,
    beduerfnisart       TEXT,
    anzahl_waffen       INTEGER,
    verein_genehmigt    BOOLEAN,
    email               TEXT,
    bankdaten           JSONB,
    abbuchung_erfolgt   BOOLEAN,
    bemerkung           TEXT,
    action              TEXT NOT NULL
);

-- Trigger functions for history logging
CREATE OR REPLACE FUNCTION fn_his_bed_auswahl_typ() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_auswahl_typ VALUES (NEW.id, NEW.kuerzel, NEW.beschreibung, NEW.created_at, NEW.deleted_at, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_auswahl_typ VALUES (OLD.id, OLD.kuerzel, OLD.beschreibung, OLD.created_at, OLD.deleted_at, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_auswahl_typ VALUES (OLD.id, OLD.kuerzel, OLD.beschreibung, OLD.created_at, OLD.deleted_at, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_auswahl() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_auswahl VALUES (NEW.id, NEW.typ_id, NEW.kuerzel, NEW.beschreibung, NEW.created_at, NEW.deleted_at, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_auswahl VALUES (OLD.id, OLD.typ_id, OLD.kuerzel, OLD.beschreibung, OLD.created_at, OLD.deleted_at, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_auswahl VALUES (OLD.id, OLD.typ_id, OLD.kuerzel, OLD.beschreibung, OLD.created_at, OLD.deleted_at, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_datei() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_datei VALUES (NEW.id, NEW.created_at, NEW.changed_at, NEW.deleted_at, NEW.antragsnummer, NEW.dateiname, NEW.file_bytes, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_datei VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.dateiname, OLD.file_bytes, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_datei VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.dateiname, OLD.file_bytes, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_sport() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_sport VALUES (NEW.id, NEW.created_at, NEW.changed_at, NEW.deleted_at, NEW.antragsnummer, NEW.schiessdatum, NEW.waffenart_id, NEW.disziplin_id, NEW.training, NEW.wettkampfart_id, NEW.wettkampfergebnis, NEW.bemerkung, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_sport VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.schiessdatum, OLD.waffenart_id, OLD.disziplin_id, OLD.training, OLD.wettkampfart_id, OLD.wettkampfergebnis, OLD.bemerkung, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_sport VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.schiessdatum, OLD.waffenart_id, OLD.disziplin_id, OLD.training, OLD.wettkampfart_id, OLD.wettkampfergebnis, OLD.bemerkung, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_waffe_besitz() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_waffe_besitz VALUES (NEW.id, NEW.created_at, NEW.changed_at, NEW.deleted_at, NEW.antragsnummer, NEW.wbk_nr, NEW.lfd_wbk, NEW.waffenart_id, NEW.hersteller, NEW.kaliber_id, NEW.lauflaenge_id, NEW.gewicht, NEW.kompensator, NEW.beduerfnisgrund_id, NEW.verband_id, NEW.bemerkung, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_waffe_besitz VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.wbk_nr, OLD.lfd_wbk, OLD.waffenart_id, OLD.hersteller, OLD.kaliber_id, OLD.lauflaenge_id, OLD.gewicht, OLD.kompensator, OLD.beduerfnisgrund_id, OLD.verband_id, OLD.bemerkung, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_waffe_besitz VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.wbk_nr, OLD.lfd_wbk, OLD.waffenart_id, OLD.hersteller, OLD.kaliber_id, OLD.lauflaenge_id, OLD.gewicht, OLD.kompensator, OLD.beduerfnisgrund_id, OLD.verband_id, OLD.bemerkung, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_antrag_status() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_antrag_status VALUES (NEW.id, NEW.status, NEW.beschreibung, NEW.deleted_at, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_antrag_status VALUES (OLD.id, OLD.status, OLD.beschreibung, OLD.deleted_at, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_antrag_status VALUES (OLD.id, OLD.status, OLD.beschreibung, OLD.deleted_at, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_his_bed_antrag() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO his_bed_antrag VALUES (NEW.id, NEW.created_at, NEW.changed_at, NEW.deleted_at, NEW.antragsnummer, NEW.person_id, NEW.status_id, NEW.wbk_neu, NEW.wbk_art, NEW.beduerfnisart, NEW.anzahl_waffen, NEW.verein_genehmigt, NEW.email, NEW.bankdaten, NEW.abbuchung_erfolgt, NEW.bemerkung, 'insert');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO his_bed_antrag VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.person_id, OLD.status_id, OLD.wbk_neu, OLD.wbk_art, OLD.beduerfnisart, OLD.anzahl_waffen, OLD.verein_genehmigt, OLD.email, OLD.bankdaten, OLD.abbuchung_erfolgt, OLD.bemerkung, 'update');
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO his_bed_antrag VALUES (OLD.id, OLD.created_at, OLD.changed_at, OLD.deleted_at, OLD.antragsnummer, OLD.person_id, OLD.status_id, OLD.wbk_neu, OLD.wbk_art, OLD.beduerfnisart, OLD.anzahl_waffen, OLD.verein_genehmigt, OLD.email, OLD.bankdaten, OLD.abbuchung_erfolgt, OLD.bemerkung, 'delete');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers to capture changes
DROP TRIGGER IF EXISTS trg_his_bed_auswahl_typ ON bed_auswahl_typ;
CREATE TRIGGER trg_his_bed_auswahl_typ
AFTER INSERT OR UPDATE OR DELETE ON bed_auswahl_typ
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_auswahl_typ();

DROP TRIGGER IF EXISTS trg_his_bed_auswahl ON bed_auswahl;
CREATE TRIGGER trg_his_bed_auswahl
AFTER INSERT OR UPDATE OR DELETE ON bed_auswahl
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_auswahl();

DROP TRIGGER IF EXISTS trg_his_bed_datei ON bed_datei;
CREATE TRIGGER trg_his_bed_datei
AFTER INSERT OR UPDATE OR DELETE ON bed_datei
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_datei();

DROP TRIGGER IF EXISTS trg_his_bed_sport ON bed_sport;
CREATE TRIGGER trg_his_bed_sport
AFTER INSERT OR UPDATE OR DELETE ON bed_sport
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_sport();

DROP TRIGGER IF EXISTS trg_his_bed_waffe_besitz ON bed_waffe_besitz;
CREATE TRIGGER trg_his_bed_waffe_besitz
AFTER INSERT OR UPDATE OR DELETE ON bed_waffe_besitz
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_waffe_besitz();

DROP TRIGGER IF EXISTS trg_his_bed_antrag_status ON bed_antrag_status;
CREATE TRIGGER trg_his_bed_antrag_status
AFTER INSERT OR UPDATE OR DELETE ON bed_antrag_status
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_antrag_status();

DROP TRIGGER IF EXISTS trg_his_bed_antrag ON bed_antrag;
CREATE TRIGGER trg_his_bed_antrag
AFTER INSERT OR UPDATE OR DELETE ON bed_antrag
FOR EACH ROW EXECUTE FUNCTION fn_his_bed_antrag();

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_pass_number ON users(pass_number);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token);

-- Create indexes for faster lookups (password_reset)
CREATE INDEX IF NOT EXISTS idx_password_reset_person_id ON password_reset(person_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_verification_token ON password_reset(verification_token);

-- Create indexes for faster lookups (user_email_validation)
CREATE INDEX IF NOT EXISTS idx_user_email_validation_person_id ON user_email_validation(person_id);
CREATE INDEX IF NOT EXISTS idx_user_email_validation_verification_token ON user_email_validation(verification_token);
CREATE INDEX IF NOT EXISTS idx_user_email_validation_email ON user_email_validation(email);

CREATE INDEX IF NOT EXISTS idx_api_request_logs_person_id ON api_request_logs(person_id);
CREATE INDEX IF NOT EXISTS idx_api_request_logs_created_at ON api_request_logs(created_at);

-- Indexes for bed_auswahl tables
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_typ_id ON bed_auswahl(typ_id);
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_typ_kuerzel ON bed_auswahl_typ(kuerzel);
CREATE INDEX IF NOT EXISTS idx_bed_auswahl_kuerzel ON bed_auswahl(kuerzel);

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

-- Indexes for bed_antrag_status table
CREATE INDEX IF NOT EXISTS idx_bed_antrag_status_status ON bed_antrag_status(status);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_status_deleted_at ON bed_antrag_status(deleted_at) WHERE deleted_at IS NULL;

-- Indexes for bed_antrag table
CREATE INDEX IF NOT EXISTS idx_bed_antrag_antragsnummer ON bed_antrag(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_person_id ON bed_antrag(person_id);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_status_id ON bed_antrag(status_id);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_email ON bed_antrag(email);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_created_at ON bed_antrag(created_at);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_deleted_at ON bed_antrag(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_bed_antrag_antragsnummer_person_id ON bed_antrag(antragsnummer, person_id);

-- Grant privileges to main app user (replace bssbuser with your POSTGRES_USER)
GRANT CONNECT ON DATABASE bssbdb TO bssbuser;
GRANT USAGE ON SCHEMA public TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bssbuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bssbuser;

-- Grant anonymous read access (PostgREST anon role)
GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO web_anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO web_anon;

-- Grant access to bed_auswahl tables
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_auswahl_typ TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_auswahl TO bssbuser;
GRANT SELECT ON bed_auswahl_typ TO web_anon;
GRANT SELECT ON bed_auswahl TO web_anon;

-- Grant access to bed_datei table
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_datei TO bssbuser;
GRANT SELECT, INSERT, UPDATE ON bed_datei TO web_anon;

-- Grant access to bed_sport table
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_sport TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_sport TO web_anon;

-- Grant access to bed_waffe_besitz table
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_waffe_besitz TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_waffe_besitz TO web_anon;

-- Grant access to bed_antrag_status table
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_antrag_status TO bssbuser;
GRANT SELECT, INSERT, UPDATE ON bed_antrag_status TO web_anon;
GRANT USAGE ON SEQUENCE bed_antrag_status_id_seq TO bssbuser;
GRANT USAGE ON SEQUENCE bed_antrag_status_id_seq TO web_anon;

-- Grant access to bed_antrag table
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_antrag TO bssbuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON bed_antrag TO web_anon;
GRANT USAGE ON SEQUENCE bed_antrag_id_seq TO bssbuser;
GRANT USAGE ON SEQUENCE bed_antrag_id_seq TO web_anon;
GRANT USAGE ON SEQUENCE seq_antragsnummer TO bssbuser;
GRANT USAGE ON SEQUENCE seq_antragsnummer TO web_anon;
