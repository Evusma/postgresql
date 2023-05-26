-- While updating the data (_securite.nsm_squats), the trigger checks if the user is adding a point (geom2) which is geographically inside of a polygon from another table (_cadastre_plu_domaine.nsm_domaine_tout)
-- If the point is not inside, the trigger raise an exception
-- The data has two geometries (geom and geom2)

CREATE FUNCTION _securite.insert_squat_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF (NEW.date IS NULL)THEN
        	UPDATE _securite.nsm_squats
		   SET date = now()::timestamp
	     	 WHERE date IS NULL;
    END IF;
	
    IF (NEW.geom2 IS NOT NULL AND ST_Within(NEW.geom2,
					   (SELECT geom 
					      FROM _cadastre_plu_domaine.nsm_domaine_tout 
					     WHERE ST_Contains(geom,NEW.geom2))))THEN
		UPDATE _securite.nsm_squats
		   SET geom = ST_AsEWKT(d.geom), geom2 = st_centroid(d.geom) -- ST_AsEWKT(d.geom);
		  FROM _cadastre_plu_domaine.nsm_domaine_tout as d
		 WHERE ST_Within(geom2, d.geom);
		RETURN NEW;
    END IF;
	
    IF (NEW.geom2 IS NULL AND NEW.geom IN 
			      (SELECT geom 
				 FROM _cadastre_plu_domaine.nsm_domaine_tout )) THEN
		UPDATE _securite.nsm_squats
		   SET geom2 = st_centroid(geom); -- ST_AsEWKT(d.geom);
		RETURN NEW;
    END IF;

    RAISE EXCEPTION 'Veuillez indiquer une parcelle du domaine de la commune';
		
END;
$BODY$;
