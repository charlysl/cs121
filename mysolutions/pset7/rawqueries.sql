/*
2a) Return a count of the total number of rows in the raw_web_log table.
*/
SELECT COUNT(*) FROM raw_web_log;
-- 3461612

/*
2b) For each IP address in the log data, compute the total number of 
requests from that IP address. Your query should return the top 20 IP 
addresses along with how many requests each one made. Order the results 
in descending order of request-counts. Give the request-count a meaningful 
name.
*/
SELECT ip_addr, COUNT(*) AS num_requests
FROM raw_web_log
GROUP BY ip_addr
ORDER BY num_requests DESC
LIMIT 20;

/*
piweba3y.prodigy.com, 21988
piweba4y.prodigy.com, 16437
piweba1y.prodigy.com, 12825
edams.ksc.nasa.gov, 11964
163.206.89.4, 9697
news.ti.com, 8161
www-d1.proxy.aol.com, 8047
alyssa.prodigy.com, 8037
siltb10.orl.mmc.com, 7573
www-a2.proxy.aol.com, 7516
www-b2.proxy.aol.com, 7266
piweba2y.prodigy.com, 7246
www-b3.proxy.aol.com, 7218
www-d4.proxy.aol.com, 7211
www-b5.proxy.aol.com, 7080
www-d2.proxy.aol.com, 6984
www-b4.proxy.aol.com, 6972
www-d3.proxy.aol.com, 6895
webgate1.mot.com, 6749
e659229.boeing.com, 6720
*/

/*
2c) Write a query that computes, for each resource:
• The total number of requests for that resource. 
(This will simply be the number of log records that specify the resource.)
• The total number of bytes served for that resource. 
(This is in the bytes_sent column.)
Your query should return the top 20 resources, 
ordered by decreasing “total bytes served,” 
and should include the resource, the total requests for that resource, 
and the total bytes served for that resource. 
*/

SELECT resource, 
       COUNT(resource) AS num_requests, 
       SUM(bytes_sent) AS total_bytes_served
FROM raw_web_log
GROUP BY resource
ORDER BY total_bytes_served DESC
LIMIT 20;

/*
/shuttle/missions/sts-71/movies/sts-71-launch.mpg, 4142, 3196457118
/shuttle/missions/sts-71/movies/sts-71-mir-dock.mpg, 1988, 1409035595
/shuttle/missions/sts-71/movies/sts-71-tcdt-crew-walkout.mpg, 2197, 1137114616
/shuttle/missions/sts-70/movies/sts-70-launch.mpg, 1988, 1098853893
/shuttle/technology/sts-newsref/stsref-toc.html, 13939, 1061408730
/shuttle/missions/sts-53/movies/sts-53-launch.mpg, 1148, 1034715432
/shuttle/missions/sts-69/count69.gif, 24383, 1006019900
/shuttle/countdown/video/livevideo2.gif, 16856, 981889941
/shuttle/countdown/count70.gif, 21417, 920630117
/shuttle/countdown/count.gif, 22237, 829910080
/shuttle/missions/sts-71/movies/sts-71-mir-dock-2.mpg, 1244, 772631390
/shuttle/missions/sts-71/movies/crew-arrival-t38.mpg, 3250, 764436680
/shuttle/missions/sts-70/movies/woodpecker.mpg, 4117, 670412269
/shuttle/missions/sts-71/movies/sts-71-landing.mpg, 844, 667725300
/images/rss.gif, 2804, 657538873
/images/ksclogo-medium.gif, 121580, 629750296
/shuttle/missions/sts-70/movies/sts-70-launch-press.mpg, 746, 618865665
/shuttle/countdown/video/livevideo.gif, 10168, 575252793
/ksc.html, 83953, 563742661
/history/apollo/apollo-13/movies/apo13damage.mpg, 2087, 519087083
*/

/*
2d) Web server logs record individual requests for resources, 
but we would also like to know how many “visits” we get to our website. 
Two web-server requests are part of the same “visit” if they are from 
the same client (i.e. same ip_addr value), and if the request times 
are within 20 minutes of each other. 
Correspondingly, if there are two requests from the same client, 
and they are more than 20 minutes apart, they are considered to be 
two separate visits to the website. (20 minutes is a bit of an 
arbitrary number. 
Probably the only meaningful values would be somewhere between 15 minutes 
and 1 hour.)
It turns out to be prohibitively expensive to have a simple relational 
database figure out what log records correspond to what “visits” 
(it requires a self-join with multiple inequality conditions, 
much like our “dense rank” query), so the log data has been annotated 
with a “visit_val” value. Multiple requests are part of the same visit 
if they have the same value for the visit_val column. 
In addition, all visit_val values in our log data are unique;
if the values are different then the records correspond to different 
visits.
Write a query that computes these values for each visit:
• The total number of requests made during that visit.
• The starting time of the visit (this will be the minimum request-time).
• The ending time of the visit (this will be the maximum request-time).
Your result should include five columns:
• The visit value
• The IP address of the requester
• The total number of requests in the visit
• The starting time of the visit
• The ending time of the visit

Order your results by decreasing “total requests,” and include only 
the top 20 results. Give all columns meaningful names.
*/

SELECT visit_val, MIN(ip_addr),
       COUNT(resource) AS num_requests, 
       MIN(logtime) AS starting_time,
       MAX(logtime) AS ending_time
FROM raw_web_log
GROUP BY visit_val
ORDER BY num_requests DESC
LIMIT 20;

/*
807356074, siltb10.orl.mmc.com, 2843, 1995-07-13 20:12:13, 1995-07-17 02:00:40
807334417, bill.ksc.nasa.gov, 2711, 1995-07-11 08:16:24, 1995-07-12 14:54:37
807336099, indy.gradient.com, 2320, 1995-07-11 12:48:21, 1995-07-12 15:47:46
807401527, currypc.fpl.msstate.edu, 1919, 1995-07-21 16:40:23, 1995-07-24 10:17:09
807389341, siltb10.orl.mmc.com, 1835, 1995-07-19 17:09:54, 1995-07-21 10:32:16
807338170, marina.cea.berkeley.edu, 1429, 1995-07-11 17:12:57, 1995-07-12 09:28:59
807575184, beta.xerox.com, 1284, 1995-08-30 19:10:08, 1995-08-31 09:30:40
807287193, piweba3y.prodigy.com, 1204, 1995-07-04 07:35:13, 1995-07-05 02:06:06
807347497, rush.internic.net, 1116, 1995-07-13 00:59:54, 1995-07-13 04:19:12
807346358, nidhogg.srl.caltech.edu, 999, 1995-07-12 20:32:40, 1995-07-13 07:56:28
807565021, 163.206.89.4, 989, 1995-08-29 10:35:47, 1995-08-29 17:07:37
807372199, siltb10.orl.mmc.com, 902, 1995-07-17 02:45:44, 1995-07-18 03:25:33
807578165, goose.sms.fi, 812, 1995-08-31 08:16:17, 1995-08-31 11:13:58
807362012, piweba4y.prodigy.com, 703, 1995-07-14 15:48:51, 1995-07-14 23:48:51
807548632, mac998.kip.apple.com, 650, 1995-08-25 14:27:59, 1995-08-25 21:44:33
807349395, vagrant.vf.mmc.com, 649, 1995-07-13 08:42:33, 1995-07-13 12:50:09
807362726, piweba3y.prodigy.com, 621, 1995-07-14 17:26:51, 1995-07-15 02:35:56
807510405, 139.169.174.102, 603, 1995-08-17 18:19:53, 1995-08-17 21:30:10
807416996, jbiagioni.npt.nuwc.navy.mil, 589, 1995-07-25 11:01:45, 1995-07-25 15:01:01
807571559, electron.mcc.com, 571, 1995-08-30 10:38:13, 1995-08-30 17:05:42
*/

