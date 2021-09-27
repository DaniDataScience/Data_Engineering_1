/*Exercise 1*/
SELECT id, speed, 
    IF(speed < 100 OR speed IS NULL, 'LOW SPEED', 'HIGH SPEED')
    AS speed_category
FROM  birdstrikes
ORDER BY speed;

/*Exercise 2*/
SELECT COUNT(DISTINCT aircraft) FROM birdstrikes;
/*Answer 3*/

/*Exercise 3*/
SELECT min(speed) FROM birdstrikes WHERE aircraft LIKE 'H%';
/*Answer 9*/

/*Exercise 4*/
SELECT COUNT(id), phase_of_flight AS count FROM birdstrikes GROUP BY phase_of_flight ORDER BY COUNT(id) ASC LIMIT 1;
/*Answer Taxi*/

/*Exercise 5*/
SELECT ROUND(AVG(cost)), phase_of_flight FROM birdstrikes GROUP BY phase_of_flight ORDER BY ROUND(AVG(cost)) DESC LIMIT 1;
/*Answer Climb*/

/*Exercise 6*/
SELECT AVG(speed), state FROM birdstrikes WHERE length(state) <= 5 GROUP BY state ORDER BY AVG(speed) DESC LIMIT 1;
/*Answer 2,862.5*/