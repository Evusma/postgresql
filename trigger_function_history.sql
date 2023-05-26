-- Trigger function to record for the history of data modifications

CREATE FUNCTION __historique.nsm_historique_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	IF (TG_OP IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')) THEN
		INSERT INTO __historique.nsm_historique (schema_table, name_table, modification, modified_by, date_maj)
		VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, current_user, now());
		RETURN NEW;
	END IF;
END;
$BODY$;