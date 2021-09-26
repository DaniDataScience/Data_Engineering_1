/*Exercise 1*/
CREATE TABLE employee(
	id INT NOT NULL,
    employee_name VARCHAR(50) NOT NULL, PRIMARY KEY(id)
    );
/*Answer: Table is created.*/

/*Exercise 2*/
SELECT state FROM birdstrikes LIMIT 144,1;
/*Answer: Tennessee*/

/*Exercise 3*/
SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC;
/*Answer: 2000-4-18*/
    
/*Exercise 4*/
SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;
/*Answer: $5,345*/

/*Exercise 5*/
SELECT * FROM birdstrikes WHERE state IS NOT NULL AND state != '' and bird_size IS NOT NULL and bird_size!= '';
/*Answer: Colorado*/

/*Exercise 6*/
SELECT * FROM birdstrikes WHERE state='Colorado' AND (WEEKOFYEAR('flight_date')) = 52;
/*Answer: There are no entries for the 52nd week. I double checked the uploaded CSV and only saw entries up to April 2000. In order for an entry to be in the 52nd week, it would have to be in the last week in Decemeber.*/