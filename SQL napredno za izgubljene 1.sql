CREATE DATABASE polog_novca;

USE polog_novca;

CREATE TABLE zaposlenik (
	id_zap INTEGER PRIMARY KEY,
	ime VARCHAR(30),
	prezime VARCHAR(30),
	datum_zaposlenja VARCHAR(30)
);

CREATE TABLE gradanin (
	id_grad INTEGER PRIMARY KEY,
    ime VARCHAR(30),
    prezime VARCHAR(30),
    oib INTEGER,
    id_zaposlenik INTEGER,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id_zap)
);

CREATE TABLE stednja (
	id_sted INTEGER PRIMARY KEY,
    id_gradanin INTEGER,
    broj_racuna VARCHAR(4),
    stanje INTEGER,
    kamatna_stopa NUMERIC(2,1),
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id_grad)
);

CREATE TABLE tekuci (
	id_tek INTEGER PRIMARY KEY,
    id_gradanin INTEGER,
    broj_racuna VARCHAR(4),
    stanje INTEGER,
    iznos_prekoracenja INTEGER,
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id_grad)
);


INSERT INTO zaposlenik VALUES (1, 'Marina', 'Rović', '10.01.2020.'),
                              (2, 'Teo', 'Zović', '11.01.2020.'),
                              (3, 'Mauro', 'Matić', '12.01.2020.');

INSERT INTO gradanin VALUES (11, 'Teo', 'Zović', 1313233, 1),
							(12, 'Ana', 'Babić', 1321133, 1),
                            (13, 'Linda', 'Horvat', 1321112, 2);

INSERT INTO stednja VALUES (21, 11, '0001', 10000, 3.0),
						   (22, 11, '0002', 3000, 2.5),
                           (23, 12, '0003', 15000, 4.0);

INSERT INTO tekuci VALUES (31, 11, '0011', 1000, 2000),
						  (32, 12, '0012', 4000, 3000),
                          (33, 12, '0013', 25000, 3000),
                          (34, 13, '0014', 100, 3000);

-- prikaži sve zaposlenike sortirane prema prezimenu silazno i imenu ulazno

SELECT *
	FROM zaposlenik
    ORDER BY prezime DESC, ime ASC;

-- prikaži sva imena građana koja se pojavljuju kao imena zaposlenika

SELECT gr.ime
	FROM gradanin AS gr, zaposlenik AS zp
    WHERE gr.ime = zp.ime;

-- prikaži prezimena građana koja se ne pojavljuju kao prezimena zaposlenika

SELECT prezime
	FROM gradanin
    WHERE ime NOT IN
		(SELECT ime
			FROM zaposlenik);

-- OR --

SELECT prezime
	FROM gradanin
    WHERE NOT EXISTS
		(SELECT *
			FROM zaposlenik
            WHERE gradanin.ime = zaposlenik.ime);

-- prikaži najveći iznos stanja na nekom tekućem računu

SELECT MAX(stanje) AS najveci_iznos
	FROM tekuci;

-- prikaži građana koji je vlasnik štednje sa najmanjim iznosom stanja

SELECT gradanin.*, MIN(stanje) AS min_stednja
	FROM stednja, gradanin;

-- OR --

SELECT g.*
	FROM gradanin AS g, stednja AS s
    WHERE g.id_grad = s.id_gradanin
    ORDER BY s.stanje
    LIMIT 1;

-- prikaži sve tekuće račune građana sa imenom 'Ana'

SELECT t.*
	FROM tekuci AS t, gradanin AS g
    WHERE g.id_grad = t.id_gradanin AND g.ime = 'Ana';

-- prikaži sve zaposlenike sa brojem građana kojima su oni osobni bankari

SELECT z.*, count(id_grad) AS klijenti
	FROM gradanin AS g
    RIGHT OUTER JOIN zaposlenik AS z ON (g.id_zaposlenik = z.id_zap) -- korišten je right outer join umjesto inner join jer inner join nece prikazati bankara sa nula klijenta
    GROUP BY z.id_zap, z.ime, z.prezime, z.datum_zaposlenja;

-- prikaži građane koji imaju samo jedan tekući račun

SELECT g.*
	FROM gradanin AS g
    INNER JOIN tekuci AS t ON (t.id_gradanin = g.id_grad)
    GROUP BY g.id_grad, g.ime, g.prezime, g.oib, g.id_zaposlenik
    HAVING count(t.id_gradanin) = 1;

-- prikaži sve građane sa dodatnim stupcem koji prikazuje ukupan iznos stanja na njihovim tekućim računima

SELECT g.*, sum(t.stanje) AS totalni_iznos
	FROM gradanin AS g
    INNER JOIN tekuci AS t ON (t.id_gradanin = g.id_grad)
    GROUP BY g.id_grad, g.ime, g.prezime, g.oib, g.id_zaposlenik;
    