-- Creazione del database

-- Creazione della tabella ANAGRAFICA
CREATE TABLE Anagrafica (
    IdAnagrafica INT IDENTITY(1,1) PRIMARY KEY,
    Cognome VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Indirizzo VARCHAR(100),
    Citta VARCHAR(50),
    CAP CHAR(5),
    Cod_Fisc CHAR(16) UNIQUE NOT NULL
);

-- Creazione della tabella TIPO VIOLAZIONE
CREATE TABLE TipoViolazione (
    IdViolazione INT IDENTITY(1,1) PRIMARY KEY,
    Descrizione VARCHAR(255) NOT NULL
);

-- Creazione della tabella VERBALE
CREATE TABLE Verbale (
    IdVerbale INT IDENTITY(1,1) PRIMARY KEY,
    IdAnagrafica INT NOT NULL,
    IdViolazione INT NOT NULL,
    DataViolazione DATE NOT NULL,
    IndirizzoViolazione VARCHAR(100) NOT NULL,
    Nominativo_Agente VARCHAR(100) NOT NULL,
    DataTrascrizioneVerbale DATE NOT NULL,
    Importo DECIMAL(10,2) NOT NULL,
    DecurtamentoPunti INT NOT NULL CHECK (DecurtamentoPunti >= 0),
    FOREIGN KEY (IdAnagrafica) REFERENCES Anagrafica(IdAnagrafica),
    FOREIGN KEY (IdViolazione) REFERENCES TipoViolazione(IdViolazione)
);

-- Inserimento dati di esempio in Anagrafica
INSERT INTO Anagrafica (Cognome, Nome, Indirizzo, Citta, CAP, Cod_Fisc) VALUES
('Rossi', 'Mario', 'Via Roma, 10', 'Palermo', '90100', 'RSSMRA80A01H501Z'),
('Bianchi', 'Luca', 'Via Milano, 15', 'Milano', '20100', 'BNCLCU75B12F205X');

-- Inserimento dati di esempio in TipoViolazione
INSERT INTO TipoViolazione (Descrizione) VALUES
('Eccesso di velocità'),
('Divieto di sosta'),
('Guida senza cintura');

-- Inserimento dati di esempio in Verbale
INSERT INTO Verbale (IdAnagrafica, IdViolazione, DataViolazione, IndirizzoViolazione, Nominativo_Agente, DataTrascrizioneVerbale, Importo, DecurtamentoPunti) VALUES
(1, 1, '2023-01-15', 'Via Libertà, 25', 'Agente Rossi', '2023-01-16', 200.50, 3),
(2, 2, '2023-02-20', 'Piazza Duomo, 5', 'Agente Bianchi', '2023-02-21', 100.00, 0);

-- Query richieste
-- 1. Conteggio dei verbali trascritti
SELECT COUNT(*) AS NumeroVerbali FROM Verbale;

-- 2. Conteggio dei verbali trascritti raggruppati per anagrafe
SELECT IdAnagrafica, COUNT(*) AS NumeroVerbali FROM Verbale GROUP BY IdAnagrafica;

-- 3. Conteggio dei verbali trascritti raggruppati per tipo di violazione
SELECT IdViolazione, COUNT(*) AS NumeroViolazioni FROM Verbale GROUP BY IdViolazione;

-- 4. Totale dei punti decurtati per ogni anagrafe
SELECT IdAnagrafica, SUM(DecurtamentoPunti) AS TotalePuntiDecurtati FROM Verbale GROUP BY IdAnagrafica;

-- 5. Dettagli verbali per anagrafici residenti a Palermo
SELECT A.Cognome, A.Nome, V.DataViolazione, V.IndirizzoViolazione, V.Importo, V.DecurtamentoPunti
FROM Verbale V
JOIN Anagrafica A ON V.IdAnagrafica = A.IdAnagrafica
WHERE A.Citta = 'Palermo';

-- 6. Verbali tra febbraio 2009 e luglio 2009
SELECT A.Cognome, A.Nome, A.Indirizzo, V.DataViolazione, V.Importo, V.DecurtamentoPunti
FROM Verbale V
JOIN Anagrafica A ON V.IdAnagrafica = A.IdAnagrafica
WHERE V.DataViolazione BETWEEN '2009-02-01' AND '2009-07-31';

-- 7. Totale importi per ogni anagrafico
SELECT IdAnagrafica, SUM(Importo) AS TotaleImporto FROM Verbale GROUP BY IdAnagrafica;

-- 8. Tutti gli anagrafici residenti a Palermo
SELECT * FROM Anagrafica WHERE Citta = 'Palermo';

-- 9. Violazioni per una certa data
SELECT DataViolazione, Importo, DecurtamentoPunti FROM Verbale WHERE DataViolazione = '2023-01-15';

-- 10. Conteggio delle violazioni per agente di polizia
SELECT Nominativo_Agente, COUNT(*) AS NumeroVerbali FROM Verbale GROUP BY Nominativo_Agente;

-- 11. Violazioni con più di 5 punti decurtati
SELECT A.Cognome, A.Nome, A.Indirizzo, V.DataViolazione, V.Importo, V.DecurtamentoPunti
FROM Verbale V
JOIN Anagrafica A ON V.IdAnagrafica = A.IdAnagrafica
WHERE V.DecurtamentoPunti > 5;

-- 12. Violazioni con importo superiore a 400 euro
SELECT A.Cognome, A.Nome, A.Indirizzo, V.DataViolazione, V.Importo, V.DecurtamentoPunti
FROM Verbale V
JOIN Anagrafica A ON V.IdAnagrafica = A.IdAnagrafica
WHERE V.Importo > 400;

GO
CREATE PROCEDURE InserisciVerbale
    @IdAnagrafica INT,
    @IdViolazione INT,
    @DataViolazione DATE,
    @IndirizzoViolazione VARCHAR(100),
    @Nominativo_Agente VARCHAR(100),
    @DataTrascrizioneVerbale DATE,
    @Importo DECIMAL(10,2),
    @DecurtamentoPunti INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Verbale (IdAnagrafica, IdViolazione, DataViolazione, IndirizzoViolazione, Nominativo_Agente, DataTrascrizioneVerbale, Importo, DecurtamentoPunti)
        VALUES (@IdAnagrafica, @IdViolazione, @DataViolazione, @IndirizzoViolazione, @Nominativo_Agente, @DataTrascrizioneVerbale, @Importo, @DecurtamentoPunti);
    END TRY
    BEGIN CATCH
        PRINT 'Errore nell''inserimento del verbale: ' + ERROR_MESSAGE();
    END CATCH
END;
GO