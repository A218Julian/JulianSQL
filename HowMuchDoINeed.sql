Use Enterprisesub

Declare @Researcher AS INT = '74683051' -- Use Researcher CID Here

Drop Table if exists #Contacts;
Select *
Into #Contacts 
From ContactAudit CA With (NOLOCK)
Where ca.UpdatedByContactID = @Researcher
Order by ca.UpdatedDate DESC;

Drop Table if exists #Properties
SELECT *
Into #Properties 
FROM propertynote PN WITH (NOLOCK)
WHERE pn.UpdatedByContactID = @Researcher
AND pn.Note LIKE '%#Topowner%';

Drop Table if exists #Locations;

Select * 
Into #Locations 
From [EnterpriseAuditing].[audit].[Location] L With (NOLOCK) 
Where L.ActionByContactID = @Researcher;

Drop Table if exists #FundCalls

Select CA.CostarContactID,
		ca.ActivityNote,
		ca.LocationID,
		ca.MethodID,
		ca.CreatedDate,
		ca.ContactActivityID
Into #FundCalls
From ContactActivity CA WITH (NOLOCK)
Left JOin Contact C With (NOLOCK) ON c.ContactID = ca.CostarContactID
Where ca.CostarContactID = @Researcher AND ca.ActivityNote LIKE '%#Fund%';


Drop table if exists #CreatedProperties
Select * 
Into #CreatedProperties
From PRoperty PC WITH (NOLOCK)
Where PC.CreatedByContactID = @Researcher
AND (Pc.CountryCode = 'USA'
or Pc.countryCode = 'GBR'
or pc.countrycode = 'CAN');

Drop Table if exists #Intproperties
Select *
Into #Intproperties
From Property P WITH (NOLOCK)
Where P.CreatedByContactID = @Researcher
AND NOT P.CountryCode = 'USA'
AND NOT P.countryCode = 'GBR'
AND NOT p.countrycode = 'CAN';

WITH 
ContactCounts AS (
    SELECT 
        CONVERT(DATE, C.UpdatedDate) as 'Date',
        COUNT(DISTINCT C.ContactID) AS 'ContactIDCount'
    FROM #Contacts C WITH (NOLOCK)
    GROUP BY CONVERT(DATE, C.UpdatedDate)),

TopOwnerCounts AS 
(SELECT 
    CONVERT(DATE, P.UpdatedDate) as 'Date',
        COUNT(P.PropertyID) AS 'Properties'
    FROM #Properties P WITH (NOLOCK)
    GROUP BY CONVERT(DATE, P.UpdatedDate)),

Locations AS 
(Select CONVERT(DATE, Lo.ActionDate) as 'Date',
        COUNT(DISTINCT Lo.LocationID) AS 'LocIDCount'
        From #Locations LO with (NOLOCK)
        Group By CONVERT(DATE, Lo.ActionDate)),

FundCalls AS 
(Select CONVERT(DATE, FC.createddate) as 'Date',
		Count (Distinct FC.contactactivityID) AS 'Fund Calls'
		From #FundCalls FC WITH (NOLOCK)
		Group by CONVERT(DATE, FC.createddate)),

CreatedProperties AS
(Select CONVERT(DATE, cp.CreatedDate) as 'Date',
        COUNT(DISTINCT cp.PropertyID) AS 'PID count'
        From #CreatedProperties CP with (NOLOCK)
        Group By CONVERT(DATE, cp.CreatedDate)),

IntProperties AS
(Select CONVERT(DATE, IP.CreatedDate) as 'Date',
        COUNT(DISTINCT IP.PropertyID) AS 'IPID count'
        From #IntProperties IP with (NOLOCK)
        Group By CONVERT(DATE, IP.CreatedDate))

SELECT 
    COALESCE(CC.Date, TOC.Date, LO.date) as 'Date',
	ISNULL(fc.[Fund Calls], 0) AS 'Fund Calls',
    ISNULL(CC.ContactIDCount, 0) AS 'ContactIDCount',
    ISNULL (LO.LocIDCount,0) AS 'LocIDCount',
    ISNULL(TOC.[Properties], 0) AS 'Properties',
	ISNULL(CP.[PID count], 0) AS 'Created Properties',
	ISNULL(IP.[IPID COUNT],0) As 'International Properties',
    (ISNULL(CC.ContactIDCount, 0) + ISNULL(TOC.[Properties], 0) + ISNULL (LO.LocIDCount,0)) AS 'Total Count',
	42 - ((ISNULL(TOC.[Properties], 0)) + ((ISNULL (LO.LocIDCount, 0) * .5)) + ((ISNULL(CP.[PID count], 0) *1.25)) + ((ISNULL(IP.[IPID count], 0) *1.5)) + ((ISNULL(CC.ContactIDCount, 0)) * .79245283))  AS 'Properties Needed',
	53 - ((ISNULL(CC.ContactIDCount, 0))  + ((ISNULL(TOC.[Properties], 0) + ((ISNULL(IP.[IPID count], 0) *1.5)) + ((ISNULL(CP.[PID count], 0) *1.25)) + ((ISNULL (LO.LocIDCount, 0)) * .5)) /.79245283)) As ' Contacts Needed',
	84 - ((ISNULL (LO.LocIDCount, 0)) + ((ISNULL(TOC.[Properties], 0) + ((ISNULL(IP.[IPID count], 0) *1.5)) + (ISNULL(CP.[PID count], 0) *1.25) + ((ISNULL(CC.ContactIDCount, 0) * .79245283))) / .5)) AS 'Locs Needed'
FROM ContactCounts CC WITH (NOLOCK)
Full JOIN TopOwnerCounts TOC WITH (NOLOCK) ON CC.Date = TOC.Date
Full JOIN Locations LO WITH (NOLOCK) ON Lo.Date = TOC.Date
Full JOin CreatedProperties CP WITH (NOLOCK) ON CP.Date = Toc.Date
Full Join Intproperties IP WITH (NOLOCK) ON IP.Date = toc.date
Left Join FundCalls FC WITH (NOLOCK) ON FC.Date = TOC.Date
Where COALESCE(CC.Date, TOC.Date, LO.date) > '2023-08-01'							-- Enter desired date here 
ORDER BY 'Date' DESC;