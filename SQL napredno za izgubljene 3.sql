CREATE DATABASE fiputube;

USE fiputube;

CREATE TABLE korisnik (
    id INTEGER PRIMARY KEY,
    email VARCHAR(40),
    ime VARCHAR(15),
    prezime VARCHAR(20)
);

CREATE TABLE video (
    id INTEGER PRIMARY KEY,
    naslov VARCHAR(40),
    broj_pregleda INTEGER,
    video_sadrzaj VARCHAR(20)
);

CREATE TABLE komentar (
    id INTEGER PRIMARY KEY,
    id_video INTEGER,
    id_korisnik INTEGER,
    datum DATETIME,
    sadrzaj VARCHAR(50),
    id_nad_komentar INTEGER
);

INSERT INTO korisnik VALUES (1, 'marko.maric@email.hr', 'Marko', 'Marić'),
			    (2, 'toni.milovan@email.hr', 'Toni', 'Milovan'),
			    (3, 'ime.prezime@email.hr', 'Ime', 'Prezime'),
			    (4, 'ime2.prezime@email.hr', 'Ime2', 'Prezime');
                            
INSERT INTO video VALUES (11, 'Formula 1 Australian Grand Prix', 500, 'video1'),
			 (12, 'Learn Relational Algebra: Part II', 30, 'video2'),
			 (13, '*** Music Video', 250, 'video3'),
			 (14, 'Prezentacija projekta BP1', 0, 'video4');
                         
INSERT INTO komentar VALUES (21, 11, 1, STR_TO_DATE('02.01.2020.', '%d.%m.%Y.'), 'First!', NULL),
			    (22, 11, 1, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'I was first, just saying', NULL),
			    (23, 11, 3, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'What happened at 02:00?', NULL),
			    (24, 12, 1, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'What does "sigma" actually do?', NULL),
			    (25, 12, 2, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'This video was very helpful. Thanks!', NULL),
			    (26, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'It filter tuples based on the specific condition', 24),
			    (27, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'Basically, it is just a filter', 24),
			    (28, 13, 1, STR_TO_DATE('09.01.2020.', '%d.%m.%Y.'), 'She sings amazing.', NULL);


-- prikaži sve komentare zajedno sa korisnikom koji ga je objavio i video za koji je objavljen

SELECT kom.*, kor.*, vid.*
	FROM komentar AS kom, korisnik AS kor, video AS vid
    WHERE (kom.id_korisnik = kor.id) AND (kom.id_video = vid.id);

-- prikaži sve korisnike i komentare koje su objavili, uključujući korisnike koji nisu objavili niti jedan komentar

SELECT kor.*, kom.*
	FROM korisnik AS kor
    LEFT OUTER JOIN komentar AS kom ON (kor.id = kom.id_korisnik);

-- prikaži sve video zapise sa brojem komentara (uključujući podkomentare)

SELECT vid.*, COUNT(kom.id) AS broj_komentara
	FROM video AS vid
    INNER JOIN komentar AS kom ON (vid.id = kom.id_video)
    GROUP BY vid.id, vid.naslov, vid.broj_pregleda, vid.video_sadrzaj;

-- prikaži sve komentare i broj podkomentara (NESPOSOBAN SAM)

-- prikaži sve korisnike koji su objavili barem jedan komentar na datum '07.01.2020.'

SELECT kor.* 
	FROM korisnik AS kor
    INNER JOIN komentar AS kom ON (kor.id = kom.id_korisnik)
    GROUP BY kor.id, kor.email, kor.ime, kor.prezime
    HAVING COUNT(datum = '07.01.2020.') > 0
    ORDER BY kor.id ASC;

-- prikaži sve video zapise sa dodatna dva stupca: broj komentara ( uključujući podkomentare), broj podkomentara (NESPOSOBAN SAM)

