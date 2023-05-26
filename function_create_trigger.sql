-- This function creates a trigger for a bunch of tables, using two for loops (one for the schema, other for table name).
-- The trigger created records in a table the date of last modification of the data

CREATE OR REPLACE FUNCTION __donnees.create_trigger()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    d text;
    f text;
BEGIN
    FOR f IN SELECT DISTINCT n.schemaname 
	       FROM pg_catalog.pg_tables as n 
	      WHERE n.schemaname NOT IN ('topology', 'information_schema', 'pgmetadata', '__projets', 'public', 'pg_catalog', '_formation')
    LOOP	
        FOR d IN SELECT b.tablename 
	           FROM pg_catalog.pg_tables as b 
	          WHERE b.schemaname = f
	LOOP
	    EXECUTE 
		'DROP TRIGGER IF EXISTS pgmetadata_date ON '||f||'.'||d||';
		CREATE TRIGGER pgmetadata_date
		AFTER INSERT OR UPDATE OR DELETE
		ON '||f||'.'||d||'
		FOR EACH ROW
		EXECUTE PROCEDURE __donnees.pgmetadata_date_p()';
	END loop;
    END loop;
END;
$BODY$;
