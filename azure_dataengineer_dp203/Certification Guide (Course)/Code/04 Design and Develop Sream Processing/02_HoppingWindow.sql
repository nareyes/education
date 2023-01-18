-- Every 5 seconds, return the count of tweets over the previous 10 seconds
SELECT
    Topic
    , COUNT (*) AS CountTweets
FROM TwitterStream
TIMESTAMP BY CreatedAt 
GROUP BY
    Topic
    , HoppingWindow (SECOND, 10, 5); -- (Timeunit, Window, Hop)