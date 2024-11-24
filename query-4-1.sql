SELECT 
    AVG(EXTRACT(EPOCH FROM (bt.EndDate - bt.StartDate)) / 60) AS avg_long_trip_duration_minutes
FROM 
    BicycleTrips bt
WHERE 
    EXTRACT(EPOCH FROM (bt.EndDate - bt.StartDate)) / 60 > 30;
