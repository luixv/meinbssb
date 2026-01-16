-- Create bed_datei_zuord table
CREATE TABLE IF NOT EXISTS bed_datei_zuord (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    antragsnummer VARCHAR(255) NOT NULL,
    datei_id INTEGER NOT NULL,
    datei_art VARCHAR(50) NOT NULL CHECK (datei_art IN ('SPORT', 'WBK')),
    bed_sport_id INTEGER
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_bed_datei_zuord_antragsnummer ON bed_datei_zuord(antragsnummer);
CREATE INDEX IF NOT EXISTS idx_bed_datei_zuord_datei_id ON bed_datei_zuord(datei_id);
CREATE INDEX IF NOT EXISTS idx_bed_datei_zuord_datei_art ON bed_datei_zuord(datei_art);
CREATE INDEX IF NOT EXISTS idx_bed_datei_zuord_bed_sport_id ON bed_datei_zuord(bed_sport_id);
CREATE INDEX IF NOT EXISTS idx_bed_datei_zuord_deleted_at ON bed_datei_zuord(deleted_at);

-- Grant permissions for PostgREST
GRANT SELECT, INSERT, UPDATE ON bed_datei_zuord TO devuser;
GRANT USAGE ON SEQUENCE bed_datei_zuord_id_seq TO devuser;
