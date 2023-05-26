-- This function creates a trigger for a bunch of tables, using two for loops (one for the schema, other for table name).
-- The trigger created records in the table nsm_historique the changes made in the tables of the database

CREATE OR REPLACE FUNCTION __historique.create_trigger()
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
	          WHERE b.schemaname = f AND b.tablename != 'nsm_historique'
	LOOP
	    EXECUTE 
	        'DROP TRIGGER IF EXISTS nsm_historique_trigger ON '||f||'.'||d||';
		CREATE TRIGGER nsm_historique_trigger
		AFTER INSERT OR UPDATE OR DELETE
		ON '||f||'.'||d||'
		FOR EACH ROW
		EXECUTE PROCEDURE __historique.nsm_historique_p()';
	END loop;
    END loop;
END;
$BODY$;
