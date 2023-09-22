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
    ContactID IN (
    4556593 --Mike Martin
   ,88442321 --Liz Mitchell
   ,6334296 --James Regoord
   ,117653641 --Robert Schwartz
   ,118443721 --Laisha Peters
   ,154208081 --Jacob Floyd 
   ,74683051 --Julian Sebia
   ,44387711 --Matthew McClenahan
   ,4204161 --Ernest Rodriguez
   ,61351271 --Eric Byerley
   ,4779152 --Shavon Shockley
   ,3978801 --Victoria Cottman
   ,43784101 --Sean-Evan Evaro
   ,84588351 --Clenda Membreno
   ,4778811 --Greg Charlton
   ,4579917 --Bryan McCaslin
   ,107025241 --Thomas Meldrum
   ,91341081 --Justin Diggs
   ,4426032 --Fran Koerner
   ,45024231 --Anne Scobell
   ,43486541 --Scott Cooper
   ,5102581 --Scott Layton
   ,63911361 --Madison Palmer
   ,6781531 --Nicklaus Smith
   ,98945391) --Molly Barcikowski

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
