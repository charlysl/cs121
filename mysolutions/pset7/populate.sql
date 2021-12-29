/*
4a) Populate resource_dim.
Write an INSERT...SELECT statement that populates the non- primary-key 
columns with only distinct combinations of values that appear in the 
raw web logs.
Insert all distinct combinations of ip_addr and visit_val that appear
in the raw web logs.
*/

INSERT INTO resource_dim 
SELECT NULL, resource, method, protocol, response
FROM raw_web_log
GROUP BY resource, method, protocol, response;
/*
SELECT COUNT(*) FROM resource_dim;
33462
*/

/*
Populate visitor_dim
Write an INSERT...SELECT statement that populates the non- primary-key 
columns with only distinct combinations of values that appear in the 
raw web logs.
*/

INSERT INTO visitor_dim 
SELECT NULL, MIN(ip_addr), visit_val
FROM raw_web_log
GROUP BY visit_val;
-- 320435 row(s)

/*
Populate datetime_dim

Dates and times are normally maintained in separate dimension tables, 
but since our data warehouse is so small, we keep them together in one table.
*/

-- Populates table datetime_dim with all dates and hours
-- between d_start and d_end inclusive.
DELIMITER !
CREATE PROCEDURE populate_dates(d_start DATE, d_end DATE) BEGIN
  DECLARE d DATE;
  DECLARE h INTEGER;
  
  -- Delete all rows whose date_val is between d_start and d_end. 
  DELETE FROM datetime_dim WHERE date_val BETWEEN d_start AND d_end;
  
  SET d = d_start;
  WHILE d <= d_end
  DO
    SET h = 0;
    WHILE h <= 23 DO
      INSERT INTO datetime_dim 
        VALUES (NULL, d, h, is_weekend(d), is_holiday(d));
      SET h = h + 1;
    END WHILE;
    SET d = d + INTERVAL 1 DAY;
  END WHILE;
END ! 
DELIMITER ;

/*
SELECT DATE(MIN(logtime)), DATE(MAX(logtime)) FROM raw_web_log;
1995-07-01, 1995-08-31
*/
CALL populate_dates('1995-07-01', '1995-08-31');
/*
SELECT COUNT(*) FROM datetime_dim;
1584
*/

/*
Problem 5a) Populate resource_fact
*/
SET interactive_timeout = 300; 
SET wait_timeout = 300;

INSERT INTO resource_fact
SELECT date_id, resource_id, COUNT(r.resource), SUM(bytes_sent)
FROM raw_web_log AS l
JOIN datetime_dim
  ON date_val = DATE(logtime) AND 
     hour_val = HOUR(logtime)
JOIN resource_dim AS r
  ON r.resource <=> l.resource AND 
     r.method   <=> l.method   AND 
     r.protocol <=> l.protocol AND 
     r.response <=> l.response
GROUP BY date_id, resource_id
;

/*
Populating resource_fact with the full dataset:
• Takes around 2 minute 30 seconds to populate.
• Inserts 788,524 records.

ACTUAL: 788524 row(s) affected Records: 788524  Duplicates: 0  Warnings: 0	90.084 sec

• If you run this query:

SELECT date_id, COUNT(*) AS c 
FROM resource_fact 
GROUP BY date_id 
ORDER BY c DESC 
LIMIT 3;

Assuming that you generate the same ID values, you should get 
{ (300, 1218), (111, 1179), (304, 1167) }. 
If you have different ID values, the second number in each pair should 
at least be the same.

ACTUAL: OK
396, 1218
207, 1179
400, 1167
*/

/*
Problem 5b) Populate visitor_fact
*/

INSERT INTO visitor_fact
SELECT date_id, visitor_id, COUNT(l.resource), SUM(bytes_sent)
FROM raw_web_log AS l
JOIN datetime_dim
  ON date_val = DATE(logtime) AND 
     hour_val = HOUR(logtime)
JOIN visitor_dim AS v
  ON v.visit_val <=> l.visit_val
GROUP BY date_id, visitor_id
;

/*
Populating visitor_fact with the full dataset:
• Takes around 2 minutes to populate.
• Inserts 353,020 records.

ACTUAL: 353020 row(s) affected   Ok

• If you run this query:

SELECT date_id, COUNT(*) AS c 
FROM visitor_fact 
GROUP BY date_id 
ORDER BY c DESC 
LIMIT 3;

Again, assuming that you generate the same ID values, you should get 
{ (298, 1173), (299, 1021), (300, 893) }.

ACTUAL:
394, 1173
395, 1021
396, 893
*/


