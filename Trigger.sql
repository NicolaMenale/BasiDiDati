CREATE OR REPLACE TRIGGER MAX_INDIRIZZI
BEFORE INSERT ON INDIRIZZO
FOR EACH ROW
DECLARE
I_COUNT NUMBER :=0;
I_ERROR EXCEPTION;
BEGIN
SELECT COUNT (*) INTO I_COUNT FROM INDIRIZZO WHERE (:NEW.CODICE_FISCALE_INDIRIZZO=CODICE_FISCALE_INDIRIZZO);
IF I_COUNT = 5
THEN RAISE I_ERROR;
END IF;

EXCEPTION
WHEN I_ERROR THEN RAISE_APPLICATION_ERROR(-20010,'RAGGIUNTO IL NUMERO MASSIMO DI INDIRIZZI');
END;



CREATE OR REPLACE TRIGGER MAX_PRODOTTO
BEFORE INSERT ON CONTIENE
FOR EACH ROW
DECLARE
C_QUANTITA NUMBER :=0;
C_ERROR EXCEPTION;
BEGIN
FOR R IN
    (SELECT QUANTITA INTO C_QUANTITA FROM CONTIENE WHERE N_ACQUISTO_CONTIENE = :NEW.N_ACQUISTO_CONTIENE)
    LOOP
    IF :NEW.QUANTITA >= 10
    THEN RAISE C_ERROR;
    END IF;
    END LOOP;

EXCEPTION
WHEN C_ERROR THEN RAISE_APPLICATION_ERROR(-20011,'RAGGIUNTO IL NUMERO MASSIMO DI TIPO DI PROTTO CHE E POSSIBILE ACQUISTARE');
END;



CREATE OR REPLACE TRIGGER QUANTITA_NON_DISPONIBILE
BEFORE INSERT ON CONTIENE
FOR EACH ROW
DECLARE
C_QUANTITA NUMBER :=0;
C_ERROR EXCEPTION;
BEGIN
    SELECT QUANTITA_DISPONIBILE INTO C_QUANTITA FROM PRODOTTO WHERE ID_PRODOTTO = :NEW.ID_PRODOTTO_CONTIENE;
    IF :NEW.QUANTITA > C_QUANTITA
    THEN RAISE C_ERROR;
    END IF;

EXCEPTION
WHEN C_ERROR THEN RAISE_APPLICATION_ERROR(-20012,'QUANTITA NON DISPONIBILE');
END;



CREATE OR REPLACE TRIGGER DATA_ERRATA_SPEDIZIONE
BEFORE INSERT ON SPEDIZIONE
FOR EACH ROW
DECLARE
A_DATA_ACQUISTO DATE;
DATA_ERRATA EXCEPTION;

BEGIN
SELECT DATA_ACQUISTO INTO A_DATA_ACQUISTO FROM STATO_ACQUISTO WHERE N_ACQUISTO_STATO_ACQUISTO = :NEW.N_ACQUISTO_SPEDIZIONE;
IF (:NEW.DATA_CREAZIONE_SPEDIZIONE - A_DATA_ACQUISTO)<0 THEN
RAISE DATA_ERRATA;
END IF;

EXCEPTION
WHEN DATA_ERRATA THEN RAISE_APPLICATION_ERROR(-20013,'DATA SPEDIZIONE NON VALIDA');
END;



CREATE OR REPLACE TRIGGER MAX_METODO_DI_PAGAMENTO
BEFORE INSERT ON METODO_DI_PAGAMENTO
FOR EACH ROW
DECLARE
I_COUNT NUMBER :=0;
I_ERROR EXCEPTION;
BEGIN
SELECT COUNT (*) INTO I_COUNT FROM METODO_DI_PAGAMENTO WHERE (:NEW.CODICE_FISCALE_MDP=CODICE_FISCALE_MDP);
IF I_COUNT = 5
THEN RAISE I_ERROR;
END IF;

EXCEPTION
WHEN I_ERROR THEN RAISE_APPLICATION_ERROR(-20014,'RAGGIUNTO IL NUMERO MASSIMO DI METODI DI PAGAMENTO');
END;



CREATE OR REPLACE TRIGGER AGGIORNAMENTO_QUANTITA
AFTER INSERT ON contiene
FOR EACH ROW
DECLARE
    C_ACQUISTO NUMBER := :NEW.N_ACQUISTO_CONTIENE;
    C_QUANTITA NUMBER := :NEW.QUANTITA;
BEGIN
    UPDATE PRODOTTO
    SET QUANTITA_DISPONIBILE_PRODOTTO = QUANTITA_DISPONIBILE_PRODOTTO - C_QUANTITA
    WHERE ID_PRODOTTO = :NEW.ID_PRODOTTO_CONTIENE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20015, 'Acquisto non valido.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20016, 'Errore durante l''aggiornamento della quantità.');
END;