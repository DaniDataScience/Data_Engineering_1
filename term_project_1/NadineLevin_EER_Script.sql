/*
Nadine Levin DE1 2021
US Fatal Police Shootings
Data Downloaded from https://www.kaggle.com/kwullum/fatal-police-shootings-in-the-us and https://corgis-edu.github.io/corgis/csv/state_demographics/
*/

DROP SCHEMA
	IF EXISTS us_fatal_police_shootings;
	CREATE SCHEMA us_fatal_police_shootings;
USE us_fatal_police_shootings;
SET sql_mode = "";
SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS medianhouseholdincome2015_state;

CREATE TABLE `us_fatal_police_shootings`.`medianhouseholdincome2015_state` (
  geographic_area VARCHAR(30),     
  average_medium_income INTEGER NOT NULL 
  );

LOAD DATA INFILE '/tmp/MedianHouseholdIncome2015_state.csv' 
INTO TABLE medianhouseholdincome2015_state FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n' 
IGNORE 1 LINES (geographic_area,city,@median_income) 
SET   
	median_income = NULLIF(@median_income,'')
    ;

DROP TABLE IF EXISTS percentageover25completedhighschool_state;
CREATE TABLE `us_fatal_police_shootings`.`percentageover25completedhighschool_state` (
  geographic_area VARCHAR(30),     
  avg_percent_completed_hs INTEGER NOT NULL 
  );

LOAD DATA INFILE '/tmp/PercentageOver25CompletedHighSchool_state.csv' 
INTO TABLE percentageover25completedhighschool_state FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n' 
IGNORE 1 LINES (geographic_area,city,@avg_percent_completed_hs) 
SET   
	avg_percent_completed_hs = NULLIF(@avg_percent_completed_hs,'')
    ;

DROP TABLE IF EXISTS percentagepeoplebelowpovertylevel_state;
CREATE TABLE `us_fatal_police_shootings`.`percentagepeoplebelowpovertylevel_state` (
  geographic_area VARCHAR(30),     
  avg_poverty_rate INTEGER NOT NULL 
  );

LOAD DATA INFILE '/tmp/PercentagePeopleBelowPovertyLevel_state.csv' 
INTO TABLE percentagepeoplebelowpovertylevel_state FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' LINES TERMINATED BY '\n' 
IGNORE 1 LINES (geographic_area,city,@avg_poverty_rate) 
SET   
	avg_poverty_rate = NULLIF(@avg_poverty_rate,'')
    ;

DROP TABLE IF EXISTS racebreakout_state;
CREATE TABLE `us_fatal_police_shootings`.`racebreakout_state` (
	geographic_area VARCHAR(30),
    native_american	INT,
    asian INT,
	black INT,
	hispanic INT,
	pacific_islander INT,
	two_more_races INT,
	white INT
);

LOAD DATA INFILE '/tmp/ShareRaceByCity_state.csv'
INTO TABLE racebreakout_state FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geographic_area,@native_american, @asian, @black, @hispanic, @pacific_islander, @two_more_races, @white)
SET 
	native_american = NULLIF(@native_american,'')
    ,asian = NULLIF(@asian,'')
    ,black = NULLIF(@black,'')
    ,hispanic = NULLIF(@hispanic,'')
    ,pacific_islander = NULLIF(@pacific_islander,'')
    ,two_more_races = NULLIF(@two_more_races,'')
    ,white = NULLIF(@white,'')
;

DROP TABLE IF EXISTS PoliceKillingsUS;
CREATE TABLE `us_fatal_police_shootings`.`PoliceKillingsUS` (
	id INT
    ,name VARCHAR(45)
    ,date DATETIME
    ,manner_of_death VARCHAR(45)
    ,armed VARCHAR(45)
    ,age INT
    ,gender VARCHAR(45)
    ,race VARCHAR(45)
    ,city VARCHAR(45)
    ,state VARCHAR(45)
    ,signs_of_mental_illness VARCHAR(45)
    ,threat_level VARCHAR(45)
    ,flee VARCHAR(45)
    ,body_camera VARCHAR(45)
);

LOAD DATA INFILE '/tmp/PoliceKillingsUS.csv' INTO TABLE PoliceKillingsUS 
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@id, name, date, manner_of_death, armed, @age, gender, race, city, state, signs_of_mental_illness, threat_level, flee, body_camera)
SET 
	id = NULLIF(@id,'')
    ,age = NULLIF(@age,'')
;

ALTER TABLE `us_fatal_police_shootings`.`PoliceKillingsUSDemo` 
CHANGE COLUMN `geographic_area` `state` VARCHAR(45) NULL DEFAULT NULL ;

ALTER TABLE `us_fatal_police_shootings`.`racebreakout_state` 
CHANGE COLUMN `white` `W` VARCHAR(45) NULL DEFAULT NULL;

ALTER TABLE `us_fatal_police_shootings`.`racebreakout_state` 
CHANGE COLUMN `black` `B` VARCHAR(45) NULL DEFAULT NULL;

ALTER TABLE `us_fatal_police_shootings`.`racebreakout_state` 
CHANGE COLUMN `hispanic` `H` VARCHAR(45) NULL DEFAULT NULL;

ALTER TABLE `us_fatal_police_shootings`.`racebreakout_state` 
ADD COLUMN `O` VARCHAR(45) NULL DEFAULT NULL;

UPDATE `us_fatal_police_shootings`.`racebreakout_state` 
SET O = racebreakout_state.native_american + racebreakout_state.pacific_islander +
			racebreakout_state.two_more_races;

/*Trigger for New Fatal Police Shootings*/
DROP TRIGGER IF EXISTS new_police_killing_insert;
CREATE TABLE IF NOT EXISTS messages (message varchar(100) NOT NULL); 

DELIMITER $$
CREATE TRIGGER new_police_killing_insert
AFTER INSERT
ON PoliceKillingsUS FOR EACH ROW
BEGIN
	/*Logs the id number of the new police shooting.*/
	INSERT INTO messages SELECT CONCAT('new id: ', NEW.id);

  	INSERT INTO PoliceKillingsUS
	SELECT *
	FROM PoliceKillingsUS
	WHERE id = NEW.id
	ORDER BY date, id;
        
END $$

DELIMITER ;

USE us_fatal_police_shootings;
SET sql_mode = "";

DROP PROCEDURE IF EXISTS create_datawarehouse;

DELIMITER $$ 

CREATE PROCEDURE create_datawarehouse()

BEGIN
DROP TABLE IF EXISTS PoliceKillingsUSDemo;
CREATE TABLE PoliceKillingsUSDemo
	AS
SELECT 
	PoliceKillingsUS.id AS ShootingId,
    PoliceKillingsUS.manner_of_death AS MannerOfDeath,
    PoliceKillingsUS.age AS Age,
    PoliceKillingsUS.gender AS Gender,
    PoliceKillingsUS.race AS Race,
    PoliceKillingsUS.city AS City,
    PoliceKillingsUS.geographic_area AS State,
    PoliceKillingsUS.signs_of_mental_illness AS SignsOfMentalIllness,
    PoliceKillingsUS.flee AS Flee,
    PoliceKillingsUS.body_camera AS BodyCamera,
    YEAR(PoliceKillingsUS.date) AS Year,
    medianhouseholdincome2015_state.avg_median_income AS StateMedianIncome,
    percentageover25completedhighschool_state.avg_percent_completed_hs AS StatePercentCompletedHS,
    percentagepeoplebelowpovertylevel_state.avg_poverty_rate AS StatePovertyRate,
    racebreakout_state.B AS StatePopulationBlack,
    racebreakout_state.H AS StatePopulationHispanic,
    racebreakout_state.O AS StatePopulationOther,
    racebreakout_state.W AS StatePopulationWhite
FROM PoliceKillingsUS
INNER JOIN medianhouseholdincome2015_state USING (geographic_area)
INNER JOIN percentageover25completedhighschool_state USING (geographic_area)
INNER JOIN percentagepeoplebelowpovertylevel_state USING (geographic_area)
INNER JOIN racebreakout_state USING (geographic_area)
;
END $$
    
DELIMITER ;

Call create_datawarehouse();

DROP PROCEDURE IF EXISTS create_datamart_views;

DELIMITER $$

CREATE PROCEDURE create_datamart_views()

BEGIN 
	DROP VIEW IF EXISTS `ShootingVictimBreakout_View`;
CREATE VIEW ShootingVictimBreakout_View
	AS
SELECT COUNT(id), gender, race, manner_of_death, signs_of_mental_illness, armed, flee, body_camera
FROM PoliceKillingsUS
WHERE race !=''
GROUP BY gender, race, manner_of_death, signs_of_mental_illness, armed, flee, body_camera
ORDER BY COUNT(id) DESC;

	DROP VIEW IF EXISTS `StateDemoDataandFatalShootingCount_view`;
CREATE VIEW StateDemoDataandFatalShootingCount_view
	AS
SELECT State, StateMedianIncome, StatePovertyRate, StatePercentCompletedHS, StatePopulationBlack, 
		StatePopulationHispanic, StatePopulationOther, StatePopulationWhite, COUNT(ShootingId)
FROM PoliceKillingsUSDemo
GROUP BY State
ORDER BY COUNT(ShootingId) DESC;

END $$

DELIMITER ;
        
CALL create_datamart_views();

SELECT `shootingvictimbreakout_view`;