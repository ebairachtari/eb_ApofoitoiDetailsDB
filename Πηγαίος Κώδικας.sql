-- Δημιουργία της βάσης δεδομένων
	CREATE DATABASE eb_apofoitoidetails

/* Δημιουργία πινάκων */

-- Ανεξάρτητοι πίνακες που δεν έχουν Foreign Keys και λειτουργούν ως βασικοί πίνακες
-- Απόφοιτοι
	CREATE TABLE 
		Apofoitoi 
		(
			am NVARCHAR(12) PRIMARY KEY,
			onoma NVARCHAR(50) NOT NULL,
			eponimo NVARCHAR(50) NOT NULL,
			patrwnimo NVARCHAR(50) NOT NULL,
			email NVARCHAR(50) NOT NULL UNIQUE,
			CONSTRAINT CHK_Email_Format CHECK (email LIKE '%_@_%._%'),
			tilefono NVARCHAR(10) NOT NULL UNIQUE,
			dategennisis DATE NOT NULL,
			CHECK (DATEDIFF(YEAR, dategennisis, GETDATE()) >= 18)
		)
	
-- Τύπος προγράμματος 
	CREATE TABLE 
		TiposProgrammatos 
		(
			tiposprogrammatosID INT PRIMARY KEY IDENTITY(1,1),
			tiposprogrammatos NVARCHAR(50) NOT NULL
		)
	
-- Τμήματα
	CREATE TABLE 
		Tmimata 
		(
			tmimaID INT PRIMARY KEY IDENTITY(1,1),
			tmima NVARCHAR(100) NOT NULL,
			sxoli NVARCHAR(100) NOT NULL
		)
 
-- Κατηγορία Απασχόλησης
	CREATE TABLE 
	KatApasxolisis		
	(
			katapasxolisisID INT PRIMARY KEY IDENTITY(1,1),
			katapasxolisis NVARCHAR(50) NOT NULL,
		)

-- Κλάδος Εργασίας
	CREATE TABLE 
		KladosErgasias 
		(
			kladosergasiasID INT PRIMARY KEY IDENTITY(1,1),
			kladosergasias NVARCHAR(255) NOT NULL
		)

-- Εξαρτώμενοι πίνακες που έχουν Foreign Keys μόνο προς τους ανεξάρτητους
-- Καθηγητές, Εξαρτάται από: Τμήματα
	CREATE TABLE 
		Kathigites 
		(
			kathigitisID INT PRIMARY KEY IDENTITY(1,1),
			onoma NVARCHAR(50) NOT NULL,
			eponimo NVARCHAR(50) NOT NULL,
			email NVARCHAR(50) UNIQUE,
			CONSTRAINT CHK_EmailK_Format CHECK (email LIKE '%_@_%._%'),
			tilefono NVARCHAR(10) UNIQUE,
			tmimaID INT NOT NULL,
			FOREIGN KEY (tmimaID) REFERENCES Tmimata(tmimaID),
			anenergos BIT NOT NULL DEFAULT 0,
			dateanenergos DATE NULL,
		)


-- Προγράμματα, Εξαρτάται από: Τμήματα & Τύπος Προγράμματος
	CREATE TABLE 
		Programmata 
		(
			programmaID INT PRIMARY KEY IDENTITY(1,1),
			programma NVARCHAR(100) NOT NULL,
			tiposprogrammatosID INT NOT NULL,
	FOREIGN KEY (tiposprogrammatosID) REFERENCES TiposProgrammatos(tiposprogrammatosID),
			tmimaID INT NOT NULL,
			FOREIGN KEY (tmimaID) REFERENCES Tmimata(tmimaID),
			diarkeia FLOAT NOT NULL,
			upoxergasia BIT NOT NULL DEFAULT 0		
		)
 
-- Εξαρτώμενοι πίνακες που έχουν Foreign Keys προς τους παραπάνω 
-- Εργασίες, Εξαρτάται από: Καθηγητές
	CREATE TABLE 
		Ergasies 
		(
			ergasiaID INT PRIMARY KEY IDENTITY(1,1),
			titlosergasias VARCHAR(200) NOT NULL,
	kathigitisID INT NOT NULL,
			FOREIGN KEY (kathigitisID) REFERENCES Kathigites(kathigitisID),
			dateipovolis DATE NOT NULL,
			vathmos DECIMAL(5,2) NOT NULL,
			path NVARCHAR(MAX) NOT NULL		
		)

-- Φοίτηση, Εξαρτάται από: Απόφοιτοι, Προγράμματα, Εργασίες
	CREATE TABLE 
		Foitisi 
		(
			foitisiID INT PRIMARY KEY IDENTITY(1,1),
			am NVARCHAR(12) NOT NULL,
			FOREIGN KEY (am) REFERENCES Apofoitoi(am),
			dateeggrafis DATE NOT NULL,
			dateapofoitisis DATE NOT NULL,
			CHECK (dateapofoitisis > dateeggrafis),
			programmaID INT NOT NULL,
	FOREIGN KEY (programmaID) REFERENCES Programmata(programmaID),
			vathmos DECIMAL(5,2) NOT NULL,
			ergasiaID INT NULL,
	FOREIGN KEY (ergasiaID) REFERENCES Ergasies(ergasiaID)
	)

-- Καριέρα, Εξαρτάται από: Απόφοιτοι, Κατηγορία Απασχόλησης, Κλάδος Απασχόλησης
	CREATE TABLE 
		Kariera 
		(
			karieraID INT PRIMARY KEY IDENTITY(1,1),
			am NVARCHAR (12) NOT NULL,
			FOREIGN KEY (am) REFERENCES Apofoitoi(am),
			etairia NVARCHAR(100),
			titlos NVARCHAR(100),
			katapasxolisisID INT NOT NULL,
			FOREIGN KEY (katapasxolisisID) REFERENCES KatApasxolisis(katapasxolisisID),
			datefrom DATE NOT NULL,
			kladosergasiasID INT NOT NULL,
			FOREIGN KEY (kladosergasiasID) REFERENCES KladosErgasias(kladosergasiasID),
			xwra NVARCHAR(50) NOT NULL
		) 

-- Εισαγωγή δεδομένων από CSV αρχεία

-- Εισαγωγή δεδομένων για τον πίνακα Kariera και ομοίως για όλους τους πίνακες
	BULK INSERT dbo.Kariera
	FROM 'C:\Temp\CSV\Kariera.csv'
	WITH 
		(
			FIELDTERMINATOR = ';', -- Τα πεδία στο αρχείο χωρίζονται με το χαρακτήρα ;
			ROWTERMINATOR = '\n', -- Κάθε γραμμή τελειώνει με το χαρακτήρα αλλαγής γραμμής
			FIRSTROW = 2, -- η εισαγωγή θα ξεκινήσει από την 2η γραμμή
			CODEPAGE = '65001' -- η κωδικοποίηση του αρχείου είναι UTF-8
		)

/* Έλεγχοι */

-- Γενικοί
	SELECT * FROM TiposProgrammatos -- total=2 
	SELECT * FROM Tmimata -- total=6 
	SELECT * FROM KatApasxolisis -- total=3
	SELECT * FROM KladosErgasias -- total=27
	SELECT * FROM Programmata -- total=26 
	SELECT * FROM Kathigites -- total=250
	SELECT * FROM Apofoitoi -- total=55.182
	SELECT * FROM Ergasies -- total= 25.182
	SELECT * FROM Foitisi -- total= 69.774
	SELECT * FROM Kariera -- total= 25.182

-- Για κάθε πίνακα

-- Apofoitoi
-- Συνολικός αριθμός αποφοίτων
	SELECT COUNT(*) AS TotalApofoitoi FROM Apofoitoi


-- Tmimata
 -- Συνολικός αριθμός τμημάτων
 
	SELECT COUNT(*) AS TotalTmimata FROM Tmimata
-- Συνολικός αριθμός μοναδικών σχολών
	SELECT COUNT(DISTINCT sxoli) AS TotalSxoles FROM Tmimata


-- TiposProgrammatos
-- Συνολικός αριθμός τύπου προγράμματος
	SELECT * FROM TiposProgrammatos


-- Programmata
-- Συνολικός αριθμός προγραμμάτων
	SELECT COUNT(*) AS TotalProgrammata FROM Programmata
	
-- Προγράμματα με υποχρεωτικές εργασίες
	SELECT COUNT(*) AS ProgrammataMeErgasies FROM Programmata WHERE upoxergasia=1


-- Kathigites
-- Συνολικός αριθμός καθηγητών
	SELECT COUNT(*) AS TotalKathigites FROM Kathigites
	
-- Ανενεργοί καθηγητές
	SELECT * FROM Kathigites WHERE anenergos = 1


-- Foitisi
-- Συνολικός αριθμός εγγραφών φοίτησης
	SELECT COUNT(*) AS TotalFoitisi FROM Foitisi
	
-- Σύνολο αποφοίτων που ανήκουν σε αυτές τις κατηγορίες
	WITH TotalApofoitoiTiposProgrammatos AS 
	(
		SELECT 
			am,
			SUM(CASE WHEN p.tiposprogrammatosID = 1 THEN 1 ELSE 0 END) AS prop,
			SUM(CASE WHEN p.tiposprogrammatosID = 2 THEN 1 ELSE 0 END) AS metap
		FROM 
			Foitisi f
		INNER JOIN Programmata p ON f.programmaid=p.programmaid
		GROUP BY 
			am
	)
	SELECT
		COUNT(*) AS 'Σύνολο Αποφοίτων',
		SUM(CASE WHEN prop = 1 AND metap = 0 THEN 1 ELSE 0 END) AS 'Μόνο προπτυχιακό',
		SUM(CASE WHEN prop = 0 AND metap = 1 THEN 1 ELSE 0 END) AS 'Μόνο μεταπτυχιακό',
		SUM(CASE WHEN prop = 1 AND metap = 1 THEN 1 ELSE 0 END) AS 'Προπτυχιακό & 1 Μεταπτυχιακό',
		SUM(CASE WHEN prop = 1 AND metap = 2 THEN 1 ELSE 0 END) AS 'Προπτυχιακό & 2 Μεταπτυχιακά'
	FROM
		TotalApofoitoiTiposProgrammatos
		
-- Ομαδοποίηση με βάση τον αριθμό προγραμμάτων που έχει κάθε απόφοιτος
	SELECT am, COUNT(*) AS ProgramCount
	FROM Foitisi GROUP BY am ORDER BY ProgramCount DESC


-- Ergasies
-- Έλεγχος για τυχόν εγγραφές με dateapofoitisis > dateipovolis που δεν ταιριάζουν: -
	SELECT f.am, f.dateapofoitisis, e.dateipovolis
	FROM Ergasies e
	INNER JOIN Foitisi f ON e.ergasiaID=f.ergasiaID
	INNER JOIN Programmata p ON f.programmaID = p.programmaID
	WHERE p.tiposprogrammatosID = 2 AND f.dateapofoitisis <= e.dateipovolis

-- Ανάθεση εργασιών μέσω εισαγωγής δεδομένων από CSV αρχείο σε προσωρινό πίνακα, update δεδομένων στον πίνακα Ergasies και έλεγχος 

	CREATE TABLE #TempErgasies (ergasiaID INT,kathigitisID INT)

	BULK INSERT #TempErgasies
	FROM 'C:\Temp\CSV\updatekathigitesseergasies.csv'
	WITH 
	(
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',   
		FIRSTROW = 2
	)

	SELECT *  FROM #TempErgasies

	UPDATE e
	SET e.kathigitisID = te.kathigitisID
	FROM Ergasies e
	INNER JOIN #TempErgasies te ON e.ergasiaID = te.ergasiaID

	SELECT *  FROM Ergasies

	DELETE #TempErgasies
	DROP TABLE #TempErgasies

-- Έλεγχος ανενεργών καθηγητών και εργασίες : -
	SELECT 
		k.kathigitisID,
		e.ergasiaID
	FROM 
		Kathigites k
	INNER JOIN 
		Ergasies e ON k.kathigitisID = e.kathigitisID
	WHERE 
		k.anenergos = 1 
		AND e.dateipovolis > k.dateanenergos

-- Έλεγχος αν το άθροισμα των καθηγητών χωρίς εργασίες και το άθροισμα των καθηγητών με εργασίες ισούται με το συνολικό αριθμό καθηγητών
	WITH XorisErgasies AS 
	(
		SELECT COUNT(*) AS KathigitesXorisErgasies
		FROM Kathigites k
		LEFT JOIN Ergasies e ON k.kathigitisID = e.kathigitisID
		WHERE e.kathigitisID IS NULL
	),
	MeErgasies AS 
	(
		SELECT COUNT(DISTINCT k.kathigitisID) AS KathigitesMeErgasies
		FROM Kathigites k
		LEFT JOIN Ergasies e ON k.kathigitisID = e.kathigitisID
		WHERE e.kathigitisID IS NOT NULL
	),
	Total AS 
	(
		SELECT COUNT(*) AS TotalKathigites
		FROM Kathigites
	)
	SELECT 
		x.KathigitesXorisErgasies + m.KathigitesMeErgasies AS 'Άθροισμα καθηγητών με ή χωρίς εργασία',
		s.TotalKathigites AS 'Σύνολο καθηγητών',
		CASE 
			WHEN x.KathigitesXorisErgasies + m.KathigitesMeErgasies = s.TotalKathigites 
			THEN 'OK'
			ELSE 'FAIL'
		END AS 'Έλεγχος'
	FROM 
		XorisErgasies x, MeErgasies m, Total s


-- KatApasxolisis
-- Συνολικός αριθμός εγγραφών στον πίνακα Κατηγορία Απασχόλησης 
	SELECT COUNT(*) AS TotalKatApasxolisis FROM KatApasxolisis


-- KladosErgasias
-- Συνολικός αριθμός εγγραφών στον πίνακα Κλάδος Εργασίας
	SELECT COUNT(*) AS TotalKladosErgasias FROM KladosErgasias


-- Kariera
-- Συνολικός αριθμός εγγραφών στον πίνακα καριέρας
	SELECT COUNT(*) AS TotalKariera FROM Kariera

-- Έλεγχος αν υπάρχουν φοιτητές με ΜΟΝΟ με προπτυχιακό που έχουν εγγραφή στην Καριέρα: -
	SELECT DISTINCT k.am 
	FROM Kariera k
	INNER JOIN 
		(   -- 36.000 Απόφοιτοι μόνο προπτυχιακού
			SELECT f.am
			FROM Foitisi f
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			GROUP BY f.am
			HAVING COUNT(DISTINCT p.tiposprogrammatosID) = 1 AND MAX(p.tiposprogrammatosID) = 1
		) AS Monoprop ON k.am = Monoprop.am


/* SELECT Εντολές */

-- QUERY για ποσοστό αποφοίτων ανά τύπο προγράμματος
	SELECT 
		t.tiposprogrammatos AS 'Τύπος Προγράμματος', 
	CAST(ROUND(COUNT(f.am) * 100.0 / (SELECT COUNT(*) FROM Foitisi), 2) AS DECIMAL(5, 2)) AS '% Ποσοστό (%) Αποφοίτων'
	FROM Foitisi F
	INNER JOIN Programmata p ON p.programmaID=F.programmaID
	INNER JOIN TiposProgrammatos t ON p.tiposprogrammatosID=t.tiposprogrammatosID
	GROUP BY t.tiposprogrammatos

-- QUERY για μέσο όρο βαθμολογιών ανά τμήμα και τύπο προγράμματος
	SELECT 
			t.tmimaID AS 'Τμήμα',
	CAST(AVG(CASE WHEN p.tiposprogrammatosID = 1 THEN f.vathmos END) AS DECIMAL(5,2)) AS 'Μέσος όρος βαθμολογίας Προπτυχιακών',
	CAST(AVG(CASE WHEN p.tiposprogrammatosID = 2 THEN f.vathmos END) AS DECIMAL(5,2)) AS 'Μέσος όρος βαθμολογίας Μεταπτυχιακών'
	FROM Foitisi f
	INNER JOIN Programmata p ON f.programmaID = p.programmaID
	INNER JOIN Tmimata t ON p.tmimaID = t.tmimaID
	GROUP BY t.tmimaID
	ORDER BY t.tmimaID

-- QUERY για ποσοστό αποφοίτων με τη μέγιστη βαθμολογία ανά τμήμα	
	WITH MaxVathmosPerTmima AS 
		(
			-- Βρίσκουμε την υψηλότερη βαθμολογία ανά τμήμα
			SELECT 
				t.tmimaID, 
				MAX(f.vathmos) AS HighestVathmos
			FROM Foitisi f
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			INNER JOIN Tmimata t ON p.tmimaID = t.tmimaID
			GROUP BY t.tmimaID
		),
	StudentCounts AS 
		(
			-- Βρίσκουμε το συνολικό πλήθος φοιτητών και όσους έχουν τη μέγιστη βαθμολογία ανά τμήμα
			SELECT 
				t.tmimaID,
				COUNT(*) AS TotalStudents,
				SUM(CASE WHEN f.vathmos = m.HighestVathmos THEN 1 ELSE 0 END) AS TopStudents
			FROM Foitisi f
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			INNER JOIN Tmimata t ON p.tmimaID = t.tmimaID
			INNER JOIN MaxVathmosPerTmima m ON t.tmimaID = m.tmimaID
			GROUP BY t.tmimaID
		)
	-- Υπολογίζουμε το ποσοστό των φοιτητών με τη μέγιστη βαθμολογία ανά τμήμα και το ταξινομούμε
	SELECT 
		tmimaID AS 'Τμήμα',
		TotalStudents AS 'Συνολικοί Φοιτητές',
		TopStudents AS 'Φοιτητές με Υψηλότερη Βαθμολογία',
		CAST((TopStudents * 100.0) / TotalStudents AS DECIMAL(5,2)) AS 'Ποσοστό (%) Φοιτητών με Υψηλότερη Βαθμολογία'
	FROM StudentCounts
	ORDER BY tmimaID

-- QUERY για Ανάλυση χρονικής απόστασης Προπτυχιακού-Μεταπτυχιακού
	-- Υπολογίζει το πλήθος προπτυχιακών (prop) και μεταπτυχιακών (metap) που έχει κάθε απόφοιτος
	WITH TotalApofoitoiTiposProgrammatos AS (
		SELECT 
			f.am, -- Αναγνωριστικό φοιτητή
			SUM(CASE WHEN p.tiposprogrammatosID = 1 THEN 1 ELSE 0 END) AS prop, -- Πλήθος προπτυχιακών
			SUM(CASE WHEN p.tiposprogrammatosID = 2 THEN 1 ELSE 0 END) AS metap -- Πλήθος μεταπτυχιακών
		FROM Foitisi f
		INNER JOIN Programmata p ON f.programmaID = p.programmaID 
		GROUP BY f.am 
	),
	-- Φιλτράρει όσους έχουν ακριβώς 1 προπτυχιακό και 1 ή 2 μεταπτυχιακά
	FilteredApofoitoi AS (
		SELECT 
			am
		FROM TotalApofoitoiTiposProgrammatos
		WHERE prop = 1 AND (metap = 1 OR metap = 2) 
	),
	-- Εντοπίζει την τελευταία ημερομηνία αποφοίτησης από προπτυχιακό για κάθε φοιτητή
	LastUndergraduate AS (
		SELECT 
			f.am,
			MAX(f.dateapofoitisis) AS LastPropDate
		FROM Foitisi f
		INNER JOIN Programmata p ON f.programmaID = p.programmaID
		WHERE p.tiposprogrammatosID = 1 -- Φιλτράρει μόνο προπτυχιακά
		  AND f.am IN (SELECT am FROM FilteredApofoitoi) -- Περιλαμβάνει μόνο τους φιλτραρισμένους φοιτητές
		GROUP BY f.am
	),
	-- Εντοπίζει την πρώτη ημερομηνία εγγραφής σε μεταπτυχιακό για κάθε φοιτητή
	FirstPostgraduate AS (
		SELECT 
			f.am,
			MIN(f.dateeggrafis) AS FirstMetapDate 
		FROM Foitisi f
		INNER JOIN Programmata p ON f.programmaID = p.programmaID
		WHERE p.tiposprogrammatosID = 2 -- Φιλτράρει μόνο μεταπτυχιακά
		  AND f.am IN (SELECT am FROM FilteredApofoitoi) -- Περιλαμβάνει μόνο τους φιλτραρισμένους φοιτητές
		GROUP BY f.am
	),
	-- Υπολογίζει τα χρόνια μεταξύ του τελευταίου προπτυχιακού και του πρώτου μεταπτυχιακού
	EtiDiafora AS (
		SELECT 
			lu.am,
			DATEDIFF(YEAR, lu.LastPropDate, fp.FirstMetapDate) AS YearsBetween 
		FROM LastUndergraduate lu
		INNER JOIN FirstPostgraduate fp ON lu.am = fp.am -- Σύνδεση τελευταίου προπτυχιακού με πρώτο μεταπτυχιακό
		WHERE lu.LastPropDate < fp.FirstMetapDate 
	),
	-- Υπολογίζει το πλήθος αποφοίτων ανά αριθμό ετών από το προπτυχιακό στο μεταπτυχιακό
	YearCounts AS (
		SELECT 
			YearsBetween,
			COUNT(*) AS CountPerYear -- Πλήθος αποφοίτων ανά έτος
		FROM EtiDiafora
		GROUP BY YearsBetween
	),
	-- Υπολογίζει το συνολικό πλήθος αποφοίτων που πληρούν τα κριτήρια
	TotalApofoitoiFinal AS (
		SELECT COUNT(*) AS TotalApofoitoiFinal
		FROM EtiDiafora
	)
	-- Τελικό αποτέλεσμα: Ποσοστό και πλήθος αποφοίτων ανά χρόνια από το προπτυχιακό στο μεταπτυχιακό
	SELECT 
		yc.YearsBetween AS 'Χρόνια μετά από το προπτυχιακό', 
		yc.CountPerYear AS 'Σύνολο Αποφοίτων', 
		CAST(100.0 * yc.CountPerYear / tf.TotalApofoitoiFinal AS DECIMAL(5,2)) AS '% Ποσοστό Αποφοίτων' 
	FROM YearCounts yc
	CROSS JOIN TotalApofoitoiFinal tf -- Συνδυασμός με το συνολικό πλήθος αποφοίτων
	ORDER BY yc.YearsBetween 

-- QUERY για εύρεση αποφοίτων με δύο μεταπτυχιακά από διαφορετικά τμήματα
	SELECT DISTINCT 
			f1.am AS 'AM',
			t1.tmima AS 'Τμήμα 1ου',
		p1.programma AS 'Πρόγραμμα 1ου',
		YEAR(f1.dateapofoitisis) AS  'Χρονιά αποφοίτησης 1ου',
			t2.tmima AS 'Τμήμα 2ου',
		p2.programma 'Πρόγραμμα 2ου',
		YEAR(f2.dateapofoitisis) AS  'Χρονιά αποφοίτησης 2ου'
	FROM Foitisi f1
	INNER JOIN Programmata p1 ON f1.programmaID = p1.programmaID
	INNER JOIN Tmimata t1 ON p1.tmimaID = t1.tmimaID
	INNER JOIN Foitisi f2 ON f1.am = f2.am -- Self-join για τον ίδιο φοιτητή
	INNER JOIN Programmata p2 ON f2.programmaID = p2.programmaID
	INNER JOIN Tmimata t2 ON p2.tmimaID = t2.tmimaID
	WHERE 
		p1.tiposprogrammatosID = 2 -- Το 1ο πρόγραμμα είναι μεταπτυχιακό
		AND p2.tiposprogrammatosID = 2 -- Το 2ο πρόγραμμα είναι μεταπτυχιακό
		AND t1.tmimaID <> t2.tmimaID -- Διαφορετικά τμήματα
		AND f1.foitisiID < f2.foitisiID -- Αποφυγή διπλών αποτελεσμάτων


/* Stored procedures */
-- Store procedure για τατιστική ανάλυση αποφοίτων ανά έτος και πρόγραμμα σπουδών
	CREATE PROCEDURE [dbo].[ebproc_GetApofoitoiByYearAndProgram]
		@Year INT = NULL, -- Αν NULL, επιστρέφει όλα τα έτη
		@TmimaID INT = NULL,
		@Tmima NVARCHAR(100) = NULL,
		@ProgrammaID INT = NULL,
		@Programma NVARCHAR(100) = NULL,
		@Tiposprogrammatos INT = NULL
		
	AS
	BEGIN
		SET NOCOUNT ON

		SELECT 
			YEAR(f.dateapofoitisis) AS 'Έτος αποφοίτησης',
			CASE 
				WHEN p.tiposprogrammatosID = 1 THEN 'Προπτυχιακό'
				WHEN p.tiposprogrammatosID = 2 THEN 'Μεταπτυχιακό'
				ELSE 'Other'
			END AS 'Τύπος Προγράμματος',
			f.programmaID AS 'Κωδικός Προγράμματος',
			p.programma AS 'Όνομα Προγράμματος',
			p.tmimaID AS 'Κωδικός Τμήματος',
			t.tmima AS 'Όνομα Τμήματος',
			t.sxoli AS 'Σχολή',
			COUNT(DISTINCT f.am) AS 'Σύνολο αποφοίτων'
		FROM 
			Foitisi f INNER JOIN Programmata p ON f.programmaID = p.programmaID
		INNER JOIN Tmimata t ON p.tmimaID = t.tmimaID
		WHERE 
			f.dateapofoitisis IS NOT NULL
			AND (@Year IS NULL OR YEAR(f.dateapofoitisis) = @Year) -- Φιλτράρει ανά έτος
			AND (@ProgrammaID IS NULL OR p.programma = @ProgrammaID)   -- Φιλτράρισμα ανά πρόγραμμα
			AND (@Programma IS NULL OR p.programma = @Programma)
			AND (@TmimaID IS NULL OR p.tmimaID = @TmimaID)
			AND (@Tmima IS NULL OR t.tmima = @Tmima)
			AND (@Tiposprogrammatos IS NULL OR p.tiposprogrammatosID = @Tiposprogrammatos)
		GROUP BY 
		   YEAR(f.dateapofoitisis),
		   p.tiposprogrammatosID,
		f.programmaID,
		p.programma,
		p.tmimaID,
		   t.tmima,
		   t.sxoli
		ORDER BY 
			YEAR(f.dateapofoitisis),
			p.tiposprogrammatosID,
			f.programmaID,
			p.programma,
			p.tmimaID,
			t.tmima,
			t.sxoli
	END

		-- Έλεγχοι 
		
		-- χωρίς παραμέτρους
		exec ebproc_GetApofoitoiByYearAndProgram
		
		-- με παραμέτρους
		exec ebproc_GetApofoitoiByYearAndProgram 
		@Year = 2020 , @TmimaID = 3 , @Tiposprogrammatos = 2	
	
	
-- Store procedure για αναζήτηση φορτίου εργασιών καθηγητών ανά έτος	
	CREATE PROCEDURE [dbo].[ebproc_GetErgasiesByKathigitisAndYear]
	@kathigitisID INT = NULL,  -- Προαιρετική παράμετρος για το ID του καθηγητή
	@etos INT = NULL,  -- Προαιρετική παράμετρος για το έτος
	@programmaID INT = NULL  -- Προαιρετική παράμετρος για το πρόγραμμα
	AS
	BEGIN
		-- Υπολογίζουμε το σύνολο εργασιών ανά έτος και πρόγραμμα
		WITH TotalErgasiesPerYearAndProgram AS 
		(
			SELECT 
				YEAR(e.dateipovolis) AS Etos,           
				f.programmaID AS Programma,             
				COUNT(e.ergasiaID) AS SynoloErgasion    
			FROM Ergasies e
			INNER JOIN Foitisi f ON e.ergasiaID = f.ergasiaID 
			GROUP BY YEAR(e.dateipovolis), f.programmaID
		)
		-- Αναζήτηση των εργασιών κάθε καθηγητή και το ποσοστό εργασιών καθηγητή σε σχέση με το σύνολο εργασιών ανά έτος και πρόγραμμα
		SELECT 
			k.kathigitisID AS 'Καθηγητής',                                   
			CONCAT(k.onoma, ' ', k.eponimo) AS 'Ονοματεπώνυμο',               
			YEAR(e.dateipovolis) AS 'Έτος ',                                   
			f.programmaID AS 'Πρόγραμμα',                                    
			COUNT(e.ergasiaID) AS 'Αριθμός Εργασιών',
			CAST((COUNT(e.ergasiaID) * 100.0) / te.SynoloErgasion AS DECIMAL(5,2)) AS 'Συμμετοχή στις Συνολικές Εργασίες (%)'   
		FROM Ergasies e
		INNER JOIN Kathigites k ON e.kathigitisID = k.kathigitisID         
		INNER JOIN Foitisi f ON e.ergasiaID = f.ergasiaID                 
		INNER JOIN TotalErgasiesPerYearAndProgram te ON YEAR(e.dateipovolis) = te.Etos AND f.programmaID = te.Programma
		WHERE 
		   (@kathigitisID IS NULL OR k.kathigitisID = @kathigitisID) -- Φιλτράρισμα με βάση καθηγητή
		   AND (@etos IS NULL OR YEAR(e.dateipovolis) = @etos) -- Φιλτράρισμα με βάση έτος
		AND (@programmaID IS NULL OR f.programmaID = @programmaID) -- Φιλτράρισμα με βάση το πρόγραμμα

		GROUP BY 
			k.kathigitisID, k.onoma, k.eponimo, YEAR(e.dateipovolis), f.programmaID, te.SynoloErgasion
		ORDER BY 
			k.kathigitisID, YEAR(e.dateipovolis), f.programmaID          
	END
		
		-- Έλεγχοι 
		
		-- χωρίς παραμέτρους
		EXEC ebproc_GetErgasiesByKathigitisAndYear
		
		-- με παραμέτρους
		EXEC ebproc_GetErgasiesByKathigitisAndYear @etos = 2018, @kathigitisID = 6
		
		EXEC ebproc_GetErgasiesByKathigitisAndYear @programmaID = 9, @etos = 2018
	
	
-- Store procedure για στατιστική ανάλυση αποφοίτων που εργάζονται στο εξωτερικό, ανά πρόγραμμα 
	CREATE PROCEDURE [dbo].[ebproc_GetProgramCountryStats]
    @Program NVARCHAR(100) = NULL, -- Δυνατότητα φιλτραρίσματος βάσει προγράμματος
    @Year INT = NULL               -- Δυνατότητα φιλτραρίσματος βάσει έτους
	AS
	BEGIN
		WITH TotalProgramCounts AS 
	(
			SELECT 
				p.programma AS 'Πρόγραμμα',
				COUNT(*) AS TotalStudents
			FROM Kariera c
			INNER JOIN Foitisi f ON c.am = f.am
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			WHERE p.tiposprogrammatosID = 2
			GROUP BY p.programma
			),
		ProgramCountryCounts AS 
		(
			SELECT 
				p.programma AS 'Πρόγραμμα',
				COUNT(*) AS StudentsAbroad,
				CAST(ROUND(COUNT(*) * 1.0 / tp.TotalStudents * 100, 2) AS DECIMAL(5, 2)) AS 'Ποσοστό'
			FROM Kariera c
			INNER JOIN Foitisi f ON c.am = f.am
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			INNER JOIN TotalProgramCounts tp ON p.programma = tp.Πρόγραμμα
			WHERE c.xwra <> 'Ελλάδα' AND p.tiposprogrammatosID = 2
			GROUP BY p.programma, tp.TotalStudents
			)
		SELECT 
			Πρόγραμμα,
			StudentsAbroad AS 'Σύνολο Αποφοίτων Εκτός Ελλάδας',
			CONCAT(Ποσοστό, '%') AS '(%) Ποσοστό'
		FROM ProgramCountryCounts
		WHERE (@Program IS NULL OR Πρόγραμμα = @Program) -- Φιλτράρισμα ανά πρόγραμμα
		  AND (@Year IS NULL OR EXISTS (
			  SELECT 1
			  FROM Kariera c
			  WHERE AND (@Year IS NULL OR YEAR(c.datefrom) = @Year)
			))
		ORDER BY Πρόγραμμα, Ποσοστό DESC
	END 

		-- Έλεγχοι 
		
		-- χωρίς παραμέτρους
		EXEC ebproc_GetProgramCountryStats
		
		-- με παραμέτρους
		EXEC ebproc_GetProgramCountryStats @Program = 'Μεταπτυχιακό1_Τμήματος1_Σχολής1', @Year = 2023
		EXEC ebproc_GetProgramCountryStats @Year = 2023


-- Store procedure για αναζήτηση αποφοίτων που εργάζονται στο εξωτερικό, ανά πρόγραμμα
	CREATE PROCEDURE [dbo].[ebproc_GetProgramCountryDetails]
	@Program NVARCHAR(100) = NULL, -- Φιλτράρισμα βάσει προγράμματος
	@Year INT = NULL               -- Φιλτράρισμα βάσει έτους
	AS
	BEGIN
		WITH TotalProgramCounts AS 
		(
			SELECT 
				p.programma AS 'Πρόγραμμα',
				COUNT(*) AS TotalStudents
			FROM Kariera k
			INNER JOIN Foitisi f ON k.am = f.am
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			WHERE p.tiposprogrammatosID = 2
			GROUP BY p.programma
			),
		ProgramCountryCounts AS 
		(
			SELECT 
				p.programma AS 'Πρόγραμμα',
				COUNT(*) AS StudentsAbroad,
				CAST(ROUND(COUNT(*) * 1.0 / tp.TotalStudents * 100, 2) AS DECIMAL(5, 2)) AS 'Ποσοστό'
			FROM Kariera k
			INNER JOIN Foitisi f ON k.am = f.am
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			INNER JOIN TotalProgramCounts tp ON p.programma = tp.Πρόγραμμα
			WHERE k.xwra <> 'Ελλάδα' AND p.tiposprogrammatosID = 2
			GROUP BY p.programma, tp.TotalStudents
			)
		SELECT 
			Πρόγραμμα,
			StudentsAbroad AS 'Σύνολο Αποφοίτων Εκτός Ελλάδας',
			CONCAT(Ποσοστό, '%') AS '(%) Ποσοστό'
		FROM ProgramCountryCounts
		WHERE (@Program IS NULL OR Πρόγραμμα = @Program) -- Φιλτράρισμα ανά πρόγραμμα
		  AND (@Year IS NULL OR EXISTS (
			  SELECT 1
			  FROM Kariera k
			  WHERE k.datefrom >= DATEFROMPARTS(@Year, 1, 1)
				 AND (@Year IS NULL OR YEAR(k.datefrom) = @Year)
			))
		ORDER BY Πρόγραμμα, Ποσοστό DESC
	END 
	
		-- Έλεγχοι 
		
		-- χωρίς παραμέτρους
		EXEC ebproc_GetProgramCountryDetails
		
		-- με παραμέτρους 
		EXEC ebproc_GetProgramCountryDetails @Program = 'Μεταπτυχιακό1_Τμήματος1_Σχολής1' 
		EXEC ebproc_GetProgramCountryDetails @Program = 'Μεταπτυχιακό1_Τμήματος1_Σχολής1', @Year = 2023


-- Store procedure για στατιστική ανάλυση χρόνου εύρεσης πρώτης εργασίας μετά το Μεταπτυχιακό
	CREATE PROCEDURE [dbo].[ebproc_GetFirstJobStats]
		@Program NVARCHAR(100) = NULL -- Φιλτράρισμα βάσει προγράμματος (προαιρετικό)
	AS
	BEGIN
		WITH LastMasterGraduation AS 
	(
			SELECT 
				f.am, -- Αριθμός Μητρώου Απόφοιτου
				p.programma AS Program, -- Πρόγραμμα Σπουδών
				MAX(f.dateapofoitisis) AS LastMasterDate -- Τελευταία ημερομηνία μεταπτυχιακού
			FROM Foitisi f
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			WHERE p.tiposprogrammatosID = 2 -- Μόνο μεταπτυχιακά
			GROUP BY f.am, p.programma
		),
		FirstJobAfterMaster AS 
	(
			SELECT 
				lmg.am, -- Αριθμός Μητρώου Απόφοιτου
				lmg.Program, -- Πρόγραμμα Σπουδών
				DATEDIFF(MONTH, lmg.LastMasterDate, MIN(c.datefrom)) AS MonthsToFirstJob -- Μήνες μέχρι την πρώτη δουλειά
			FROM Kariera c
			INNER JOIN LastMasterGraduation lmg ON c.am = lmg.am
			WHERE c.datefrom > lmg.LastMasterDate -- Μόνο καριέρα μετά το μεταπτυχιακό
			GROUP BY lmg.am, lmg.Program, lmg.LastMasterDate
		),
		GroupedData AS 
	(
			SELECT 
				Program,
				CASE 
					WHEN MonthsToFirstJob <= 3 THEN '0-3 μήνες'
					WHEN MonthsToFirstJob BETWEEN 4 AND 7 THEN '4-7 μήνες'
					WHEN MonthsToFirstJob BETWEEN 8 AND 12 THEN '8-12 μήνες'
					WHEN MonthsToFirstJob BETWEEN 13 AND 24 THEN '13-24 μήνες'
					ELSE '25+ μήνες'
				END AS TimeRange,
				COUNT(*) AS TotalGraduates
			FROM FirstJobAfterMaster
			GROUP BY 
				Program,
				CASE 
					WHEN MonthsToFirstJob <= 3 THEN '0-3 μήνες'
					WHEN MonthsToFirstJob BETWEEN 4 AND 7 THEN '4-7 μήνες'
					WHEN MonthsToFirstJob BETWEEN 8 AND 12 THEN '8-12 μήνες'
					WHEN MonthsToFirstJob BETWEEN 13 AND 24 THEN '13-24 μήνες'
					ELSE '25+ μήνες'
				END
		),
		TotalGraduatesPerProgram AS 
	(
			SELECT 
				Program,
				SUM(TotalGraduates) AS TotalProgramGraduates
			FROM GroupedData
			GROUP BY Program
		)
		SELECT 
			gd.Program AS 'Πρόγραμμα',
			gd.TimeRange AS 'Χρονικό Εύρος',
			gd.TotalGraduates AS 'Σύνολο Αποφοίτων',
			CAST(100.0 * gd.TotalGraduates / tgp.TotalProgramGraduates AS DECIMAL(5,2)) AS 'Ποσοστό (%)'
		FROM GroupedData gd
		INNER JOIN TotalGraduatesPerProgram tgp ON gd.Program = tgp.Program
		WHERE @Program IS NULL OR gd.Program = @Program -- Εφαρμογή φίλτρου βάσει προγράμματος
		ORDER BY gd.Program, gd.TimeRange
	END 
	
		-- Έλεγχοι
		
		-- χωρίς παραμέτρους
		EXEC ebproc_GetFirstJobStats
		
		-- με παραμέτρους
		EXEC ebproc_GetFirstJobStats @Program = 'Μεταπτυχιακό1_Τμήματος1_Σχολής1'
		
		
-- Store procedure για ανάλυση αποφοιτων που εργάζονται στην Ελλάδα σε κλάδο μη σχετικό με το Μεταπτυχιακό τους		
	CREATE PROCEDURE ebproc_GetApofoitoiLastJobSeAlloKladoEllada
		@etos INT = NULL -- Προαιρετική παράμετρος για φιλτράρισμα βάσει έτους
	AS
	BEGIN
		SET NOCOUNT ON

		  WITH LastCareer AS (
			SELECT 
				k.am, -- Αριθμός Μητρώου Απόφοιτου
				MAX(k.datefrom) AS LatestCareerDate, -- Τελευταία ημερομηνία καριέρας
				kl.kladosergasias AS CareerField -- Κλάδος εργασίας
			FROM Kariera k
			INNER JOIN KladosErgasias kl ON k.kladosergasiasID=kl.kladosergasiasID
			WHERE k.kladosergasiasID = 27 -- Μόνο για τον κλάδο 27
			GROUP BY k.am, kl.kladosergasias
		),
		LastProgram AS (
			SELECT 
				f.am, -- Αριθμός Μητρώου Απόφοιτου
				MAX(f.dateapofoitisis) AS LastProgramDate -- Τελευταία ημερομηνία αποφοίτησης
			FROM Foitisi f
			INNER JOIN Programmata p ON f.programmaID = p.programmaID
			GROUP BY f.am
		)
		SELECT 
			lp.am AS 'Αριθμός Μητρώου',
			a.onoma AS 'Όνομα',
			a.eponimo AS 'Επώνυμο',
			a.email AS 'Email',
			a.tilefono AS 'Τηλέφωνο',
			YEAR(lp.LastProgramDate) AS 'Έτος Αποφοίτησης',
			lc.LatestCareerDate AS 'Τελευταία Ημερομηνία Καριέρας',
			lc.CareerField AS 'Κλάδος Εργασίας'
		FROM LastProgram lp
		INNER JOIN LastCareer lc ON lp.am = lc.am
		INNER JOIN Apofoitoi a ON lp.am = a.am
		WHERE @etos IS NULL OR YEAR(lp.LastProgramDate) = @etos -- Φιλτράρισμα αν δοθεί έτος
		ORDER BY lc.LatestCareerDate DESC
	END

		-- Έλεγχοι

		-- χωρίς παραμέτρους
		EXEC ebproc_GetApofoitoiLastJobSeAlloKladoEllada
		
		-- με παραμέτρους
		EXEC ebproc_GetApofoitoiLastJobSeAlloKladoEllada @etos = 2021 


/* Indexes */

-- Index στον πίνακα Foitisi για am
	CREATE NONCLUSTERED INDEX ebIX_Foitisi_am ON Foitisi (am)

-- Index στον πίνακα Foitisi για dateapofoitisis
	CREATE NONCLUSTERED INDEX ebIX_Foitisi_dateapofoitisis ON Foitisi (dateapofoitisis)

-- Index στον πίνακα Foitisi για programmaID
	CREATE NONCLUSTERED INDEX ebIX_Foitisi_programmaID ON Foitisi (programmaID)

-- Index στον πίνακα Ergasies για kathigitisID
	CREATE NONCLUSTERED INDEX ebIX_Ergasies_kathigitisID ON Ergasies (kathigitisID)

-- Index στον πίνακα Kariera για am
	CREATE NONCLUSTERED INDEX ebIX_Kariera_am ON Ergasies (kathigitisID)
	

/* Triggers */ 

-- Triggers για σωστή διαχείριση ανενεργών καθηγητών
 
-- Trigger στον πίνακα καθηγητών ώστε αν το anenergos ενημερώνεται σε 1, το dateanenergos ΠΡΕΠΕΙ να έχει τιμή
	CREATE TRIGGER ebtrg_CheckAndUpdateAnenergos
	ON Kathigites
	AFTER UPDATE
	AS
	BEGIN
		-- Έλεγχος: Αν το anenergos ενημερώνεται σε 1, το dateanenergos ΠΡΕΠΕΙ να έχει τιμή
		IF EXISTS 
		(
			SELECT 1
			FROM inserted i
			WHERE i.anenergos = 1 AND (i.dateanenergos IS NULL OR i.dateanenergos = '')
		)
		BEGIN
			-- Εμφάνιση μηνύματος σφάλματος
			THROW 50000, 'Παρακαλώ να εισάγετε τιμή στο πεδίο "Ημερομηνία".', 1;
		END

		-- Αν το anenergos = 0, κάνε το dateanenergos NULL
		UPDATE Kathigites
		SET dateanenergos = NULL
		WHERE anenergos = 0 AND dateanenergos IS NOT NULL
	END

-- Trigger στον πίνακα εργασιών ώστε αν η ημερομηνία υποβολής της εργασίας είναι μεγαλύτερη από την ημερομηνία απενεργοποίησης του καθηγητή, να βγάζει μήνυμα σφάλματος και κατά την εισαγωγή και κατά την ενημέρωση
	CREATE TRIGGER ebtrg_CheckInactiveKathigites
	ON Ergasies
	AFTER INSERT,UPDATE
	AS
	BEGIN
		-- Έλεγχος: Απαγόρευση ενημέρωσης εργασιών που ανήκουν σε ανενεργούς καθηγητές
		IF EXISTS 
		(
			SELECT 1
			FROM inserted i
			JOIN Kathigites k ON i.kathigitisID = k.kathigitisID
			WHERE k.anenergos = 1 AND k.dateanenergos < i.dateipovolis
		)
		BEGIN
			-- Εμφάνιση μηνύματος σφάλματος
			THROW 50001, 'Δεν επιτρέπεται η ενημέρωση εργασιών που ανήκουν σε ανενεργούς καθηγητές με ημερομηνία ανενεργοποίησης πριν την ημερομηνία υποβολής.', 1
		END
	END

		-- Έλεγχοι 

		-- ebtrg_CheckAndUpdateAnenergos
		-- Επιλέγουμε έναν ενεργό καθηγητή
		SELECT * FROM Kathigites WHERE kathigitisID = 1

		-- Πρέπει να εμφανίσει το μήνυμα σφάλματος
		UPDATE Kathigites
		SET anenergos = 1 
		WHERE kathigitisID = 1

		-- Πρέπει να λειτουργήσει σωστά
		UPDATE Kathigites
		SET anenergos = 1, dateanenergos = '2024-12-20' 
		WHERE kathigitisID = 1
		-- SELECT * FROM Kathigites WHERE kathigitisID = 1

		-- Πρέπει να ορίσει anenergos = 0, dateanenergos = null
		UPDATE Kathigites
		SET anenergos = 0, dateanenergos = '2024-12-20' -- θα ορίσει anenergos = 0, dateanenergos = null
		WHERE kathigitisID = 1
		--SELECT * FROM Kathigites WHERE kathigitisID = 1
		 

		-- έλεγχος ότι δεν επηρεάζει το trigger αλλαγές σε άλλα πεδία του πίνακα
		UPDATE Kathigites
		SET email='test1@unipi.gr' 
		WHERE kathigitisID = 1

		SELECT email,* FROM Kathigites WHERE kathigitisID = 1 
		-- Επαναφορά δεδομένων
		UPDATE Kathigites
		SET anenergos = 0 , email='email_k_1@unipi.gr'
		WHERE kathigitisID = 1
		 
		-- ebtrg_CheckInactiveKathigites
		-- Πρέπει να εμφανίσει το μήνυμα σφάλματος
		INSERT INTO Ergasies (titlosergasias, kathigitisID, dateipovolis, vathmos, path)
		VALUES ('test', 2, '2025-01-20', 10, '/path/to/file')
			 
		-- Πρέπει να εμφανίσει το μήνυμα σφάλματος
		update Ergasies 
		SET dateipovolis='2025-02-01' --'2014-02-01' , '2025-01-20'
		WHERE ergasiaID=1

		update Ergasies 
		SET kathigitisID=2 --75 , 2
		WHERE ergasiaID=1


-- Triggers για σωστή διαχείριση αλλαγής τμήματος καθηγητή 
	
	-- Δημιουργία του πίνακα Kathigites_Log για να διατηρηθεί ιστορικό των αλλαγών.
	CREATE TABLE 
		Kathigites_Log 
		(
			LogID INT IDENTITY(1,1) PRIMARY KEY, -- Μοναδικό ID για κάθε εγγραφή στον πίνακα log.
			KathigitisID INT NOT NULL, -- ID του καθηγητή που υπέστη την αλλαγή.
			OldTmimaID INT NULL, -- Παλιό τμήμα του καθηγητή (αν υπάρχει).
			NewTmimaID INT NULL, -- Νέο τμήμα του καθηγητή (αν άλλαξε).
			ChangeType NVARCHAR(10) NOT NULL, -- Τύπος αλλαγής: 'INSERT' ή 'UPDATE'.
			ChangeDate DATETIME DEFAULT GETDATE() -- Ημερομηνία και ώρα που έγινε η αλλαγή.
		)

-- Trigger που ενεργοποιείται μετά από INSERT στον πίνακα Kathigites
	-- Καταγράφει την εισαγωγή νέου καθηγητή στον πίνακα Kathigites_Log
	CREATE TRIGGER ebtrg_Kathigites_Insert
	ON Kathigites
	AFTER INSERT
	AS
	BEGIN
		INSERT INTO Kathigites_Log (KathigitisID, OldTmimaID, NewTmimaID, ChangeType)
		SELECT 
			i.kathigitisID, --
			NULL AS OldTmimaID, -- Δεν υπάρχει παλιό τμήμα (είναι νέα εγγραφή).
			i.tmimaID AS NewTmimaID, -- Το νέο τμήμα του καθηγητή.
			'INSERT' AS ChangeType -- Καταγράφεται ως εισαγωγή.
		FROM inserted i -- Ο πίνακας inserted περιέχει τις νέες εγγραφές.
	END
	
-- Trigger που ενεργοποιείται μετά από UPDATE στον πίνακα Kathigites
	-- Καταγράφει την αλλαγή του τμήματος του καθηγητή στον πίνακα Kathigites_Log
	CREATE TRIGGER ebtrg_Kathigites_Update
	ON Kathigites
	AFTER UPDATE
	AS
	BEGIN
		-- Καταγραφή αλλαγής τμήματος του καθηγητή.
		INSERT INTO Kathigites_Log (KathigitisID, OldTmimaID, NewTmimaID, ChangeType)
		SELECT 
			i.kathigitisID,
			d.tmimaID AS OldTmimaID, 
			i.tmimaID AS NewTmimaID, 
			'UPDATE' AS ChangeType 
		FROM inserted i
		INNER JOIN deleted d ON i.kathigitisID = d.kathigitisID -- Συνδέει παλιές και νέες εγγραφές.
		WHERE i.tmimaID <> d.tmimaID -- Καταγράφει μόνο αν το τμήμα έχει αλλάξει.
		-- Εμφάνιση μηνύματος όταν αλλάζει το τμήμα.
		IF EXISTS (
			SELECT 1
			FROM inserted i
			INNER JOIN deleted d ON i.kathigitisID = d.kathigitisID
			WHERE i.tmimaID <> d.tmimaID
		)
		BEGIN
			PRINT 'Το τμήμα του καθηγητή άλλαξε. Οι παλιές εργασίες δεν επηρεάστηκαν.'
		END
	END

		--Έλεγχοι

		-- Εισαγωγή δοκιμαστικής εγγραφής στον πίνακα `Kathigites`.
		INSERT INTO Kathigites (onoma, eponimo, email, tilefono, tmimaID, anenergos, dateanenergos)
		VALUES ('test2', 'test2', 'test2', 2540173658, 1, 0, null)
		-- Εμφάνιση του νέου καθηγητή που καταχωρήθηκε.
		SELECT * FROM Kathigites WHERE kathigitisID = 257
		
		-- Εισαγωγή δοκιμαστικής εγγραφής στον πίνακα `Ergasies`.
		INSERT INTO Ergasies (titlosergasias, kathigitisID, dateipovolis, vathmos, path)
		VALUES ('test', 257, '2024-01-01', 8, 'test')
		-- Εμφάνιση της νέας εργασίας που καταχωρήθηκε.
		SELECT MAX(ergasiaID) FROM Ergasies 
		-- Ενημέρωση του τμήματος του καθηγητή που δημιουργήθηκε.
		UPDATE Kathigites SET tmimaID = 2 WHERE kathigitisID = 257

		-- Επαναφορά δεδομένων
		DELETE FROM Kathigites_Log WHERE LogID in (1,2)
		-- Επαναφορά του ID 
		DBCC CHECKIDENT ('Kathigites_Log', RESEED, 0)
		DELETE FROM Ergasies WHERE ergasiaID='25184'
		-- Επαναφορά του ID 
		DBCC CHECKIDENT ('Ergasies', RESEED, 25182)
		DELETE FROM Kathigites WHERE kathigitisID in (257)
		-- Επαναφορά του ID 
		DBCC CHECKIDENT ('Kathigites', RESEED, 250) 



