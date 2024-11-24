WITH trip_durations AS (                                                                            
    SELECT 
        bt.UserKey,
        EXTRACT(EPOCH FROM (bt.EndDate - bt.StartDate)) / 3600 AS duration_hours
    FROM BicycleTrips bt
),
age_groups AS (
    SELECT
        u.UserKey,
        u.Age,
        FLOOR(u.Age / 10) * 10 AS age_group_start
    FROM Users u
),
total_hours_per_age_group AS (
    SELECT 
        ag.age_group_start,
        SUM(td.duration_hours) AS total_hours
    FROM trip_durations td
    JOIN age_groups ag ON td.UserKey = ag.UserKey
    GROUP BY ag.age_group_start
)
SELECT
    age_group_start,
    total_hours
FROM total_hours_per_age_group
ORDER BY total_hours DESC;
