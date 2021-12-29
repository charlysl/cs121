/*
6a) Write a query that reports each distinct HTTP protocol value, 
along with the total number of requests using that protocol value. 
Order your results by descending “total requests” count, and only 
include the top 10 results. 
(Solution’s query takes about 15 seconds to execute.)
(HTTP/1.1 doesn’t appear because it was introduced in 1999. 
Also, you will notice some really wonky HTTP protocol values – 
web browsers were pretty buggy back in 1995, since this whole 
“World Wide Web” thing was pretty new!)
*/
SELECT protocol, SUM(num_requests) AS total_requests
FROM resource_fact
NATURAL JOIN resource_dim
GROUP BY protocol
ORDER BY total_requests DESC
LIMIT 10;
/* 5.222 sec
'HTTP/1.0', '3454845'
NULL, '4906'
'HTTP/1.0From:', '1235'
'HTTP/V1.0', '279'
'align=left', '75'
'history/apollo/apollo-13/apollo-13.html', '26'
'/', '22'
'HTTP/*', '13'
'Atlas/Centaur', '11'
'Shield', '10'
*/

/*
6b) Report the top 20 (resource, error response) combinations. 
HTTP response values of 400 or higher indicate an error of some kind. 
The result should contain the resource, the response code, and the count 
of errors for that combination. Order the result by decreasing error count.
*/
SELECT resource, SUM(response) AS error_count
FROM resource_fact
NATURAL JOIN resource_dim
GROUP BY resource, response
HAVING response >= 400
ORDER BY error_count DESC
LIMIT 20;
/* 2.221 sec
/pub/winvn/readme.txt, 365620
/pub/winvn/release.txt, 334512
/shuttle/missions/STS-69/mission-STS-69.html, 154328
/shuttle/missions/sts-68/ksc-upclose.gif, 121200
/://spacelink.msfc.nasa.gov, 113524
/elv/DELTA/uncons.htm, 97768
/images/crawlerway-logo.gif, 89688
/shuttle/resources/orbiters/atlantis.gif, 88476
/shuttle/resources/orbiters/discovery.gif, 76760
/history/apollo/apollo-13.html, 69084
/history/apollo/a-001/a-001-patch-small.gif, 57772
/shuttle/resources/orbiters/challenger.gif, 53328
/robots.txt, 51712
/shuttle/missions/technology/sts-newsref/stsref-toc.html, 51308
/history/apollo/pad-abort-test-1/pad-abort-test-1-patch-small.gif, 49692
/shuttle/missions/sts-71/images/KSC-95EC-0916.txt, 48480
/history/apollo/sa-1/sa-1-patch-small.gif, 44036
/history/apollo/images/little-joe.jpg, 42824
/images/lf-logo.gif, 39188
/history/apollo/publications/sp-350/sp-350.txt~, 34340
*/

/*
 Find the top 20 clients based on total bytes sent to each client. 
 Your result should include:
• the IP address of the client
• the number of visits the client made
 (i.e. number of distinct visit_val values for the client)
• the total requests made by the client
• the total bytes sent to that client
Order the results by decreasing "total bytes sent", and include only 
the top 20 results.
(Solution’s query takes about 33 seconds to execute.)
(Prodigy2 was the most popular Internet Service Provider at the time.)
*/
SELECT ip_addr, 
       COUNT(DISTINCT visit_val) AS num_visits, 
       SUM(num_requests) AS total_requests,
       SUM(total_bytes) AS num_bytes
FROM visitor_fact
NATURAL JOIN visitor_dim
GROUP BY ip_addr
ORDER BY num_bytes DESC
LIMIT 20;
/* 4.812 sec
piweba3y.prodigy.com, 655, 21988, 523915427
piweba1y.prodigy.com, 640, 12825, 328618131
piweba4y.prodigy.com, 665, 16437, 327110913
news.ti.com, 431, 8161, 272130709
alyssa.prodigy.com, 205, 8037, 214450314
e659229.boeing.com, 361, 6720, 209005351
piweba2y.prodigy.com, 501, 7246, 189580108
webgate1.mot.com, 361, 6749, 177873757
163.206.89.4, 314, 9697, 175165356
poppy.hensa.ac.uk, 369, 6428, 173872133
www-d4.proxy.aol.com, 667, 7211, 171158379
163.206.137.21, 152, 2787, 170602889
www-b5.proxy.aol.com, 637, 7080, 166644968
www-b3.proxy.aol.com, 667, 7218, 165547760
www-a2.proxy.aol.com, 685, 7516, 164764633
www-b2.proxy.aol.com, 676, 7266, 163405809
www-a1.proxy.aol.com, 668, 6661, 160219337
www-d3.proxy.aol.com, 674, 6895, 158527568
www-d1.proxy.aol.com, 704, 8047, 156989958
www-relay.pa-x.dec.com, 370, 4896, 156655329
*/

/*
6d) Write a query that reports the daily request-total and the total bytes 
served, for each day starting on July 23, 1995 (a Sunday), and ending on 
August 12, 1995 (a Saturday). The query result should include the date of 
each day (datetime_dim.date_val would be fine), the total number of 
requests on that day, and the total number of bytes served on that day. 
Make sure that every day in this date-range actually appears in the result!

You should notice couple of gaps in that time period. One of the gaps has 
a good reason; what caused this gap? 
(Hint: See the web page mentioned at the start of the assignment, 
where the NASA logs were retrieved from.) 
Include your answer to this question, as a comment before the query. 
(The other gap has no explanation. Make sure you identify which gap is 
which.)
*/
SELECT date_val, 
       SUM(num_requests) AS request_total, 
       SUM(total_bytes) AS bytes_served
FROM resource_fact AS f
RIGHT JOIN datetime_dim AS d
  ON f.date_id = d.date_id
GROUP BY date_val
HAVING date_val BETWEEN DATE('1995-07-23') AND DATE('1995-08-12')
;
/* 2.429 sec
'1995-07-23', '39199', '766191614'
'1995-07-24', '64259', '1213143555'
'1995-07-25', '62699', '1148520557'
'1995-07-26', '58849', '1041367234'
'1995-07-27', '61680', '1124849017'
'1995-07-28', '27121', '489187736'
'1995-07-29', NULL, NULL
'1995-07-30', NULL, NULL
'1995-07-31', NULL, NULL
'1995-08-01', '33996', '529321719'
'1995-08-02', NULL, NULL
'1995-08-03', '41388', '732953605'
'1995-08-04', '59557', '1109750886'
'1995-08-05', '31893', '613609454'
'1995-08-06', '32420', '634115309'
'1995-08-07', '57362', '957845030'
'1995-08-08', '60157', '1063204146'
'1995-08-09', '60458', '980865711'
'1995-08-10', '61248', '1034849598'
'1995-08-11', '61246', '1102726342'
'1995-08-12', '38071', '695596219'

Quoted from (**highlight** is mine)
https://web.archive.org/web/19980110125550/https://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html
"""
Distribution
Available from the Archive in **Jul 01 to Jul 31**, 
ASCII format, 20.7 MB gzip compressed, 205.2 MB uncompressed, 
and **Aug 04 to Aug 31**, 
ASCII format, 21.8 MB gzip compressed, 167.8 MB uncompressed.
"""
*/

/*
6e) For each day that appears in the data-set, report the resource that 
generated the largest “total bytes served” for that day. 
The result should include the date, the resource, the total number of 
requests for that resource, and the total bytes served for the resource 
during that day. Order the results by increasing date value. 
Don’t worry about including the dates for which there are no log records.

Important Note: a given resource can have multiple resource_id values 
associated with it, if the method, protocol or response was different 
when the resource was accessed. 
For example, the resource /shuttle/countdown/count.gif has four 
resource_id values. Therefore, your query must group on resources, 
not resource IDs.

To double-check your answers, here are some partial results:
• For 1995-07-03, the number of requests is 204, and total bytes is 143,209,714. 
'1995-07-03', '143209714', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '204'
• For 1995-07-10, the number of requests is 123, and total bytes is 91,171,362. 
'1995-07-10', '91171362', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '123'
• For 1995-08-07, the number of requests is 858, and total bytes is 37,037,014. 
'1995-08-07', '37037014', '/shuttle/missions/sts-69/count69.gif', '858'
• For 1995-08-29, the number of requests is 96, and total bytes is 69,974,274.
'1995-08-29', '69974274', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '96'
*/
CREATE TEMPORARY TABLE daily_bytes AS
SELECT date_val, resource, 
       SUM(num_requests) AS total_requests, 
       SUM(total_bytes) AS bytes_served
FROM resource_fact
NATURAL JOIN datetime_dim
NATURAL JOIN resource_dim
GROUP BY date_val, resource
;

CREATE TEMPORARY TABLE max_daily_bytes AS
SELECT date_val, MAX(bytes_served) AS bytes_served
FROM daily_bytes
GROUP BY date_val
;

SELECT *
FROM daily_bytes
NATURAL JOIN max_daily_bytes
;

/*
'1995-07-01', '108594472', '/shuttle/missions/sts-71/movies/sts-71-mir-dock.mpg', '151'
'1995-07-02', '95840885', '/shuttle/missions/sts-71/movies/sts-71-mir-dock.mpg', '131'
'1995-07-03', '143209714', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '204'
'1995-07-04', '106875368', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '133'
'1995-07-05', '136225174', '/shuttle/countdown/count.gif', '3637'
'1995-07-06', '135784820', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '163'
'1995-07-07', '103511756', '/shuttle/missions/sts-71/movies/sts-71-tcdt-crew-walkout.mpg', '201'
'1995-07-08', '70913156', '/shuttle/missions/sts-71/movies/sts-71-tcdt-crew-walkout.mpg', '127'
'1995-07-09', '36367114', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '45'
'1995-07-10', '91171362', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '123'
'1995-07-11', '108309718', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '148'
'1995-07-12', '124256484', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '164'
'1995-07-13', '225480667', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '414'
'1995-07-14', '122522431', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '212'
'1995-07-15', '49969107', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '86'
'1995-07-16', '54261715', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '102'
'1995-07-17', '60421616', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '132'
'1995-07-18', '42567170', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '74'
'1995-07-19', '43407705', '/shuttle/countdown/count70.gif', '1023'
'1995-07-20', '50739155', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '89'
'1995-07-21', '45842235', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '88'
'1995-07-22', '26000281', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '41'
'1995-07-23', '30494219', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '52'
'1995-07-24', '33664867', '/shuttle/missions/sts-70/movies/sts-70-landing.mpg', '38'
'1995-07-25', '31895051', '/shuttle/missions/sts-70/movies/sts-70-launch.mpg', '52'
'1995-07-26', '27600950', '/shuttle/countdown/count70.gif', '642'
'1995-07-27', '28619943', '/shuttle/countdown/count70.gif', '656'
'1995-07-28', '14001634', '/shuttle/countdown/count70.gif', '325'
'1995-08-01', '15395335', '/shuttle/countdown/count70.gif', '361'
'1995-08-03', '24201302', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '39'
'1995-08-04', '75352668', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '92'
'1995-08-05', '36735754', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '48'
'1995-08-06', '31929300', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '36'
'1995-08-07', '37037014', '/shuttle/missions/sts-69/count69.gif', '858'
'1995-08-08', '70120980', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '82'
'1995-08-09', '52210384', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '77'
'1995-08-10', '73779804', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '93'
'1995-08-11', '54615082', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '70'
'1995-08-12', '49702882', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '71'
'1995-08-13', '49695440', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '70'
'1995-08-14', '79632584', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '99'
'1995-08-15', '61630376', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '77'
'1995-08-16', '59132566', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '70'
'1995-08-17', '62975364', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '84'
'1995-08-18', '49432546', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '64'
'1995-08-19', '46068634', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '71'
'1995-08-20', '32977876', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '55'
'1995-08-21', '48670690', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '64'
'1995-08-22', '61557398', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '73'
'1995-08-23', '55563854', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '78'
'1995-08-24', '61908904', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '77'
'1995-08-25', '67897256', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '86'
'1995-08-26', '42662262', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '58'
'1995-08-27', '31372994', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '50'
'1995-08-28', '50719440', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '68'
'1995-08-29', '69974274', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '96'
'1995-08-30', '92923700', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '116'
'1995-08-31', '112762416', '/shuttle/missions/sts-71/movies/sts-71-launch.mpg', '148'
*/