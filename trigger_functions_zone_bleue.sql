-- three trigger function for data changes from a view

-- Function for the trigger instead of delete;

CREATE FUNCTION _vrd_transport.bleue_delete_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	DELETE FROM __donnees.voirie_nsm_zone_bleue
	WHERE id=OLD.id and id_voie = OLD.id_voie;
	
	RETURN OLD;

END;
$BODY$;

-- Function for the trigger instead of insert;
-- It takes street id from the street inventory by selecting the closest street from the zone bleue

CREATE FUNCTION _vrd_transport.bleue_insert_p()
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
		        WHERE ST_Covers(ST_Buffer(d.geom,10),NEW.geom));
		
	new_rivoli = (SELECT d.rivoli 
			FROM __donnees.voirie_nsm_inventaire as d 
		       WHERE ST_Covers(ST_Buffer(d.geom,10),NEW.geom));

	IF (new_id_voie IS NOT NULL) THEN
	
		INSERT INTO __donnees.voirie_nsm_zone_bleue(geom, id_voie, rivoli, statut, observations, places, maj)
		VALUES (NEW.geom, new_id_voie, new_rivoli, NEW.statut, NEW.observations, NEW.places, now());
	
		RETURN NEW;
	END IF;
	
	RAISE EXCEPTION 'Veuillez bien suivre la géométrie de référence.';

END;
$BODY$;

-- Function for the trigger instead of update;
-- It checks that the new geometry/location has not changed much from the original geometry (it is still in a 10 meters buffer)

CREATE FUNCTION _vrd_transport.bleue_update_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	geom_condition geometry;
BEGIN

	geom_condition = (SELECT ST_Buffer(d.geom,10) 
			    FROM __donnees.voirie_nsm_inventaire as d 
			   WHERE OLD.id_voie = d.id_voie);

	IF (OLD.id = NEW.id and OLD.id_voie = NEW.id_voie AND ST_Covers(geom_condition,NEW.geom)) THEN
		UPDATE  __donnees.voirie_nsm_zone_bleue
		   SET  geom = NEW.geom, 
		        statut = NEW.statut, 
			observations = NEW.observations, 
			places = NEW.places, 
			maj = now()
		 WHERE  id = OLD.id;
		RETURN NEW;
	END IF;

	RAISE EXCEPTION 'Veuillez changer seulement la géométrie, le statut, les observations et/ou les places.';

END;
$BODY$;
