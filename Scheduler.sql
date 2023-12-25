BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'SCADENZA_ABBONAMENTO',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          FOR R IN (SELECT DISTINCT CLIENTE.CODICE_FISCALE
                                    FROM CLIENTE
                                    JOIN POSSIEDE ON CLIENTE.CODICE_FISCALE = POSSIEDE.CODICE_FISCALE_POSSIEDE
                                    JOIN ABBONAMENTO ON POSSIEDE.CODICE_ABBONAMENTO_POSSIEDE = ABBONAMENTO.CODICE_ABBONAMENTO
                                    WHERE ABBONAMENTO.DATA_FINE_ABBONAMENTO <= SYSDATE)
                          LOOP
                            DECLARE
                              abbonamenti_attivi NUMBER;
                            BEGIN
                              SELECT COUNT(*) INTO abbonamenti_attivi
                              FROM POSSIEDE
                              JOIN ABBONAMENTO ON POSSIEDE.CODICE_ABBONAMENTO_POSSIEDE = ABBONAMENTO.CODICE_ABBONAMENTO
                              WHERE POSSIEDE.CODICE_FISCALE_POSSIEDE = R.CODICE_FISCALE
                                    AND ABBONAMENTO.DATA_FINE_ABBONAMENTO > SYSDATE;

                              IF abbonamenti_attivi = 0 THEN
                                UPDATE CLIENTE
                                SET ABBONAMENTO = 0
                                WHERE CODICE_FISCALE = R.CODICE_FISCALE;
                              END IF;
                            END;
                          END LOOP;
                        END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MONTHLY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE);
END;
