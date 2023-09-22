USE EnterpriseSub
GO

DECLARE @BeginDate AS DATE
DECLARE @EndDate AS DATE

SET @BeginDate = '09-06-2023'
SET @EndDate = '09-18-2023'


IF OBJECT_ID('tempdb.dbo.#DateRange') IS NOT NULL
DROP TABLE #DateRange

;WITH Dates AS (
    SELECT @BeginDate as [Date]
    UNION ALL
    SELECT DATEADD(DD, 1, [Date]) FROM Dates WHERE [Date] < @EndDate
  )
SELECT [Date] INTO #DateRange FROM Dates


IF OBJECT_ID('tempdb.dbo.#OwnerTeam') IS NOT NULL
DROP TABLE #OwnerTeam

SELECT
    ContactID,
    ResearcherName = C.FirstName + ' ' + C.LastName,
    [Date],
    [Total Contacts Updated] = CAST(0 AS INT)
INTO
    #OwnerTeam
FROM
    Contact C WITH (NOLOCK)
CROSS APPLY #DateRange
WHERE
    ContactID IN (---
  
   ,74683051 --Julian Sebia
---

IF OBJECT_ID('tempdb.dbo.#ContactActivities') IS NOT NULL
DROP TABLE #ContactActivities

SELECT
    CA.ContactActivityID,
    CreatedDate = CAST(CA.CreatedDate AS DATE),
    CoStarContactID = OT.ContactID,
    CA.LocationID,
    AC.CompanyContactID,
    RowNum = ROW_NUMBER() OVER(PARTITION BY CA.LocationID, AC.CompanyContactID, OT.ContactID ORDER BY CA.CreatedDate)
INTO
    #ContactActivities
FROM
    ContactActivity CA WITH (NOLOCK)
LEFT JOIN
    ActivityContact AC WITH (NOLOCK) ON AC.ContactActivityID = CA.ContactActivityID AND AC.PrimaryContact = 1
INNER JOIN
    #OwnerTeam OT ON OT.ContactID = CA.CostarContactID AND OT.Date = CAST(CA.CreatedDate AS DATE)
WHERE
    CA.MethodID = 102
AND
    CAST(CA.CreatedDate AS DATE) BETWEEN @BeginDate AND @EndDate
--AND
    --CA.LocationID IS NOT NULL

IF OBJECT_ID('tempdb.dbo.#ContactActivityCounts') IS NOT NULL
DROP TABLE #ContactActivityCounts

SELECT
    CreatedDate = CAST(CreatedDate AS DATE),
    CoStarContactID,
    CNT = COUNT(*)
INTO
    #ContactActivityCounts
FROM
   #ContactActivities
WHERE
    RowNum = 1
GROUP BY
    CAST(CreatedDate AS DATE),
    CoStarContactID

UPDATE OT
SET
    [Total Contacts Updated] = CA.CNT
FROM
    #OwnerTeam OT
INNER JOIN
    #ContactActivityCounts CA ON CA.CoStarContactID = OT.ContactID AND CA.CreatedDate = OT.[Date]

SELECT
    *
FROM
    #OwnerTeam
