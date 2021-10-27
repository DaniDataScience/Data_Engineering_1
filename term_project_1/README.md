Term Project 1: Fatal Police Shootings in the US
======
## Summary

I chose my dataset via Kaggle on fatal police shootings in the United States, link [here](https://www.kaggle.com/kwullum/fatal-police-shootings-in-the-us). I was interested in this dataset as an American to better understand if there is a correlation in demographic (demo) data regarding poverty, education, and race and the count of police shootings in certain states. I also wanted to better understand who is being fatally killed by police in the United States. Within the Kaggle dataset, there were 5 separate tables. 4 of the tables were specifically demo data broken out by US city and state while the remaining table was a data collection from the Washington Post on police shootings from 2015 onwards, link [here](https://github.com/washingtonpost/data-police-shootings), as per inspiration from the Black Lives Matter protests. 

After Michael Brown, an unarmed Black man, was killed by police officers in 2014, the Washington Post discovered that fatal police encounters were underreported by ~50%. The police shooting data set is an aggregation of news, social media, and police reports. This is a live dataset as per their github page and is updated daily to include new fatal police shootings.

## ETL: Analytics Plan
My analytics plan consists of four different steps: data cleaning, operational layer, analytical layer, and data marts. See diagram below. The individual steps are detailed below.

![ETL_Plan_Diagram](https://user-images.githubusercontent.com/90245801/139145506-0b1fb215-9df6-4ffc-aa9c-f783b2fa2b82.jpg)

## ETL: Data Cleaning
Unfortunately, the data for the demo tables from Kaggle was fairly large (25,000+ rows) due to the US city variable. As a result, I aggregated the entries for the tables to break out demo data by US state only as a result. This was accomplished in Excel through pivot table aggregation on all the demo data since I was unable to accomplish in SQL due to size. 

I also discovered the demo table for racial statistics was flawed due to the extreme values in certain variables. For example, there were some towns that had 100% Hispanic population, but also percentages in other races as well. While this may have been due to overlapping racial identities, I used a different data set for a higher confidence in validity. This data set from the US government, link [here](https://corgis-edu.github.io/corgis/csv/state_demographics/). I also removed blank entries from the police killings table to ensure the accuracy of my analysis across demographics, and reduced the file size to 3,000 rows.

See definitions of variables below. Demo data is based on US census data from 2015 [here](https://factfinder.census.gov/faces/nav/jsf/pages/community_facts.xhtml).

**Key**	| **Description**	| **Type** | **Sample Value**
----| ------------ | ----| -------------
geographic_area	| US state |	VARCHAR(45) |	NY
avg_median_income	| Average median household income	| INT	| 42388
avg_percent_completed_hs	| Average percentage of state population above 25 years old that has graduated high school	| INT	| 81
avg_poverty_rate	| Average percentage of people living below US census definition of poverty	| INT	26
B	| Black ethnicity	| INT	| 4
H	| Hispanic ethnicity	| INT	| 6
O	| Other ethnicity (eg. Asian)	| INT	| 7
W	| White ethnicity	| INT	| 62
id	| Data table id of fatal shooting	| INT	| 125
name	| Shooting victim name	| VARCHAR(45)	| Jeremy Lett
date	| Date of fatal shooting	| DATETIME	| 2015-02-05
manner_of_death	| Manner of fatal police killing	| VARCHAR(45)	| shot and Tasered
armed	| Indicates if the victim was armed with some sort of weapon that a police officer believed could cause harm	| VARCHAR(45)	| unarmed
age	| Age of victim	| INT	| 16
gender	| Gender of victim	| VARCHAR(45)	| M
race	| Race of victim	| VARCHAR(45) | W
city	| City of fatal police shooting	| VARCHAR(45)	| Essex
signs_of_mental_illness	| Mental illness status of victim	| VARCHAR(45)	| TRUE
threat_level	| Threat level of victim	| VARCHAR(45)	| attack
flee	| Flee status of victim during fatal shooting	| VARCHAR(45)	| Foot
body_camera	| Body camera status of police officer who committed fatal police shooting	| VARCHAR(45)	| FALSE

## Operational Layer
My operational layer of the data is 5 separate tables: 1 specific to individual police shootings and 4 demo data regarding individual US states. See EER diagrams below.

![ETL_Plan_Diagram](https://user-images.githubusercontent.com/90245801/139149810-664f4eef-2cb3-4986-a1a7-c31f1ff5db20.jpg)

I imported the 5 tables after aggregating 3 of the demo tables in Excel. Since this reduced the size dramatically (from 25,000+ rows to 52 for all US states and header row), my operational layer was fairly straight forward. I altered the police shooting table to change the variable “state” to “geographic_area” to match the naming convention of the other tables. I also changed the racial data to match the racial breakout from the police shootings table to only include Black, White, Hispanic, and Other. 

I also included a trigger for a live dataset from the Washington Post when new fatal shootings occur. New additions are captured in an additional table “messages” along with the new shooting id. 

## ETL: Analytical Layer
In my analytical layer, I joined the 5 tables together to create a denormalized central data warehouse. This captured an individual fatal shooting along with the state demographic data in which the shooting was done. Since I had reduced the file, I was comparing only US state data instead of individual cities. However, since there were tens of thousands of US citizens and there are only 50 US states (and the District of Columbia), I felt this was a better path for valuable analysis. Fatal police shootings occur in every state and seemed to occur in more concentrated populations without standout cities. 

## ETL: Data Mart
I created 2 separate views: one focused on the demographic data of the count of shootings and another on state demographic data including the count of police shootings.

*ShootingVictimBreakout_View*

This view includes the count of shooting id and various shooting variables I found interesting and informative based on the outputs. I include the gender, race, manner of death, signs of mental illness, armed, flee, and body camera. As the next view shows, the state populations of Black Americans is significantly smaller than white Americans, but Black Americans are killed at a much higher rate than White Americans. This data can be further analyzed by determining if there are certain variables that lead to a higher count of fatal shootings like mental health status.

*StateDemoDataandFatalShootingCount_view*

This view includes the state demographic data with the count of shooting id. This includes median income, state poverty rate, percentage completed high school, and state population racial breakout. It can be used to determine if there are certain variables in states lead to higher shootings. For example, CA and TX lead the way in terms of count of police shootings and have some of the lowest high school completion rates. Additional state information can be added to this view like unemployment for even more analysis.


