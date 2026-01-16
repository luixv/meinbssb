-- Create bed_antrag_person table
CREATE TABLE IF NOT EXISTS bed_antrag_person (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    antragsnummer VARCHAR(255) NOT NULL,
    person_id BIGINT NOT NULL,
    status_id INTEGER,
    vorname VARCHAR(255),
    nachname VARCHAR(255),
    vereinsname VARCHAR(255)
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_bed_antrag_person_antragsnummer ON bed_antrag_person(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_person_person_id ON bed_antrag_person(person_id);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_person_status_id ON bed_antrag_person(status_id);
CREATE INDEX IF NOT EXISTS idx_bed_antrag_person_deleted_at ON bed_antrag_person(deleted_at);

-- Grant permissions for PostgREST
GRANT SELECT, INSERT, UPDATE ON bed_antrag_person TO devuser;
GRANT USAGE ON SEQUENCE bed_antrag_person_id_seq TO devuser;
