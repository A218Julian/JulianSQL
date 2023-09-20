Declare @MetricMonth varchar(45) = '202308'
Declare @Director varchar(45) = 'Jeff Miles'

;With ContactName as 
(	 Select Distinct
    Contactid,
    firstName + ' ' + lastName as [Listing Contact]
    From Enterprise.dbo.contact C (nolock)
    where countrycode = 'USA'
    and c.LocationID is not null
),

BrokerContacts As
(
    SELECT DISTINCT
          LBM.[LocationID],
          LBM.[ContactID],
          LBM.[MetricMonthCD],
          LBM.[ListingManagerUsagePct],
          LBM.[ActivitiesOrCallToCount],
          LBM.TotalPortfolioCalls as CallAttempts
      FROM ResearchMetricsSub.WallBoard.LocationBrokerMetric as LBM (nolock) 
      Where 1=1
      and LBM.QualifiedBrokerToCall = 1
      And MetricMonthCD = @MetricMonth
),

Calls As 

(
Select wc.ContactID,
	wc.ResearcherContactID,
	wc.CreatedDate,
	c.LocationID

From ResearchMetricsSub.WallBoardStaging.CTICalls WC WITH (NOLOCK) 
Left Join enterprise.dbo.Contact C WITH (NOLOCK) On C.ContactID = wc.ContactID
)

SELECT 
    BC.ContactID,
    T.MetricMonthCD,
    T.LocationID,
    cast((Cast(ContactsUpdated as float)/cast(nullif(Contacts,0) as float)) as decimal(10,2)) as '%LocationComplete',
    T.LocationName,
    T.Name,
    T.[Manager Name],
    T.[Director Name],
    case when BC.[ActivitiesOrCallToCount] = 1 then 'Y' else 'N' end as ContactComplete,
    BC.ListingManagerUsagePct,
    C.[Listing Contact],
    BC.CallAttempts,
    case when T.NewCostarSelectContacts >= 1 then 'Y' else 'N' end as SelectAccount,
    MAX(ca.CreatedDate) as 'Date Last Called'

FROM 
    ResearchStrategy.Portfolio.TemporaryNewCUF as T (nolock)
    LEFT OUTER JOIN BrokerContacts as BC (nolock) ON BC.LocationID = T.LocationID 
    LEFT JOIN ContactName as C (nolock) ON C.ContactID = BC.ContactID
    LEFT JOIN Calls CA WITH (NOLOCK) ON ca.contactid = bc.contactid
WHERE 
    T.MetricMonthCD = @MetricMonth
    AND T.[Director Name] = @Director 
    AND T.[Manager Name] is not null
GROUP BY 
    BC.ContactID,
    T.MetricMonthCD,
    T.LocationID,
    T.LocationName,
    T.Name,
    T.[Manager Name],
    T.[Director Name],
    BC.[ActivitiesOrCallToCount],
    BC.ListingManagerUsagePct,
    C.[Listing Contact],
    BC.CallAttempts,
    T.NewCostarSelectContacts,
    T.ContactsUpdated, 
    T.Contacts           
ORDER BY 
    T.[Manager Name], T.Name, T.locationid;


