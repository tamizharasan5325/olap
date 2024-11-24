WITH TripDurations AS (
    SELECT 
        EXTRACT(DOW FROM bt.StartDate) AS DayOfWeek,
        EXTRACT(EPOCH FROM (bt.EndDate - bt.StartDate)) / 60 AS DurationMinutes
    FROM 
        BicycleTrips bt
)

SELECT
    DayOfWeek,
    COUNT(*) AS TripCount,
    AVG(DurationMinutes) AS AvgDurationMinutes
FROM
    TripDurations
GROUP BY
    DayOfWeek
ORDER BY
    DayOfWeek;
