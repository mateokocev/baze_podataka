```mysql
# 1. Napiši okidač koji će pretvoriti ime kupca u velika slova samo ako su sva slova mala, 
#	 npr. ime Teo neće pretvarati jer je barem jedno slovo veliko, dok će ime teo pretvoriti u velika slova (TEO) jer su sva slova malena. 
#	 Dovoljno je napisati samo jedan okidač po želji (kod unosa ili kod izmjene). 
# 	 Napomena: ako se želi napraviti usporedba dvaju izraza bez da se ignoriraju velika i mala slova je potrebno koristiti naredbu BINARY

DELIMITER //
CREATE TRIGGER bi_kupac
BEFORE INSERT ON kupac
    FOR EACH ROW
BEGIN	
	IF BINARY new.ime = LOWER(new.ime) THEN
		SET new.ime = UPPER(new.ime);
    END IF;
END//
DELIMITER ;

INSERT INTO kupac VALUES (4, 'Ivan', 'Horvat');
INSERT INTO kupac VALUES (5, 'ivan', 'Horvat');
SELECT * FROM kupac;

-- ---------------------------------------------------

DELIMITER //
CREATE TRIGGER lowertoupper
	BEFORE INSERT ON kupac
	FOR EACH ROW
BEGIN
	IF (BINARY new.ime <> BINARY LOWER(new.ime)) = 0 THEN
		SET new.ime = UPPER(new.ime);
    END IF;
END //
DELIMITER ;
DROP TRIGGER lowertoupper;

INSERT INTO kupac VALUES (12, 'Tomasso', 'Rockerson');
SELECT * FROM kupac;



# 2. Napiši okidač koji će zabraniti brisanje artikla ako je barem jednom dodan na stavke računa (ista funkcionalnost koju i Foreign Key osigurava). 
#	 Greška će ispisati poruku 'Ne možeš brisati artikl koji je barem jednom izdan na računu!'.

DELIMITER //
CREATE TRIGGER bd_artikl
    BEFORE DELETE ON artikl
    FOR EACH ROW
BEGIN
	DECLARE l_br_stavaka INTEGER;
    
	SELECT COUNT(*) INTO l_br_stavaka
		FROM stavka_racun
        WHERE id_artikl = old.id;
    
	IF l_br_stavaka > 0 THEN
		SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Ne možeš brisati artikl koji je barem jednom izdan na računu!';
	END IF;
END//
DELIMITER ;

-- Želimo obrisati artikl 'Puding' (id=21)
SELECT * FROM artikl;
SELECT * FROM stavka_racun; -- 'Puding' se nalazi na stavkama (u stupcu id_artikl postoji id 22)
DELETE FROM artikl WHERE id = 21; -- Ne smijemo moći obrisati

INSERT INTO artikl VALUES (24, 'Kruh', 7.00);
DELETE FROM artikl WHERE id = 24; -- Ovo možemo normalno brisati jer se id=24 ne pojavljuje u tablici stavka_racun



# 3. Napiši okidač koji će zabraniti izmjenu 'naziva' artikla koji je izdan na računima u sveukupnoj količini većoj od 4.  
# 	 Npr. ne možemo izmijeniti naziv artikla 'Milka čokolada' jer je na računima izdan u sveukupnoj količini od 6, dok je sve ostale atribute artikla moguće mijenjati.

DELIMITER //
CREATE TRIGGER bu_artikl
    BEFORE UPDATE ON artikl
    FOR EACH ROW
BEGIN
	DECLARE l_kolicina INTEGER;
    
	SELECT SUM(kolicina) INTO l_kolicina
		FROM stavka_racun
        WHERE id_artikl = old.id;
    
	IF l_kolicina > 4 AND old.naziv != new.naziv THEN
		SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = 'Ne možeš mijenjati naziv artikla koji je izdan u sveukupnoj količini većoj od 4!';
	END IF;
END//
DELIMITER ;

-- Ne možemo izmjeniti naziv artikla 'Milka čokolada'
UPDATE artikl
	SET naziv = 'M. čokolada'
    WHERE naziv = 'Milka čokolada';

-- Ali smijemo izmjeniti npr. cijenu artikla 'Milka čokolada'
UPDATE artikl
	SET cijena = 32
    WHERE naziv = 'Milka čokolada';


-- Možemo normalno izmjeniti naziv artikla 'Čips'
UPDATE artikl
	SET naziv = 'Č.'
    WHERE naziv = 'Čips';
```

