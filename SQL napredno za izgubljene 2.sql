DROP DATABASE IF EXISTS evidencija_racun;

CREATE DATABASE evidencija_racun;

USE evidencija_racun;

CREATE TABLE zaposlenik (
 id INTEGER PRIMARY KEY,
 ime VARCHAR(20),
 prezime VARCHAR(30),
 oib CHAR(11),
 datum_zaposlenja DATETIME
);

CREATE TABLE artikl (
 id INTEGER PRIMARY KEY,
 naziv VARCHAR(20),
 cijena NUMERIC(10, 2)
);

CREATE TABLE racun (
 id INTEGER PRIMARY KEY,
 id_zaposlenik INTEGER,
 broj VARCHAR(20),
 datum_izdavanja DATETIME
);

CREATE TABLE stavka_racun (
 id INTEGER PRIMARY KEY,
 id_racun INTEGER,
 id_artikl INTEGER,
 kolicina INTEGER
);

INSERT INTO zaposlenik VALUES 
							  (4, 'Nina', 'Marko', '123454', STR_TO_DATE('20.02.2020.', '%d.%m.%Y.'));
 
INSERT INTO artikl VALUES (11, 'Puding', 5.99),
						  (12, 'Milka čokolada', 30.00),
						  (13, 'Kruh', 6.00),
						  (14, 'Čips', 9.00),
						  (15, 'Sladoled', 12.00);
 
INSERT INTO racun VALUES (21, 1, '00001', STR_TO_DATE('12.02.2020.', '%d.%m.%Y.')),
						 (22, 2, '00002', STR_TO_DATE('13.02.2020.', '%d.%m.%Y.')),
						 (23, 1, '00003', STR_TO_DATE('16.02.2020.', '%d.%m.%Y.')),
						 (24, 3, '00004', STR_TO_DATE('16.02.2020.', '%d.%m.%Y.'));

INSERT INTO stavka_racun VALUES (31, 21, 11, 2),
								(32, 21, 12, 3),
								(33, 21, 13, 1),
								(34, 21, 14, 5),
								(35, 22, 12, 1),
								(36, 22, 14, 4),
								(37, 23, 13, 2),
								(38, 24, 14, 1);


-- prikaži sve račune koje je izdala zaposlenica sa imenom 'Tea' (rezultat: id, id_zaposlenik, broj, datum_izdavanja)

SELECT r.*
	FROM racun AS r, zaposlenik AS z
    WHERE z.id = r.id_zaposlenik AND ime = 'Tea';

-- prikaži artikl sa najmanjom cijenom (rezultat: id, naziv, cijena)

SELECT a.*
	FROM artikl AS a
    WHERE cijena =
		(SELECT MIN(cijena) FROM artikl);

--  prikaži sve datume i broj računa izdanih na taj dan (rezultat: datum_izdavanja, broj_izdanih_racuna)

SELECT datum_izdavanja, COUNT(racun.id) AS broj_izdanih_racuna
	FROM racun
	GROUP BY datum_izdavanja;

-- obriši zaposlenike koji nisu izdali niti jedan račun

DELETE z.*
	FROM zaposlenik AS z
    WHERE id NOT IN (SELECT id_zaposlenik FROM racun);

-- prikaži sve artikle koji su prodani u sveukupnoj količini većoj od 3 (rezultat: id, naziv, cijena)

SELECT a.*
	FROM artikl AS a
    INNER JOIN stavka_racun AS s ON (s.id_artikl = a.id)
    GROUP BY a.id, a.naziv, a.cijena
    HAVING SUM(s.kolicina) > 3;
    