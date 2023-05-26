-- Trigger function to update the date of last modification in the metadata table (metadata managed by the QGIS plugin pgmetadata);

CREATE FUNCTION __donnees.pgmetadata_date_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF (TG_OP IN ('INSERT', 'UPDATE', 'DELETE')) THEN
	UPDATE pgmetadata.dataset
	   SET data_last_update = now() 
	 WHERE table_name = TG_TABLE_NAME;
	RETURN NEW;
    END IF;
END;
$BODY$;
