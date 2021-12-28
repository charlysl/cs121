INSERT INTO customer VALUES (0, 'The', 'Purchaser', 'p@a.com', '123');
INSERT INTO purchaser VALUES (1);
INSERT INTO customer VALUES (NULL, 'The', 'Traveller', 't@a.com', '456');
INSERT INTO traveller VALUES (2, NULL);
INSERT INTO aircraft VALUES ('380', 'Airbus', 'A380');
INSERT INTO aircraft VALUES ('744', 'Boeing', '747-400');
INSERT INTO seat VALUES ('380', '34A', 'F', 'W', 0);
INSERT INTO flight VALUES 
  ('QF11', '2007-05-21', '14:10:00', 'SGN', 'MAD', 1, '380');
INSERT INTO purchase VALUES (NULL, 1, NOW(), '111111');
INSERT INTO ticket VALUES 
  (NULL, 500, 'QF11', '2007-05-21', '380', '34A', 1, 2);

-- a) We need to provide a way to display all the purchase history for a single customer via the company website. To demonstrate how this will work, write a SQL query that will retrieve all purchases and associated ticket information for the customer (aka “purchaser”) with ID 54321. The results should be ordered by these columns:
-- purchase date (descending order), flight date, traveler last name, -- -- traveler first name (all other columns ascending order).
SELECT *
FROM purchaser AS p
NATURAL JOIN purchase
JOIN ticket AS t USING(purchase_id)
JOIN traveller AS tr
JOIN customer AS trc 
WHERE tr.customer_id = t.customer_id
  AND trc.customer_id = tr.customer_id
  AND p.customer_id = '1'
ORDER BY timestamp DESC, date, trc.last_name, trc.first_name;


  -- b) Write a query that reports that total revenue from ticket sales for each kind of airplane in our flight booking database, generated from flights with a departure time within the last two weeks. Include all kinds of airplanes in the database, whether they were used for flights in the last 2 weeks or not.
SELECT SUM(price) AS total_revenue, a.aircraft_type
FROM ticket AS t
NATURAL JOIN flight AS f
RIGHT JOIN aircraft AS a 
  ON a.aircraft_type = f.aircraft_type
WHERE ticket_id IS NULL OR
      ADDTIME(CONVERT(date, DATETIME), time) <
      DATE_SUB(NOW(), INTERVAL 2 WEEK)
GROUP BY a.aircraft_type
;

-- c) Write a query that reports all travelers on international flights that have not yet specified all of their international flight information.
SELECT t.customer_id
FROM flight
NATURAL JOIN ticket AS t
LEFT JOIN international_info AS ii
  ON t.customer_id = ii.customer_id
WHERE is_inter AND
  ii.customer_id IS NULL;
;