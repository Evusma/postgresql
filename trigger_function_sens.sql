-- three trigger functions for data changes from a view

-- Function for the trigger instead of delete;

CREATE FUNCTION _vrd_transport.sens_delete_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	DELETE FROM __donnees.voirie_nsm_sens_voies
	WHERE id=OLD.id and id_voie = OLD.id_voie;
	
	RETURN OLD;

END;
$BODY$;

-- Function for the trigger instead of insert;
-- It takes street id from the street inventory by selecting the closest street from the geometry inserted

CREATE FUNCTION _vrd_transport.sens_insert_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	new_id_voie character varying(25);
	new_rivoli character varying(4);
BEGIN
	
	new_id_voie = (SELECT d.id_voie 
			 FROM __donnees.voirie_nsm_inventaire as d 
			WHERE ST_Covers(ST_Buffer(d.geom,1),NEW.geom));
	new_rivoli = (SELECT d.rivoli 
			FROM __donnees.voirie_nsm_inventaire as d 
		       WHERE ST_Covers(ST_Buffer(d.geom,1),NEW.geom));

	IF (new_id_voie IS NOT NULL) THEN
	
		INSERT INTO __donnees.voirie_nsm_sens_voies(geom, id_voie, rivoli, sens, observations, maj)
		VALUES (NEW.geom, new_id_voie, new_rivoli, NEW.sens, NEW.observations, now());
		RETURN NEW;
		
	END IF;
	
	RAISE EXCEPTION 'Veuillez bien suivre la géométrie de référence.';

END;
$BODY$;

-- Function for the trigger instead of update;
-- It checks that the geometry/location has not changed much from the original geometry (it is still in a 1 meter buffer)

CREATE FUNCTION _vrd_transport.sens_update_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	geom_condition geometry;
BEGIN

	geom_condition = (SELECT ST_Buffer(d.geom,1) 
			    FROM __donnees.voirie_nsm_inventaire as d 
			   WHERE OLD.id_voie = d.id_voie);

	IF (OLD.id = NEW.id AND OLD.id_voie = NEW.id_voie AND ST_Covers(geom_condition,NEW.geom)) THEN	
		UPDATE __donnees.voirie_nsm_sens_voies 
		   SET geom = NEW.geom, 
		       sens = NEW.sens, 
		       observations = NEW.observations, 
		       maj = now() 
		 WHERE id = OLD.id;		
		RETURN NEW;		
	END IF;

	RAISE EXCEPTION 'Veuillez changer seulement la géométrie, le sens, les observations et/ou la date de mise à jour.';
END;
$BODY$;
