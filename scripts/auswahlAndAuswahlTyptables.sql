TRUNCATE TABLE bed_auswahl RESTART IDENTITY cascade;
TRUNCATE TABLE bed_auswahl_typ RESTART IDENTITY cascade;

INSERT INTO bed_auswahl_typ (kuerzel, beschreibung, created_at)
VALUES 
('Waffenart', 'Waffenart', now()),
('Wettkampfart', 'Wettkampfart', now()),
('Verband', 'Verband', now()),
('Lauflänge', 'Lauflänge', now()),
('Bedürfnisgrund', 'Bedürfnisgrund', now()),
('Kaliber', 'Kaliber', now()),
('Dateiart', 'Dateiart', now());

INSERT INTO bed_auswahl (typ_id, kuerzel, beschreibung, created_at)
VALUES 
(1, 'Gewehr', 'Gewehr1', now()),
(1,	'Pistole', 'Pistole', now()),
(1,	'Revolver', 'Revolver', now()),
(1,	'Flinte', 'Flinte', now()),
(2,	'VM', 'Vereinsmeisterschaft', now()),
(2,	'GM', 'Gaumeisterschaft', now()),
(2,	'BM', 'Bezirksmeisterschaft', now()),
(2,	'DM', 'Deusche Meisterschaft', now()),
(2,	'INT', 'Internationaler Wettbewerb', now()),
(2,	'RWK', 'Rundenwettkampf', now()),
(2,	'SW', 'Sonstiger Wettbewerb', now()),
(3,	'BSSB', 'BSSB', now()),
(3,	'sonstiger Verband', 'sonstiger Verband', now()),
(4,	'3 bis 6', '3 bis 6 ', now()),
(4,	'3.93 bis 6,53', '3.93 bis 6,53', now()),
(4,	'3 bis offen', '3 bis offen', now()),
(5,	'Sport', 'Sport', now()),
(5,	'Jagd', 'Jagd', now()),
(5,	'sonstiges', 'sonstiges', now()),
(6,	'KK', 'KK', now()),
(6,	'1', '1', now()),
(6,	'2', '2', now());

insert into bed_antrag_status (id, status, beschreibung)
values
(1, 1, 'Entwurf'),
(2, 2, 'Gelöscht'),
(3, 3, 'Eingereicht am Verein'),
(4, 4, 'Zurückgewiesen an Mitglied von Verein'),
(5, 5, 'Genehmight von Verein'),
(6, 6, 'Zurückgewiesen von BSSB an Verein'),
(7, 7, 'Zurückgewiesen von BSSB an Mitglied'),
(8, 8, 'Eingereicht an BSSB'),	
(9, 9, 'Genehmight'),	
(10, 10, 'Abgelehnt');

SELECT * FROM bed_auswahl_typ;
SELECT * FROM bed_auswahl;
SELECT * FROM bed_antrag_status;

