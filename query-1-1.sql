WITH station_usage AS (
    SELECT StartStation AS station_id, COUNT(*) AS usage_count
    FROM BicycleTrips
    GROUP BY StartStation

    UNION ALL

    SELECT EndStation AS station_id, COUNT(*) AS usage_count
    FROM BicycleTrips
    GROUP BY EndStation
),
total_station_usage AS (
    SELECT station_id, SUM(usage_count) AS total_usage
    FROM station_usage
    GROUP BY station_id
)
SELECT s.Name AS station_name, tsu.total_usage
FROM total_station_usage tsu
JOIN Stations s ON tsu.station_id = s.StationKey
ORDER BY tsu.total_usage ASC
LIMIT 10;
