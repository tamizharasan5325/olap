WITH trip_durations AS (                                                                            
    SELECT 
        bt.UserKey,
        EXTRACT(EPOCH FROM (bt.EndDate - bt.StartDate)) / 3600 AS duration_hours
    FROM BicycleTrips bt
),
age_hours AS (
    SELECT 
        u.Age,
        SUM(td.duration_hours) AS total_hours
    FROM Users u
    JOIN trip_durations td ON u.UserKey = td.UserKey
    GROUP BY u.Age
),
age_hours_cumulative AS (
    SELECT 
        Age,
        total_hours,
        SUM(total_hours) OVER (ORDER BY Age) AS cumulative_hours
    FROM age_hours
),
total_hours AS (
    SELECT 
        SUM(total_hours) AS total_hours
    FROM age_hours
),
cut_points AS (
    SELECT 
        ah.Age,
        ah.cumulative_hours,
        th.total_hours,
        (th.total_hours / 3) AS first_cut,
        (2 * th.total_hours / 3) AS second_cut
    FROM age_hours_cumulative ah, total_hours th
)
SELECT 
    MIN(CASE WHEN cumulative_hours >= first_cut THEN Age END) AS first_cut_age,
    MIN(CASE WHEN cumulative_hours >= second_cut THEN Age END) AS second_cut_age
FROM cut_points
WHERE cumulative_hours >= first_cut OR cumulative_hours >= second_cut;
