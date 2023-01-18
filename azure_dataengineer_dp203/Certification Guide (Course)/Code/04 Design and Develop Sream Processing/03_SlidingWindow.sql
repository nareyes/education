-- Alert whenever a topic is mentioned more than 3 times in 10 seconds
-- All tweets in this example refer to the same topic
SELECT
    TOpic
    , COUNT (*) AS CountTweets
FROM TwitterStream
TIMESTAMP BY CreatedAt 
GROUP BY
    Topic
    , SlidingWindow (Second, 10) -- (TimeUnit, Window)
HAVING COUNT (*) >= 3;