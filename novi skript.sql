CREATE DATABASE trgovina;
USE trgovina;

CREATE TABLE kupac (
	id INTEGER NOT NULL,
	ime VARCHAR(10) NOT NULL,
	prezime VARCHAR(15) NOT NULL
);

CREATE TABLE zaposlenik (
	id INTEGER NOT NULL,
	ime VARCHAR(10) NOT NULL,
	prezime VARCHAR(15) NOT NULL,
	oib CHAR(10) NOT NULL,
	datum_zaposlenja DATETIME NOT NULL
);

CREATE TABLE artikl (
	id INTEGER NOT NULL,
	naziv VARCHAR(20) NOT NULL,
	cijena NUMERIC(10,2) NOT NULL
);

CREATE TABLE racun (
	id INTEGER NOT NULL,
	id_zaposlenik INTEGER NOT NULL,
	id_kupac INTEGER NOT NULL,
	broj VARCHAR(100) NOT NULL,
	datum_izdavanja DATETIME NOT NULL
);

CREATE TABLE stavka_racun (
	id INTEGER NOT NULL,
	id_racun INTEGER NOT NULL,
	id_artikl INTEGER NOT NULL,
	kolicina INTEGER NOT NULL
);


/* == Unos podataka == */
INSERT INTO kupac VALUES (1, 'Lea', 'Fabris'),
                         (2, 'David', 'Sirotić'),
                         (3, 'Tea', 'Bibić');

INSERT INTO zaposlenik VALUES 
	(11, 'Marko', 'Marić', '123451', STR_TO_DATE('01.10.2020.', '%d.%m.%Y.')),
	(12, 'Toni', 'Milovan', '123452', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.')),
	(13, 'Tea', 'Marić', '123453', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.'));

INSERT INTO artikl VALUES (21, 'Puding', 5.99),
                          (22, 'Milka čokolada', 30.00),
                          (23, 'Čips', 9);

INSERT INTO racun VALUES 
	(31, 11, 1, '00001', STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
	(32, 12, 2, '00002', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.')),
	(33, 12, 1, '00003', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.'));

INSERT INTO stavka_racun VALUES (41, 31, 21, 2),
                                (42, 31, 22, 5),
                                (43, 32, 22, 1),
                                (44, 32, 21, 1);
-- Prikaži sve zaposlenike čije ime sadrži barem 4 slova				
SELECT *
	FROM zaposlenik
		WHERE LENGTH(ime) >= 4;
        
-- Prikaži sva imena zaposlenika koja se pojavljuju kao imena kupaca
SELECT ime
	FROM zaposlenik
		WHERE ime IN (SELECT ime FROM kupac);
        
-- Ažuriraj artikle tako da im se cijena spusti za 10%
SELECT *, (cijena/100)*90 AS nova_cijena
	FROM artikl;
    
-- Prikaži artikle koji imaju iznadprosječnu cijenu
SELECT *
	FROM artikl
		WHERE cijena > (SELECT AVG(cijena) AS prosjek FROM artikl);

-- Prikaži sve artikle i račune na kojima su izdani, pritom prikazati i artikle koji nisu niti jednom kupljeni (niti jednom dodani na stavke računa)
SELECT a.id, a.naziv, sr.id_racun
	FROM artikl AS a
LEFT OUTER JOIN stavka_racun AS sr ON sr.id_artikl = a.id;

-- Prikaži najučestalijeg kupca (kupac koji ima najviše računa)
SELECT k.* , count(r.id) AS kolko_racuna
FROM kupac AS k
LEFT OUTER JOIN racun AS r ON r.id_kupac=k.id
GROUP BY k.id
LIMIT 1;

-- Prikazi sve zaposlenike koji su napravili barem 2 racuna
SELECT k.* , count(r.id) AS kolko_racuna
FROM zaposlenik AS k
LEFT OUTER JOIN racun AS r ON r.id_zaposlenik=k.id
GROUP BY k.id
HAVING kolko_racuna >= 2;


-- 1. ) Dodaj ograničenje koje će osigurati da ime kupca sadržava manji ili jednak broj slova od prezimena
-- CHECK (LENGTH(ime)<= LENGTH(prezime));

-- 2. Prikaži sve račune koji su izdani u 2020. godini
 SELECT*
    FROM racun
    WHERE EXTRACT(YEAR FROM datum_izdavanja) = '2020';

-- 3. Prikaži sve zaposlenike koji nisu izdali niti jedan račun
CREATE VIEW zasposlenici AS 
SELECT zaposlenik.id, zaposlenik.ime, zaposlenik.prezime, racun.id AS id_racun
    FROM zaposlenik
LEFT JOIN racun
ON racun.id_zaposlenik=zaposlenik.id;
select*
    from zasposlenici;

SELECT id, ime, prezime
    FROM zasposlenici
    WHERE id_racun IS NULL;

-- 5. prikazi racun sa najvecim iznosom
CREATE VIEW pogled AS
SELECT stavka_racun.id, stavka_racun.id_artikl, stavka_racun.id_racun, stavka_racun.kolicina, artikl.naziv, artikl.cijena
    FROM stavka_racun, artikl
    WHERE stavka_racun.id_artikl=artikl.id;

CREATE VIEW pogled2 AS
SELECT id_racun, kolicina*cijena AS ukupno
    FROM pogled; 

CREATE VIEW pogled3 AS
SELECT id_racun, SUM(ukupno) AS suma
    FROM pogled2
    GROUP BY id_racun;
    
SELECT id_racun,MAX(suma)
    FROM pogled3;


-- B----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. (1) Prikaži sve zaposlenike koji su zaposleni u posljednjih godinu dana
select *
    from zaposlenik
    where datum_zaposlenja> (NOW()- INTERVAL 1 year);
-- 3. (1) Prikaži sve artikle koji su barem jednom prodani (barem jednom dodani na stavku računa)
SELECT *
    FROM artikl, stavka_racun
    WHERE artikl.id=stavka_racun.id_artikl
     GROUP BY artikl.id;


-- DDLs ------------------------------------------------------------------------------------------------------------------------------------------------------
-- Dodaj ograničenje koje će osigurati da je naziv artikla jedinstven
ALTER TABLE artikl
	ADD CONSTRAINT uniime UNIQUE (naziv);

-- Dodaj ograničenje koje će zabranit unos zaposlenika kojemu je ime isto kao i prezime (npr. unos zaposlenika sa imenom i prezimenom 'Teo Teo' će rezultirati greškom)
ALTER TABLE zaposlenik
	ADD CONSTRAINT imeiprezimene CHECK(ime != PREZIME);


