WITH user_first_trip AS (
    SELECT 
        u.UserKey,
        u.RegistrationDate,
        MIN(bt.StartDate) AS first_trip_date
    FROM Users u
    JOIN BicycleTrips bt ON u.UserKey = bt.UserKey
    GROUP BY u.UserKey, u.RegistrationDate
),
users_within_7_days AS (
    SELECT 
        u.UserKey,
        u.RegistrationDate,
        MIN(bt.StartDate) AS first_trip_date
    FROM Users u
    JOIN BicycleTrips bt ON u.UserKey = bt.UserKey
    WHERE bt.StartDate <= u.RegistrationDate + INTERVAL '7 days'
    GROUP BY u.UserKey, u.RegistrationDate
)
SELECT 
    COUNT(DISTINCT uw7d.UserKey) AS users_within_7_days,
    COUNT(DISTINCT uft.UserKey) AS total_users_with_trips,
    (COUNT(DISTINCT uw7d.UserKey)::float / COUNT(DISTINCT uft.UserKey)::float) AS proportion_users_within_7_days
FROM 
    user_first_trip uft
LEFT JOIN 
    users_within_7_days uw7d ON uft.UserKey = uw7d.UserKey
WHERE 
    uft.first_trip_date IS NOT NULL;
