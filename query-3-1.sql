WITH total_users AS (
    SELECT COUNT(*) AS total_users
    FROM Users
),
users_with_trips AS (
    SELECT COUNT(DISTINCT UserKey) AS users_with_trips
    FROM BicycleTrips
)
SELECT 
    1 - (users_with_trips::float / total_users::float) AS proportion_users_without_trips
FROM 
    users_with_trips, total_users;
