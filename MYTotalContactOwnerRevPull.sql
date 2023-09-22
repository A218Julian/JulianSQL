USE EnterpriseSub

DECLARE @Researcher TABLE (VALUE INT, ResearcherName NVARCHAR(255))

DECLARE @BeginDate AS DATE
DECLARE @EndDate AS DATE

SET @BeginDate = '09-10-2023'
SET @EndDate = '09-13-2023'

INSERT INTO @Researcher VALUES 
	----

(74683051, 'Julian Sebia')
----

	
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
