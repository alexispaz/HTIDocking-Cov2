
-- Find high active repurpoused drugs (HARDs)
---------------------------------------------

-- View those drugs that have different id but same parent

CREATE VIEW siblings AS
SELECT prn, pid, GROUP_CONCAT(DISTINCT id) ids,
			 GROUP_CONCAT(DISTINCT name) names,
       COUNT(*) c
FROM data 
GROUP BY pid
HAVING c>1 and 
       ids like "%,%";  
 
-- Agregate duplicate entrees per ref, keeping best value
-- Rank drugs per ref using the values

CREATE TABLE data2 AS
SELECT ref, prn, pid,
       GROUP_CONCAT(DISTINCT psmile) psmile,
       GROUP_CONCAT(DISTINCT id) id,
       GROUP_CONCAT(DISTINCT name) name,
       GROUP_CONCAT(DISTINCT ckey) ckey,
       MAX(value) value, COUNT(*) c,
			 ROW_NUMBER() OVER(
           PARTITION BY ref
           ORDER BY value DESC) rank
FROM data
GROUP BY ref, prn
ORDER BY rank ASC;


-- Convert rank in percentages

ALTER TABLE data2 ADD COLUMN nrank REAL;

UPDATE data2 
  SET nrank = printf("%.2f", rank*100.0/(SELECT COUNT(*) FROM data2 WHERE ref='E'))
  WHERE ref='E';
UPDATE data2 
  SET nrank = printf("%.2f", rank*100.0/(SELECT COUNT(*) FROM data2 WHERE ref='H'))
  WHERE ref='H';
UPDATE data2 
  SET nrank = printf("%.2f", rank*100.0/(SELECT COUNT(*) FROM data2 WHERE ref='T'))
  WHERE ref='T';
  

-- Mach drugs in 2 ref via self join. 
--  Each entree will be duplicated but in different order, so:
--  1. I sort ref to avoid having same things like HT and TH.
--  2. keep only one id column, it will group all ids after GROUP_CONCAT in next query.
--  3. keep the max value of cut so the compound will be below the top cut of 2 assays.

CREATE TABLE hards AS
	SELECT 
        (CASE WHEN a.ref<b.ref THEN a.ref||b.ref ELSE b.ref||a.ref END) ref, 
        a.prn prn, a.pid pid, a.psmile psmile,
        a.id id,
        a.name name,
        a.value||','||b.value value,
        a.nrank||','||b.nrank nrank,
        (a.nrank+b.nrank)/2. ave,
        (CASE WHEN a.nrank < b.nrank THEN b.nrank ELSE a.nrank END) as cut
	FROM data2 a JOIN data2 b
	ON a.prn = b.prn AND a.ref != b.ref;

	-- ON (a.prn = b.prn OR a.name = b.name COLLATE NOCASE) AND a.ref != b.ref;


-- Getting HARDs using 2 ref and for different cut

CREATE TABLE hards2 AS
  SELECT ref, prn, pid,
         GROUP_CONCAT(DISTINCT id) id,
         GROUP_CONCAT(DISTINCT name) name,
         value,
				 ave,
         MIN(cut) cut,  psmile
  FROM hards
  GROUP BY prn;


-- Getting HARDs using 3 ref and for different cut

CREATE VIEW hards3 AS
SELECT  prn, pid,
        GROUP_CONCAT(DISTINCT id) id, 
        name,
        GROUP_CONCAT(cut) cut2, ave,
        MAX(cut) cut, COUNT(*) c, psmile
  FROM hards2
	GROUP BY prn
  HAVING c>1;

