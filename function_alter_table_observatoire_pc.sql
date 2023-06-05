CREATE OR REPLACE FUNCTION __donnees.alter_table_observatoire_pc()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	d text;
	f text;
BEGIN
  d = (SELECT tablename 
	       FROM pg_catalog.pg_tables 
		    WHERE tablename LIKE 'nsm_2016_20%' AND schemaname = '_pc_ads');
	f = to_char(now(), 'yyyy');
	EXECUTE 
		'ALTER TABLE _pc_ads.'||d||' 
		   RENAME TO nsm_2016_'||f||'_pc';
END;
$BODY$;
