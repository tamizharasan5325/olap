CREATE MATERIALIZED VIEW TripsCube AS
-- CTE para calcular los TotalTrips por estación
WITH StationTrips AS (
    SELECT 
        StationKey,
        COUNT(*) AS TotalTrips
    FROM (
        SELECT StartStation AS StationKey FROM BicycleTrips
        UNION ALL
        SELECT EndStation AS StationKey FROM BicycleTrips
    ) AS Trips
    GROUP BY StationKey
)

-- Consulta principal para el CUBE
SELECT
    c.CommuneKey AS CommuneKey,
    n.NeighbourhoodKey AS NeighbourhoodKey,
    s.StationKey AS StationKey,
    SUM(st.TotalTrips) AS TotalTrips
FROM
    StationTrips st
LEFT JOIN Stations s ON st.StationKey = s.StationKey
LEFT JOIN Coordinates co ON s.CoordinateKey = co.CoordinateKey
LEFT JOIN Neighbourhood n ON co.NeighbourhoodKey = n.NeighbourhoodKey
LEFT JOIN Commune c ON n.CommuneKey = c.CommuneKey
GROUP BY CUBE(c.CommuneKey, n.NeighbourhoodKey, s.StationKey);
