USE EnterpriseSub

DECLARE @Researcher TABLE (VALUE INT, ResearcherName NVARCHAR(255))

DECLARE @BeginDate AS DATE
DECLARE @EndDate AS DATE

SET @BeginDate = '09-10-2023'
SET @EndDate = '09-13-2023'

INSERT INTO @Researcher VALUES 
(4556593, 'Mike Martin'),
(88442321, 'Liz Mitchell'),
(6334296, 'James Regoord'),
(117653641, 'Robert Schwartz'),
(118443721, 'Laisha Peters'),
(154208081, 'Jacob Floyd'),
(74683051, 'Julian Sebia'),
(44387711, 'Matthew McClenahan'),
(4204161, 'Ernest Rodriguez'),
(6066923, 'Sunny Chudgar'),
(61351271, 'Eric Byerley'),
(4779152, 'Shavon Shockley'),
(3978801, 'Victoria Cottman'),
(43784101, 'Sean-Evan Evaro'),
(84588351, 'Clenda Membreno'),
(4778811, 'Greg Charlton'),
(4579917, 'Bryan McCaslin'),
(107025241, 'Thomas Meldrum'),
(91341081, 'Justin Diggs'),
(4426032, 'Fran Koerner'),
(45024231, 'Anne Scobell'),
(43486541, 'Scott Cooper'),
(6781531, 'Nicklaus Smith'),
(63911361, 'Madison Palmer'),
(5102581, 'Scott Layton');
;WITH Activities AS (
    SELECT 
        AC.CompanyContactID,
		r.ResearcherName,
        CAST(ac.CreatedDate AS DATE) AS CreatedDate,
        ROW_NUMBER() OVER (PARTITION BY AC.CompanyContactID ORDER BY ac.CreatedDate) as RowNum,
		ac.ContactActivityID
    FROM 
        @Researcher R
    JOIN ActivityContact AC WITH (NOLOCK) ON R.VALUE = AC.CreatedByContactID
    LEFT JOIN ContactActivity CA WITH (NOLOCK) ON CA.ContactActivityID = AC.ContactActivityID
		and CA.CreatedDate BETWEEN @BeginDate AND @EndDate

    WHERE 
        ca.MethodID = 102 
)

SELECT 
    a.researchername,
    a.createddate,
    Isnull (COUNT(a.ContactActivityID),0) AS Total
FROM Activities A
WHERE A.RowNum = 1
GROUP BY 
    a.researchername, 
    a.createddate 