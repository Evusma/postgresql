-- two trigger functions for data changes from a view

-- Function for the trigger instead of delete;

CREATE FUNCTION _vrd_transport.parkings_delete_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	DELETE FROM __donnees.voirie_nsm_parking
	WHERE id=OLD.id AND id_voie = OLD.id_voie;
	
	RETURN OLD;

END;
$BODY$;

-- Function for the trigger instead of update;
-- It checks that the new geometry/location has not changed much from the original geometry (it is still in a 5 meter buffer)

CREATE FUNCTION _vrd_transport.parkings_update_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	IF (OLD.id = NEW.id AND OLD.id_voie = NEW.id_voie AND ST_Covers(ST_Buffer(OLD.geom,5),NEW.geom)) THEN
	
		UPDATE  __donnees.voirie_nsm_surface_voirie
		   SET  geom = NEW.geom,
			classement = NEW.classement, 
			maj = now() 
		 WHERE  id_voie = OLD.id_voie;
			
		UPDATE  __donnees.voirie_nsm_parking
		   SET  places_total = NEW.places_total, 
			places_bleue = NEW.places_bleue, 
			places_pmr = NEW.places_pmr,
			places_livraison = NEW.places_livraison,
			observations = NEW.observations,
			maj = now() 
		 WHERE  id = OLD.id;
		 RETURN NEW;
	END IF;

	RAISE EXCEPTION 'Veuillez changer seulement la géométrie, le classement, le nombre de places (total, bleue, PMR, livraison) et/ou les observations.';
END;
$BODY$;
