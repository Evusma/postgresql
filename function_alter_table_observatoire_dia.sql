-- function to update the data for the observatory

CREATE OR REPLACE FUNCTION __donnees.alter_table_observatoire_dia()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	c text; -- schema
	d text; -- table
	f text; -- year
BEGIN
	c = '_foncier';
        d = (SELECT tablename 
	     FROM pg_catalog.pg_tables 
	     WHERE tablename LIKE 'nsm_2016_20%' AND schemaname = '_foncier');
	f = (SELECT to_char(now( )- interval '1 year', 'yyyy'));

    EXECUTE
        'INSERT INTO '||c||'.'||d||' (geom, n_dia, date, parcelle, cp, ville, legende, surface_m2, prix, prix_m2) 
         SELECT geom, n_dia, date, parcelle, cp, ville, legende, surface_m2, CAST (prix AS character varying), CAST(prix_m2 AS double precision) 
           FROM _foncier.nsm_dia_2023;

         UPDATE '||c||'.'||d||' as f 
            SET  id_dia = CONCAT_WS(''/'',CAST('||f||' AS character varying), n_dia),
                annee = '||f||' , 
                commune = ''Neuilly-sur-Marne'',
                maj = now(),
                geom2 = st_centroid(f.geom),
                quartier = b.nom
          FROM __historique.nsm_anciens_quartiers as b 
         WHERE ST_Contains(b.geom, f.geom) AND annee IS NULL;
 
        UPDATE '||c||'.'||d||' as f
           SET depart_acq = code_ced_5
          FROM __historique.code_cedex_insee as b 
         WHERE f.ville = b.nom_m AND depart_acq IS NULL;

	UPDATE '||c||'.'||d||'
	   SET depart_acq = ''PARIS''
	 WHERE cp like ''75%'' AND depart_acq IS NULL;

	UPDATE '||c||'.'||d||'
	   SET depart_acq = ''SEINE-SAINT-DENIS''
	 WHERE cp like ''93%'' AND depart_acq IS NULL;

	UPDATE '||c||'.'||d||'
	   SET depart_acq = ''VAL-DE-MARNE''
	 WHERE cp like ''94%'' AND depart_acq IS NULL;

	UPDATE '||c||'.'||d||'
	   SET depart_acq = ''ESSONNE''
	 WHERE cp like ''91%'' AND depart_acq IS NULL;

	UPDATE '||c||'.'||d||'
	   SET depart_acq = ''HAUTS-DE-SEINE''
	 WHERE cp like ''92%'' AND depart_acq IS NULL;

	 UPDATE '||c||'.'||d||'
	    SET depart_acq = ''SEINE-ET-MARNE''
	  WHERE cp like ''77%'' AND depart_acq IS NULL;

	 UPDATE '||c||'.'||d||'
	    SET depart_acq = ''YVELINES''
	  WHERE cp like ''78%'' AND depart_acq IS NULL;
    
	 ALTER TABLE '||c||'.'||d||' 
	 RENAME TO nsm_2016_'||f||'_dia';
END;
$BODY$;
