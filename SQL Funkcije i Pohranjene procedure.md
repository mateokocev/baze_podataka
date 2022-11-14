<h1 align="center"> SQL FUNKCIJE I POHRANJENE PROCEDURE </h1>



### KORIŠTENA BAZA PODATAKA ###

```mysql
DROP DATABASE IF EXISTS trgovina;

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
 cijena NUMERIC(10,2) NOT NULL,
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

INSERT INTO kupac VALUES 
 (1, 'Lea', 'Fabris'),
 (2, 'David', 'Sirotić'),
 (3, 'Tea', 'Bibić');
INSERT INTO zaposlenik VALUES
 (11, 'Marko', 'Marić', '123451', STR_TO_DATE('01.10.2020.', '%d.%m.%Y.')),
 (12, 'Toni', 'Milovan', '123452', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.')),
 (13, 'Tea', 'Marić', '123453', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.'));
INSERT INTO artikl VALUES 
 (21, 'Puding', 5.99),
 (22, 'Milka čokolada', 30.00),
 (23, 'Čips', 9);
INSERT INTO racun VALUES
 (31, 11, 1, '00001', STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
 (32, 12, 2, '00002', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.')),
 (33, 12, 1, '00003', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.'));
INSERT INTO stavka_racun VALUES
 (41, 31, 21, 2),
 (42, 31, 22, 5),
 (43, 32, 22, 1),
 (44, 32, 23, 1);
```



### FUNKCIJE ###



##### SINTAKSA #####

Primjer:

```mysql
DELIMITER //
CREATE FUNCTION demo() RETURNS VARCHAR(20)
	DETERMINISTIC
	BEGIN
		RETURN "It Works";                   -- samo neki kod
	END //
DELIMITER ;
```



CREATE FUNCTION demo() - komanda za stvaranje funkcije te ime funkcije (demo())

RETURNS VARCHAR(20) - Vrsta podatka koja će funkcija vračati

DETERMINISTIC - ključna riječ koju SQL zahtjeva te određuje da funkcije uvijek daju isti izlaz svaki put kada se pozovu s fiksnim skupom ulaznih vrijednosti i s obzirom na isti uvjet baze podataka, to jest ne manipulira podatke aka. fiksni izlaz za fiksne ulaze.

BEGIN i END - služe kao {} u C++-u te definiraju početak i kraj bloka koda

DELIMITER - označava SQL-u gdje se nalazi funkcija/procedura a ne neki SQL kod. Početak i kraj se označavaju sa kosom crtom / slashem ( / ). Delimiter je obavezno dodati na početak i na kraj sa ( ; ) na kraju



##### POZIV FUNKCIJE #####

Primjer:

```mysql
SELECT demo() FROM DUAL;
```

Neznam treba li išta objasniti ovdje.



##### BRISANJE FUNKCIJE #####

Primjer:

```mysql
DROP FUNCTION demo();
```



#### PRIMJERI FUNKCIJA ####



###### ZBRAJANJE 2 BROJA ######

```mysql
DELIMITER //
CREATE FUNCTION zbroji(a INTEGER, b INTEGER) RETURNS INTEGER
	DETERMINISTIC
	BEGIN
		DECLARE rezultat INTEGER DEFAULT 0;
		SET rezultat = a + b;
		
		RETURN rezultat;
	END //
DELIMITER ;

SELECT zbroji(5,1) FROM DUAL;
```

DECLARE - obavezno za deklariranje varijabla ( DECLARE imevarijable TIP_PODATKA; )

SET - obavezno kada dajemo vrijednost nekoj varijabli inače neće raditi

DEFAULT - Nepotrebno! Ali korisno ako želimo da varijabla ima predefiniranu vrijednost



###### SPREMANJE REZULTATA, IZVOĐENJA UPITA U VARIJABLU ######

```mysql
DELIMITER //
CREATE FUNCTION broj_artikla() RETURNS INTEGER
	DETERMINISTIC
	BEGIN
		DECLARE br INTEGER;
			SELECT count(*) INTO br
				FROM artikl;
				
		RETURN br;
	END //
DELIMITER ;
```

Kao u prijašnjem primjeru deklariramo varijablu <i><b>br</b></i> te u nju spremamo rezultat upita sa INTO ključna riječ (**!VAŽNO!** INTO može spremiti u varijablu samo ako je jedan redak rezultat. Više retka će izbaciti GREŠKU.)



###### FUNKCIJE KOJE VRAĆAJU VIŠE VARIJABLI ######

```mysql
DELIMITER //
CREATE FUNCTION artikl_info() RETURNS VARCHAR(100)
	DETERMINISTIC
	BEGIN
		DECLARE max_cijena DECIMAL(10, 2);
		DECLARE min_cijena DECIMAL(10, 2); -- ili DECLARE avg_cijena, min_cijena, max_cijena DECIMAL(10, 2);
		DECLARE avg_cijena DECIMAL(10, 2);
		
		SELECT MAX(cijena), MIN(cijena), AVG(cijena) INTO max_cijena, min_cijena, avg_cijena
			FROM artikl;
		
		RETURN CONCAT("AVG:", avg_cijena, "MAX:", max_cijena, "MIN:", min_cijena);
	END //
DELIMITER ;
```



CONCAT() - zbraja dva ili više izraza

Primjer:

```mysql
SELECT CONCAT(ime, " ", prezime) AS kupci
FROM kupac;
```



###### FUNKCIJA KOJA ĆE ZA ODREĐENI ARTIKL IZRAČUNATI UKUPNU PRODANU KOLIČINU TE NAPRAVI UPIT KOJI KORISTI FUNKCIJU ######

```mysql
DELIMITER //
CREATE FUNCTION prodana_kolicina(p_id_artikl INTEGER) RETURNS INTEGER
    DETERMINISTIC
    BEGIN
    	DECLARE kol INTEGER;

 		SELECT SUM(kolicina) INTO kol
 		FROM stavka_racun
 		WHERE id_artikl = p_id_artikl;

 		RETURN kol;
	END//
DELIMITER ;

SELECT *, prodana_kolicina(id) AS prodana_kolicina
	FROM artikl;
```



###### UKUPAN IZNOS ODREĐENOG RAČUNA ######

```mysql
DELIMITER //
CREATE FUNCTION iznos_racuna(p_id_racun INTEGER) RETURNS DECIMAL(10,2)
    DETERMINISTIC
    BEGIN
		DECLARE iznos DECIMAL(10,2);
		
		SELECT SUM(kolicina * cijena) INTO iznos
			FROM stavka_racun
			INNER JOIN artikl ON artikl.id = stavka_racun.id_artikl
			WHERE id_racun = p_id_racun;
		
		RETURN iznos;
	END//
DELIMITER ;

SELECT *, iznos_racuna(id) AS iznos_racuna
	FROM racun;
```



#### IF ELSE ####

###### JEFTINO / SKUPO ######

```mysql
DELIMITER //
CREATE FUNCTION info_o_cijeni(p_cijena DECIMAL(10,2)) RETURNS VARCHAR(100)
    DETERMINISTIC
    BEGIN
    	DECLARE info VARCHAR(100);
    	
    	IF p_cijena <= 0 THEN
    		SET info = "Došlo je do greške";
    	
        ELSE IF p_cijena < 10 THEN
            SET info = "Jeftino";
    	
    	ELSE
    		SET info = "Skupo";
    	END IF;
    	
    	RETURN info;
    END//
DELIMITER ;

SELECT *, info_o_cijeni(cijena)
	FROM artikl;
```

**!VAŽNO!**  --  ***SVAKI IF MORA ZAVRŠITI NA END IF;***



#### WHILE I DO-WHILE ####

###### RAČUNANJE FAKTORIJELA (WHILE METODA) ######

```mysql
DELIMITER //
CREATE FUNCTION faktorijel(p_x INTEGER) RETURNS INTEGER
    DETERMINISTIC
    BEGIN
    	DECLARE rez INTEGER DEFAULT 1;
    	
    	WHILE p_x > 0 DO
    	
    	SET rez = rez * p_x
    	SET p_x = p_x - 1;
    	
    	END WHILE;
    END//
DELIMITER;

SELECT faktorijel(5) FROM DUAL;
```

Formula faktorijela - 5! = 5 * 4 * 3 * 2 * 1



###### RAČUNANJE FAKTORIJELA (DO-WHILE METODA) ######

```mysql
DELIMITER //
CREATE FUNCTION faktorijel(p_x INTEGER) RETURNS INTEGER
    DETERMINISTIC
    BEGIN
    	DECLARE rez INTEGER DEFAULT 1;
    	
    	REPEAT
    	
    	SET rez = rez * p_x
    	SET p_x = p_x - 1;
    	
    	UNTIL p_x = 0;
    	END REPEAT;
    END//
DELIMITER;

SELECT faktorijel(5) FROM DUAL;
```



#### POZIV FUNKCIJA U FUNKCIJU ####

```mysql
DELIMITER //
CREATE FUNCTION demo_faktorijel(p_x INTEGER) RETURNS VARCHAR(100)
	DETERMINISTIC
	BEGIN
		DECLARE f1 INTEGER;
		
		SET f1 = faktorijel(p_x); -- ili SELECT faktorijel(p_x) INTO f1 FROM DUAL;
		
		RETURN f1
	END //
DETERMINISTIC;
```

<br>

### PROCEDURE ###

#### SINTAKSA ####



###### POVEČAVANJE CIJENE SVIH ARTIKALA ZA VRIJEDNOST PARAMETRA ######

```mysql
DELIMITER //
CREATE PROCEDURE povecaj_cijenu(postotak DECIMAL(4,2))
	BEGIN
		UPDATE artikl
			SET cijena = cijena * (1 + postotak/100);
			
	END //
DELIMITER;

CALL povecaj_cijenu(50);
```

CREATE PROCEDURE imeprocedure() - stvaranje procedure

CALL imeprocedure() - poziv procedure



#### IN/OUT PARAMETRI ####



###### SPREMA ZBROJ VRIJEDNOSTI PARAMETARA ######

```mysql
DELIMITER //
CREATE PROCEDURE zbroji(IN a INTEGER, IN b INTEGER, OUT rezultat INTEGER)
	BEGIN
		SET rezultat a + b;
		
	END //
DELIMITER;

CALL zbroji(10, 2, @rez);
SELECT @rez;
```

VARIJABLA @rez - session variable, nije trajna i čim se prekine sešn se briše, nije ju potrebno deklarirati

IN - ulazne vrijednosti

OUT - izlazne vrijednosti



###### POVEČAJ VRIJEDNOST PARAMETRA ######

```mysql
DELIMITER //
CREATE PROCEDURE povecaj_brojac(INOUT br INTEGER)
	BEGIN
		SET br = br + 1;
		
	END //
DELIMITER;

SET @rez = 3;
CALL povecaj_brojac(@rez);
SELECT @rez;
```

INOUT - radi oboje i IN i OUT (git gud)



#### KURSORI ####



##### IMPLICITNI KURSORI #####

###### MIN I MAX CIJENA ARTIKALA U VARIJABLE ######

```mysql
DELIMITER //
CREATE PROCEDURE min_max_artikla(OUT min_cijena DECIMAL(10,2), OUT max_cijena DECIMAL(10,2))
	BEGIN
		SELECT MIN(cijena), MAX(cijena) INTO min_cijena, max_cijena
			FROM artikl;
		
		
	END //
DELIMITER;

CALL min_max_artikla(@min, @max)
SELECT @min, @max;
```

**!VAŽNO!** -- RADI SAMO KAD JE REZULTAT NA **JEDNOM RETKU** 



##### EKSPLICITNI KURSORI #####

###### MIN I MAX CIJENA ARTIKALA U VARIJABLE ######

```mysql
DELIMITER //
CREATE PROCEDURE min_max_cur(OUT min_cijena DECIMAL(10,2), OUT max_cijena DECIMAL(10,2))
	BEGIN
		DECLARE cur CURSOR FOR
			SELECT cijena, cijena
				FROM artikl;
		
		OPEN cur;
			FETCH cur INTO min_cijena, max_cijena;
		
		CLOSE cur;
		
	END //
DELIMITER;

SELECT cijena, cijena
	FROM artikl;

CALL minmax_cur(@min, @max);
CALL @min, @max;
```

OVO JE NEDOVRSENI ZADATAK I RADIT CE SE NA SLJEDECOJ NASTAVI
