CREATE OR REPLACE PROCEDURE VENDITE_PRODOTTI 
IS
v_count NUMBER;
BEGIN
    FOR R IN (SELECT ID_PRODOTTO, NOME_PRODOTTO FROM PRODOTTO)
    LOOP
            SELECT COUNT(*) INTO v_count
            FROM CONTIENE
            WHERE ID_PRODOTTO_CONTIENE = R.ID_PRODOTTO;
            DBMS_OUTPUT.PUT_LINE('Il prodotto ' || R.NOME_PRODOTTO || ' è stato venduto ' || v_count || ' volte.');
    END LOOP;
END;


CREATE OR REPLACE PROCEDURE TOTALE_ACQUISTO (C_CODICE_FISCALE CHAR, N_N_ACQUISTO NUMBER)
IS 
TOT NUMBER := 0;
TOTALESPESA INTEGER :=0;
BEGIN
SELECT SUM(QUANTITA * PREZZO_PRODOTTO) INTO TOT
FROM CLIENTE 
     JOIN ACQUISTO ON CLIENTE.CODICE_FISCALE = ACQUISTO.CODICE_FISCALE_ACQUISTO  
     JOIN CONTIENE ON ACQUISTO.N_ACQUISTO = CONTIENE.N_ACQUISTO_CONTIENE 
     JOIN PRODOTTO ON ID_PRODOTTO_CONTIENE = PRODOTTO.ID_PRODOTTO
WHERE CLIENTE.CODICE_FISCALE=C_CODICE_FISCALE AND ACQUISTO.N_ACQUISTO=N_N_ACQUISTO;
DBMS_OUTPUT.PUT_LINE('Il totale dell''acquisto ' || N_N_ACQUISTO || ' è: ' || TOT);
END;


CREATE OR REPLACE PROCEDURE INSERIMENTO_INDIRIZZO(
I_ID_INDIRIZZO NUMBER,
I_CODICE_FISCALE_INDIRIZZO CHAR,
I_QUALIFICATORE VARCHAR2,
I_STRADA VARCHAR2,
I_NUMERO VARCHAR2,
I_CITTA VARCHAR2,
I_PROVINCIA VARCHAR2,
I_CAP VARCHAR2,
I_STATO_EUROPEO CHAR)  
IS  
BEGIN  
INSERT INTO INDIRIZZO (ID_INDIRIZZO, QUALIFICATORE, STRADA, NUMERO, CITTA, PROVINCIA, CAP, STATO_EUROPEO, CODICE_FISCALE_INDIRIZZO)  
VALUES (I_ID_INDIRIZZO, I_QUALIFICATORE, I_STRADA, I_NUMERO, I_CITTA, I_PROVINCIA, I_CAP, I_STATO_EUROPEO, I_CODICE_FISCALE_INDIRIZZO);
COMMIT;  
END;


CREATE OR REPLACE PROCEDURE CANCELLAZIONE_ACQUISTO(
C_CODICE_FISCALE CHAR,
N_N_ACQUISTO NUMBER,
N_N_SPEDIZIONE NUMBER)
IS
NUM_ACQ   NUMBER;
BEGIN
FOR R IN(
SELECT N_ACQUISTO 	INTO  NUM_ACQ
			FROM ACQUISTO JOIN SPEDIZIONE ON ACQUISTO.N_ACQUISTO = SPEDIZIONE.N_ACQUISTO_SPEDIZIONE
			WHERE ACQUISTO.CODICE_FISCALE_ACQUISTO = C_CODICE_FISCALE
			AND ACQUISTO.N_ACQUISTO = N_N_ACQUISTO
            AND SPEDIZIONE.N_SPEDIZIONE = N_N_SPEDIZIONE)
LOOP
UPDATE STATO_ACQUISTO
SET STATO_ACQUISTO = 'CANCELLATO'
WHERE N_ACQUISTO_STATO_ACQUISTO = N_N_ACQUISTO;

UPDATE STATO_SPEDIZIONE
SET STATO_SPEDIZIONE = 'CANCELLATO'
WHERE N_SPEDIZIONE_STATO_SPEDIZIONE = N_N_SPEDIZIONE 
      AND STATO_SPEDIZIONE='IN ELABORAZIONE' 
      OR STATO_SPEDIZIONE='IN ATTESA' 
      OR STATO_SPEDIZIONE='PRONTO PER LA SPEDIZIONE';
END LOOP;
END;
