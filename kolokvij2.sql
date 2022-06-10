

-- 1. (3) kreiraj bazu podataka i tablice na osnovu zadanih relacija, te dodaj podatke (dane na sljedećoj stranici)
-- u pripadne tablice




-- 2. dodaj sljedeća ograničenja:
--    a) (1) trajanje studija mora biti u rasponu od 1 do 5 godina (tj. [1, 5])
--    b) (1) naziv studija mora biti jedinstven
-- 3. (1) prikaži sve studente sa dodatnim stupcem koji će prikazivati njihova imena sa velikim slovima (rezultat:
-- id, ime, prezime, godina_rodenja, ime_velika_slova)
-- 4. (1) prikaži imena studenata koja se pojavljuju i kao imena nastavnika (rezultat: ime)

-- kolegij (rezultat: id, ime, prezime, godina_rodenja, broj_upisanih_kolegija)
-- 7. (3) prikaži kolegij koji ima najviše upisanih studenata (hint: to je kolegij 'Programiranje') (rezultat: id, naziv,
-- semestar_izvodenja, sati_nastave)



CREATE DATABASE UPIS_KOLEGIJA;
DROP DATABASE UPIS_KOLEGIJA;

USE UPIS_KOLEGIJA;

CREATE TABLE student (
id INTEGER PRIMARY KEY,
ime VARCHAR(20),
prezime VARCHAR(20),
godina_rodenja INTEGER

);

CREATE TABLE nastavnik (
id INTEGER PRIMARY KEY,
ime VARCHAR(20),
prezime VARCHAR(20)

);

CREATE TABLE studij (
id INTEGER PRIMARY KEY,
naziv VARCHAR(50) unique,
trajanje SMALLINT,
CHECK(trajanje > 0 AND trajanje < 6)
);


CREATE TABLE kolegij (
id INTEGER PRIMARY KEY,
id_studij INTEGER,
id_nastavnik INTEGER,
naziv VARCHAR(20),
semestar_izvodenja SMALLINT,
sati_nastave INTEGER

);

CREATE TABLE  upisao (
id INTEGER PRIMARY KEY,
id_student INTEGER,
id_kolegij INTEGER,
datum DATE

); 

INSERT INTO student VALUES 
(1, 'Marina', 'Rović', 1997),
(2, 'Mateo', 'Boban', 1999),
(3, 'Tea', 'Matić', 2000)
;

INSERT INTO nastavnik VALUES 
(11, 'Marko', 'Marić'),
 (12, 'Tea', 'Bilić'),
 (13, 'Mirko', 'Marić')
;

INSERT INTO studij VALUES
( 21, 'Preddiplomski studij informatike', 3),
(22, 'Diplomski studij informatike', 2),
( 23, 'Preddiplomski studij računarstva', 3);


INSERT INTO kolegij VALUES
(31, 23, 11, 'Programiranje', 1, 30),
( 32, 21, 12, 'Baze podataka 1', 2, 30),
(33, 21, 12, 'Baze podataka 2', 3, 30);


INSERT INTO upisao VALUES
(41, 1, 31, '10.09.2017.'),
(42, 1, 32, '10.09.2018.'),
(43, 1, 33, '10.09.2019.'),
(44, 2, 31, '10.09.2018.'),
 (45, 2, 31, '10.09.2019.');

INSERT INTO upisao VALUES
 (41, 1, 31, STR_TO_DATE('10.09.2017.', "%d.%m.%Y.")),
 (42, 1, 32,STR_TO_DATE('10.09.2018.', "%d.%m.%Y.")),
 (43, 1, 33, STR_TO_DATE('10.09.2019.', "%d.%m.%Y.")),
 (44, 2, 31, STR_TO_DATE('10.09.2018.', "%d.%m.%Y.")),
  (45, 2, 31, STR_TO_DATE('10.09.2019.', "%d.%m.%Y."))	;
  
  SELECT UPPER(ime) AS   ime_velika_slova
  FROM student ;
	
 SELECT s.ime
 FROM student as s, nastavnik as n
 GROUP BY s.ime=n.ime;
 
 
 -- 5. (2) izmjeni prezime u 'programer' nastavnika koji je nositelj kolegija sa nazivom 'Programiranje'
UPDATE nastavnik as n, kolegij as k 
SET prezime='programer'
where k.id_nastavnik = n.id and  k.naziv = 'programiranje';


 
 -- 6. (2) prikaži sve studente i broj kolegija koje su upisali, pritom prikazati i studente koji nisu upisali niti jedan
SELECT count(u.id_student) as broj_kolegija, ime
FROM student as s
left join upisao as u on  s.id=u.id_student 
group by u.id_student
;

-- 7. (3) prikaži kolegij koji ima najviše upisanih studenata (hint: to je kolegij 'Programiranje') (rezultat: id, naziv,
-- semestar_izvodenja, sati_nastave)
select student.id,ko.naziv, ko.semestar_izvodenja, ko.sati_nastave, max(up.id_kolegij)
from student
inner join upisao as up on up.id_student = student.id 
	 inner join kolegij as ko  on ko.id=up.id_kolegij

;
