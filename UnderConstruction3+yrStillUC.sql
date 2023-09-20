USE Enterprise;

SELECT 
    p.PropertyID AS 'Property ID',
    p.buildingname AS 'Property Name',
    CONCAT(MAX(a.streetnum), ' ', MAX(a.streetname)) AS 'Address',
    Max (a.City) As 'City',
    a.State,
    a.Zip,
    RM.ResearchMarketName AS 'Market',
	Max (Case When pc.ContactRoleID = 7 Then l.LocationName End) As 'Owner Name',
    loc.LocationID AS 'Owner LocID',
    CONCAT(MAX(CASE WHEN PCE.ConstructionEventTypeID = 2 THEN pce.eventmonth END), '/', MAX(CASE WHEN PCE.ConstructionEventTypeID = 2 THEN pce.eventyear END)) AS 'Construction Complete',
    CONCAT(MAX(CASE WHEN PCE.ConstructionEventTypeID = 1 THEN pce.eventmonth END), '/', MAX(CASE WHEN PCE.ConstructionEventTypeID = 1 THEN pce.eventyear END)) AS 'Ground Breaking',
    p.updateddate AS 'Last Updated Date'
FROM
    Property p
    LEFT JOIN PropertyAddress PA ON PA.PropertyID = p.PropertyID
    LEFT JOIN Address a ON a.AddressID = PA.AddressID
    LEFT JOIN ResearchMarket RM ON RM.ResearchMarketID = a.ResearchMarketID
    LEFT JOIN Propertyconstructionevent PCE ON PCE.propertyid = p.PropertyID
    LEFT JOIN (
        SELECT propertyID, MAX(locationID) AS LocationID
        FROM Propertycontact
        GROUP BY propertyID
    ) loc ON loc.propertyID = p.propertyID
    LEFT JOIN Location L ON L.LocationID = Loc.LocationID
	Left Join PropertyContact PC on PC.PropertyID = p.PropertyID
WHERE
    p.ConstructionStatusID = 4 
GROUP BY
    p.PropertyID,
    loc.LocationID,
    p.buildingname,
    RM.ResearchMarketName,
    L.locationname,
    p.UpdatedDate,
    a.city,
    a.State,
    a.Zip
HAVING
   MAX(CASE WHEN PCE.ConstructionEventTypeID = 1 THEN pce.eventyear END) <= YEAR(DATEADD(year, -3, GETDATE()))
ORDER BY CONCAT(MAX(CASE WHEN PCE.ConstructionEventTypeID = 1 THEN pce.eventmonth END), '/', MAX(CASE WHEN PCE.ConstructionEventTypeID = 1 THEN pce.eventyear END)) DESC;
