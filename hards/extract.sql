.mode csv

.output Ellinger.csv 
SELECT * FROM data2 WHERE ref = "E";

.output Heiser.csv   
SELECT * FROM data2 WHERE ref = "H";

.output Touret.csv  
SELECT * FROM data2 WHERE ref = "T";

.mode column
.separator ROW "\n"
.output siblings.dat
SELECT * FROM siblings;

.output hards2_all.dat
SELECT * FROM hards2 ORDER BY ave ASC, pid ASC;
                                 
.output hards2.dat
SELECT * FROM hards2 WHERE cut<25 AND ave < 25 ORDER BY ave ASC, pid ASC;

.output hards3.dat
SELECT * FROM hards3 WHERE cut<25 AND ave < 25 ORDER BY ave ASC;

