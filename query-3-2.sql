WITH first_trip_dates AS (
    SELECT 
        UserKey, 
        MIN(StartDate) AS first_trip_date
    FROM 
        BicycleTrips
    GROUP BY 
        UserKey
)
SELECT 
    AVG(EXTRACT(EPOCH FROM (ftd.first_trip_date - u.RegistrationDate)) / 3600) AS avg_time_to_first_trip_hours
FROM 
    Users u
JOIN first_trip_dates ftd ON u.UserKey = ftd.UserKey
-- Agregamos este check porque notamos que algunos registros 
-- lo cumplen. No parece ser consistente el dataset de GCBA
WHERE ftd.first_trip_date >= u.RegistrationDate;
