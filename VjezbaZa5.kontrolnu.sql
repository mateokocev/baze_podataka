/*
aerodrom(id, naziv, kapacitet_aviona)
aviokompanija(id, naziv, oib)
avion(id, reg_oznaka, datum_izrade, id_aviokompanija)
let(id, id_avion, datum, id_polaziste, id_odrediste)
*/



DROP DATABASE IF EXISTS avio_aerodrom;
CREATE DATABASE avio_aerodrom;
USE avio_aerodrom;

CREATE TABLE aerodrom (
 id INTEGER PRIMARY KEY,
 naziv VARCHAR(30) UNIQUE,
 kapacitet_aviona INTEGER
);

CREATE TABLE aviokompanija (
 id INTEGER PRIMARY KEY,
 naziv VARCHAR(30),
 oib CHAR(11)
);

CREATE TABLE avion (
 id INTEGER PRIMARY KEY,
 reg_oznaka VARCHAR(10),
 datum_izrade DATETIME,
 id_aviokompanija INTEGER,
 FOREIGN KEY (id_aviokompanija) REFERENCES aviokompanija (id)
);

CREATE TABLE let (
 id INTEGER PRIMARY KEY,
 id_avion INTEGER,
 datum DATETIME,
 id_polaziste INTEGER,
 id_odrediste INTEGER,
 FOREIGN KEY (id_avion) REFERENCES avion (id),
 CHECK (id_polaziste != id_odrediste)
);



INSERT INTO aerodrom
 VALUES (1, 'Aerodrom Pula', 5),
 (2, 'Aerodrom Zagreb', 10),
 (3, 'Aerodrom Zadar', 5),
 (4, 'Aerodrom Split', 6);
 
INSERT INTO aviokompanija
 VALUES (11, 'Croatia airline', '1111111'),
 (12, 'Delta flights', '1111113'),
 (13, 'Emirates', '1111115');
INSERT INTO avion
 VALUES (21, 'A1', STR_TO_DATE('10.10.2010.', '%d.%m.%Y.'), 11),
 (22, 'A2', STR_TO_DATE('01.01.2005.', '%d.%m.%Y.'), 11),
 (23, 'A3', STR_TO_DATE('15.03.2009.', '%d.%m.%Y.'), 12),
 (24, 'A4', STR_TO_DATE('15.05.2011.', '%d.%m.%Y.'), 11);
INSERT INTO let
 VALUES (31, 21, STR_TO_DATE('15.03.2020.', '%d.%m.%Y.'), 1, 3),
 (32, 21, STR_TO_DATE('16.03.2020.', '%d.%m.%Y.'), 3, 1),
 (33, 22, STR_TO_DATE('16.03.2020.', '%d.%m.%Y.'), 2, 1),
 (34, 23, STR_TO_DATE('17.03.2020.', '%d.%m.%Y.'), 2, 3),
 (35, 21, STR_TO_DATE('18.03.2020.', '%d.%m.%Y.'), 1, 2),
 (36, 22, STR_TO_DATE('19.03.2020.', '%d.%m.%Y.'), 1, 2);
 
 
 
 
 
 
 -- Zadaci (2. dio):
 
 -- 1.
 
   SELECT *
   FROM aerodrom
   LEFT JOIN let
   ON aerodrom.id = let.id_polaziste;
 
 
 
 
 -- 2. 
 
 SELECT *, COUNT(id_avion) AS broj_letova_za_avion
 FROM let 
 RIGHT JOIN avion
 ON avion.id = let.id_avion
 GROUP BY id_avion;
 
 

 
 
 