-- Return count of Tweets that occur within 5 minutes of each other
SELECT
    Topic
    , COUNT (*) AS 
FROM TwitterStream
TIMESTAMP BY CreatedAt 
GROUP BY 
    Topic
    , SessionWindow (Minute, 5, 10); -- (TimeUnit, Timeout, MaxDuration)