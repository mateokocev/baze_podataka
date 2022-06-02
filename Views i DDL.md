<h1 align="center"><bold>VIEWS & DDLs </b></h1>



### DDLs A.K.A. ograničenja ###



- **NOT NULL**: Spriječava da podaci u atributu budu NULL;

Primjer:

```sql
CREATE TABLE korisnik (
	id INTEGER PRIMARY KEY NOT NULL,
    naslov VARCHAR(40) NOT NULL,
    broj_pregleda INTEGER NOT NULL
);
```





- **UNIQUE**: Spriječava duplikate podataka u tablici, podatak je jednistven i može postojati samo jedna inačica istog podatka

Primjer:

```sql
CREATE TABLE korisnik (
	id INTEGER PRIMARY KEY NOT NULL,
    naslov VARCHAR(40) NOT NULL,
    broj_pregleda INTEGER NOT NULL,
    email VARCHAR(40) NOT NULL UNIQUE
);
```

ILI

```sql
CREATE TABLE korisnik (
	id INTEGER PRIMARY KEY NOT NULL,
    naslov VARCHAR(40) NOT NULL,
    broj_pregleda INTEGER NOT NULL,
    email VARCHAR(40) NOT NULL ,
    UNIQUE(email)
);
```

UNIQUE nam je koristan ako želimo primjerice limitirati količinu komentara koji korisnik može ubaciti video, s time da foreign key u tablici komentar pretvorimo u unique





- **CHECK**: Koristi se za postavljanje limitacija na unesene podatke (*i.e.* Broj pregleda na videu nesmije biti manji od 0).

Primjer:

```sql
CREATE TABLE video (
	id INTEGER PRIMARY KEY NOT NULL,
    naslov VARCHAR(40) NOT NULL,
    broj_pregleda INTEGER NOT NULL,
    video_sadrzaj VARCHAR(20) NOT NULL,
    CHECK (broj_pregleda > -1)
);
```





- **DEFAULT**: Postavlja vrijednost atributa na predefiniranu vrijednost ako nije unesena ručno.

Primjer:

```sql
CREATE TABLE video (
	id INTEGER PRIMARY KEY NOT NULL,
    naslov VARCHAR(40) NOT NULL,
    broj_pregleda INTEGER DEFAULT 0,
    video_sadrzaj VARCHAR(20) NOT NULL,
    CHECK (broj_pregleda > -1)
);
```





- **FOREIGN KEY**: Koristi se za identificiranje stranog kljuća u tablici.

Primjer:

```sql
CREATE TABLE komentar (
	id INTEGER PRIMARY KEY,
    id_video INTEGER NOT NULL,
    id_korisnik INTEGER NOT NULL,
    datum DATETIME NOT NULL,
    sadrzaj VARCHAR(50) NOT NULL,
    UNIQUE (id_video, id_korisnik),
    FOREIGN KEY (id_video) REFERENCES video(id),
    FOREIGN KEY (id_korisnik) REFERENCES korisnik(id)
);
```

U slućaju da brišemo podatke vezane za sve korisnike kojima je ime Marko, sadržaj svih podataka u ostalim tablicama vezani za primarni ključ marka bi se izbrisali





### Views A.K.A. pogledi ###

Primjeri:



1. Pogled koji prikazuje građane i njihovo ukupno stanje na tekućim računima sa nazivom 'gradanin_tekuci'

```sql
CREATE VIEW gradanin_tekuci AS
	SELECT g.*, SUM(stanje) AS ukupno_stanje
		FROM gradanin AS g, tekuci AS t
		WHERE g.id = t.id_gradanin
		GROUP BY g.id;
```



2.