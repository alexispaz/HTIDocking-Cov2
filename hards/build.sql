
-- Copy data from chembl_27.db to hards.db

ATTACH DATABASE 'hards.db' as 'h';

CREATE TABLE h.data as 
SELECT 
(CASE WHEN a.doc_id='110267' THEN 'H' -- Heiser
      WHEN a.doc_id='110246' THEN 'E' -- Ellinger 
      WHEN a.doc_id='110230' THEN 'T' -- Touret
      END) ref, 
p.parent_molregno prn,
m.chembl_id id, 
upper(r.compound_name) name, 
upper(r.compound_key) ckey,
a.standard_value value, 
y.assay_cell_type cell
FROM activities a 
  JOIN compound_records r on a.record_id = r.record_id 
  JOIN molecule_hierarchy p on a.molregno = p.molregno 
  JOIN molecule_dictionary m on a.molregno = m.molregno 
  JOIN assays y on a.assay_id = y.assay_id  
WHERE (a.doc_id='110267' and a.standard_type = 'Hit score') 
  or  (a.doc_id='110246' and a.standard_type = 'Inhibition') 
  or  (a.doc_id='110230' and a.standard_type = 'Inhibition index');

-- Add column with CHEMBL IDs, smile and name of the parent compound	

ALTER TABLE h.data ADD COLUMN pid TEXT;
ALTER TABLE h.data ADD COLUMN pname TEXT;
UPDATE h.data 
  SET pid = m.chembl_id,
      pname = m.pref_name
  FROM molecule_dictionary m
	WHERE prn = m.molregno;
 
ALTER TABLE h.data ADD COLUMN psmile TEXT;
UPDATE h.data 
  SET psmile = m.canonical_smiles
  FROM compound_structures m
	WHERE prn = m.molregno;
 
-- Truncate column for better visualization	

UPDATE h.data 
  SET name = substr(name,1,20), 
	    ckey = substr(ckey,1,20);
 
