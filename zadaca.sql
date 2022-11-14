DROP DATABASE trgovina;
CREATE DATABASE trgovina;
USE trgovina;

CREATE TABLE kupac (
	id INTEGER NOT NULL,
	ime VARCHAR(10) NOT NULL,
	prezime VARCHAR(15) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE zaposlenik (
	id INTEGER NOT NULL,
	ime VARCHAR(10) NOT NULL,
	prezime VARCHAR(15) NOT NULL,
	oib CHAR(11) NOT NULL,
	datum_zaposlenja DATETIME NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE artikl (
	id INTEGER NOT NULL,
	naziv VARCHAR(20) NOT NULL,
	cijena NUMERIC(10,2) NOT NULL CHECK (cijena > 0),
	PRIMARY KEY (id)
);

CREATE TABLE racun (
	id INTEGER NOT NULL,
	id_zaposlenik INTEGER NOT NULL,
	id_kupac INTEGER NOT NULL,
	broj VARCHAR(100) NOT NULL,
	datum_izdavanja DATETIME NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id),
	FOREIGN KEY (id_kupac) REFERENCES kupac (id)
);

CREATE TABLE stavka_racun (
	id INTEGER NOT NULL,
	id_racun INTEGER NOT NULL,
	id_artikl INTEGER NOT NULL,
	kolicina INTEGER NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id_racun) REFERENCES racun (id) ON DELETE CASCADE,
	FOREIGN KEY (id_artikl) REFERENCES artikl (id),
	UNIQUE (id_racun, id_artikl)
);



INSERT INTO kupac VALUES (1, 'Lea', 'Fabris'),
                         (2, 'David', 'Sirotić'),
                         (3, 'Tea', 'Bibić');

INSERT INTO zaposlenik VALUES (11, 'Marko', 'Marić', '123451', STR_TO_DATE('01.10.2020.', '%d.%m.%Y.')),
							  (12, 'Toni', 'Milovan', '123452', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.')),
							  (13, 'Tea', 'Marić', '123453', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.'));

INSERT INTO artikl VALUES (21, 'Puding', 5.99),
                          (22, 'Milka čokolada', 30.00),
                          (23, 'Cips', 9);

INSERT INTO racun VALUES (31, 11, 1, '00001', STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
						 (32, 12, 2, '00002', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.')),
						 (33, 12, 1, '00003', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.'));

INSERT INTO stavka_racun VALUES (41, 31, 21, 2),
                                (42, 31, 22, 5),
                                (43, 32, 22, 1),
                                (44, 32, 23, 1);
                                

-- Napiši funkciju koja će vratiti trenutni datum u obliku sljedećeg primjera 31.10.20.

DELIMITER //
CREATE FUNCTION datum() RETURNS VARCHAR(30)
DETERMINISTIC
	BEGIN
		RETURN DATE_FORMAT(CURDATE(), '%d.%m.%y.');
	END //
DELIMITER ;

SELECT datum() FROM DUAL;
DROP function datum;


-- Napiši funkciju koja će za dva broja (definirane sa parametrima a i b) izračunati i vratiti njihov umnožak

DELIMITER //
CREATE FUNCTION umnozak(a INTEGER, b INTEGER) RETURNS INTEGER
DETERMINISTIC
	BEGIN
		RETURN a * b;
	END //
DELIMITER ;

DROP FUNCTION umnozak;
SELECT umnozak(4, 3) FROM DUAL;

-- Napiši funkciju koja će za određeni račun (definiran sa parametrom p_id_racun) vratiti 'DA' ako račun ima barem jednu stavku, u suprotnom će vratiti vrijednost 'NE'. Isprobaj funkciju na nekom računu.

DELIMITER //
CREATE FUNCTION stavka(p_id_racun INTEGER) RETURNS VARCHAR(10)
DETERMINISTIC
	BEGIN
		DECLARE rez INTEGER;
        SELECT count(id) INTO rez
			FROM stavka_racun AS sr
				WHERE p_id_racun = sr.id_racun;
        
        IF rez <=0 THEN
			RETURN 'NE';
        
        ELSE
			RETURN 'DA';
            
        END IF;
	END //
DELIMITER ;

DROP FUNCTION stavka;
SELECT stavka(33) FROM DUAL;


-- Napiši funkciju koja će za određeno ime (definiran sa parametrom p_ime) prebrojati koliko puta se ono pojavljuje u tablicama zaposlenika i kupca (npr. ime 'Tea' se pojavljuje dva puta). Zatim napiši upit koji će prikazati sve kupce zajedno sa brojem pojavljivanja imena pojedinog kupca koristeći prethodno napisanu funkciju.

DELIMITER //
CREATE FUNCTION pojime(p_ime VARCHAR(10)) RETURNS INTEGER
DETERMINISTIC
	BEGIN
		DECLARE rezk,rezz,rez INTEGER;
		SELECT count(k.ime) INTO rezk
			FROM kupac AS k
			WHERE p_ime = k.ime;
            
		SELECT count(z.ime) INTO rezz
			FROM zaposlenik AS z
			WHERE p_ime = z.ime;
		
        SET rez = rezz + rezk;
		
        RETURN rez;
	END //
DELIMITER ;

DROP FUNCTION pojime;
SELECT pojime('David') FROM DUAL;

SELECT k.ime, pojime(k.ime) AS pojavljivanja
	FROM kupac AS k;


-- Napiši proceduru koja će za dva broja (definirane sa parametrima a i b) izračunati i vratiti njihov umnožak. Primjer pozivanja procedure: CALL umnozak(10, 3, @rezultat);

DELIMITER //
CREATE PROCEDURE umnozak_proc(IN a INTEGER, IN b INTEGER, OUT rez INTEGER)
BEGIN
	SET rez = a * b;
    
END //
DELIMITER ;

CALL umnozak_proc(10, 3, @rezultat);
SELECT @rezultat FROM DUAL;


-- Napiši proceduru koja će provjeriti jesu li svi brojevi računa dužine 5 znakova ili više. Ako svi brojevi računa imaju minimalno 5 znakova će se u varijablu rezultat spremiti vrijednost 'DA', inače će se spremiti vrijednost 'NE'. Primjer pozivanja procedure: CALL provjeri_brojeve_racuna(@rezultat);

DELIMITER //
CREATE PROCEDURE provjeri_brojeve_racuna(OUT rez VARCHAR(10))
BEGIN
	DECLARE counter INTEGER;
    -- --- --- --- --- --- --
    SELECT count(id) INTO counter
		FROM racun
        WHERE LENGTH(broj) < 5;
	-- --- --- --- --- --- --
    IF counter > 0 THEN
		SET rez = "NE";
	ELSE
		SET rez = "DA";
	-- --- --- --- --- --- --
	END IF;
    
END //
DELIMITER ;

DROP PROCEDURE provjeri_brojeve_racuna;
CALL provjeri_brojeve_racuna(@rezultat);
SELECT @rezultat FROM DUAL;


-- (3) Napiši proceduru koja će u varijablu br_artikala spremiti broj artikala koji imaju cijenu nižuod određene vrijednosti (definirane parametrom p_cijena). Primjer pozivanja procedure:CALL broj_jeftinijih_artikal(10, @br_artikala); će vratiti vrijednost 2, jer su samo dva artikla jeftinija od 10

DELIMITER //
CREATE PROCEDURE broj_jeftinijih_artikal(IN p_cijena NUMERIC(10,2), OUT br INTEGER)
BEGIN
    SELECT count(id) INTO br
		FROM artikl AS a
        WHERE p_cijena > a.cijena;
        
END //
DELIMITER ;

DROP PROCEDURE broj_jeftinijih_artikal;
CALL broj_jeftinijih_artikal(10, @br_artikala);
SELECT @br_artikala FROM DUAL;


-- Napiši proceduru koja će u varijablu br_artikala spremiti broj artikala koji čiji naziv imamanji broj znakova od određene vrijednosti (definirane parametrom p_br_znakova). Primjerpozivanja procedure: CALL broj_artikala_sa_kracim_nazivom(5, @br_artikala); ćevratiti vrijednost 1, jer samo artikal sa nazivom 'Čips' ima sadrži manje od 5 znakova

DELIMITER //
CREATE PROCEDURE broj_artikala_sa_kracim_nazivom(IN p_br_znakova INTEGER, OUT br INTEGER)
BEGIN
	SELECT count(id) INTO br
		FROM artikl
			WHERE LENGTH(naziv) < p_br_znakova;
END //
DELIMITER ;

DROP PROCEDURE broj_artikala_sa_kracim_nazivom;
CALL broj_artikala_sa_kracim_nazivom(5, @br_artikala);
SELECT @br_artikala FROM DUAL;