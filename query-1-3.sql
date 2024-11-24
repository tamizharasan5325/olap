WITH station_distances AS (
    SELECT 
        s1.StationKey AS station_id,
        s1.Name AS station_name,
        MIN(ST_Distance(ST_Transform(s1_loc.Location::geometry, 3857), ST_Transform(s2_loc.Location::geometry, 3857))) AS min_distance_meters
    FROM Stations s1
    JOIN Coordinates s1_loc ON s1.CoordinateKey = s1_loc.CoordinateKey
    JOIN Stations s2 ON s1.StationKey != s2.StationKey
    JOIN Coordinates s2_loc ON s2.CoordinateKey = s2_loc.CoordinateKey
    GROUP BY s1.StationKey, s1.Name
    HAVING MIN(ST_Distance(ST_Transform(s1_loc.Location::geometry, 3857), ST_Transform(s2_loc.Location::geometry, 3857))) > 0
),
neighbourhood_distances AS (
    SELECT 
        n.Name AS neighbourhood_name,
        AVG(sd.min_distance_meters) AS avg_min_distance_meters,
        COUNT(sd.station_id) AS station_count
    FROM station_distances sd
    JOIN Stations s ON sd.station_id = s.StationKey
    JOIN Coordinates c ON s.CoordinateKey = c.CoordinateKey
    JOIN Neighbourhood n ON c.NeighbourhoodKey = n.NeighbourhoodKey
    GROUP BY n.Name
)
SELECT
    neighbourhood_name,
    avg_min_distance_meters,
    station_count,
    RANK() OVER (ORDER BY avg_min_distance_meters) AS ranking
FROM neighbourhood_distances
ORDER BY ranking;
