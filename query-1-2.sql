WITH trip_start AS (
    SELECT s.CoordinateKey, COUNT(*) AS trip_count
    FROM BicycleTrips bt
    JOIN Stations s ON bt.StartStation = s.StationKey
    GROUP BY s.CoordinateKey
),
trip_end AS (
    SELECT s.CoordinateKey, COUNT(*) AS trip_count
    FROM BicycleTrips bt
    JOIN Stations s ON bt.EndStation = s.StationKey
    GROUP BY s.CoordinateKey
),
total_trips AS (
    SELECT CoordinateKey, SUM(trip_count) AS total_trip_count
    FROM (
        SELECT * FROM trip_start
        UNION ALL
        SELECT * FROM trip_end
    ) AS combined_trips
    GROUP BY CoordinateKey
),
neighbourhood_trips AS (
    SELECT n.Name AS neighbourhood_name, SUM(tt.total_trip_count) AS trip_count
    FROM total_trips tt
    JOIN Coordinates c ON tt.CoordinateKey = c.CoordinateKey
    JOIN Neighbourhood n ON c.NeighbourhoodKey = n.NeighbourhoodKey
    GROUP BY n.Name
)
SELECT 
    neighbourhood_name, 
    trip_count,
    RANK() OVER (ORDER BY trip_count DESC) AS ranking
FROM neighbourhood_trips
ORDER BY ranking;
