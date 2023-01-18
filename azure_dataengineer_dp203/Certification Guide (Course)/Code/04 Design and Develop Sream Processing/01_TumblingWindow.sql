-- Return the count of tweets per time zone, every 10 seconds
SELECT
    TimeZone
    , COUNT (*) AS CountTweets
FROM TwitterStream
TIMESTAMP BY CreatedAt
GROUP BY 
    TimeZone
    , TumblingWindow (Second, 10); -- (TimeUnit, Window)