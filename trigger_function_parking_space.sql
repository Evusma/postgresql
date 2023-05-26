-- Trigger function that helps keep database integrity for the parking id and street id
-- It takes street id from the street inventory by selecting the closest street from the parking

CREATE FUNCTION _vrd_transport.stationnement_insert_update_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	new_id_voie character varying(25);
	new_id_stationnement character varying(10);
	new_id int;
BEGIN

	IF (TG_OP = 'INSERT') THEN

		new_id = nextval('_vrd_transport.nsm_stationnements_gid_seq'::regclass);	
		new_id_voie = (SELECT d.id_voie 
		 		 FROM  __donnees.voirie_nsm_inventaire as d, _vrd_transport.nsm_stationnements as f
		 		WHERE (ST_Distance(NEW.geom,d.geom)<20) 
				ORDER BY ST_Distance(NEW.geom,d.geom) ASC LIMIT 1);
		new_id_stationnement = (SELECT '9350ST'||new_id
		 			  FROM _vrd_transport.nsm_stationnements 
					 WHERE gid=NEW.gid);
		 
		UPDATE  _vrd_transport.nsm_stationnements
		   SET  geom = NEW.geom, 
		        gid = new_id,
			id_stationnement = new_id_stationnement,
			id_voie = new_id_voie,
			typologie = NEW.typologie,
			adresse = NEW.adresse,
			observation = NEW.observation, 
			maj = now()
		 WHERE  geom = NEW.geom;
		RETURN NEW;
	END IF;

	IF (TG_OP = 'UPDATE' AND OLD.gid = NEW.gid AND OLD.id_stationnement = NEW.id_stationnement AND OLD.id_voie = NEW.id_voie) THEN
		
		new_id_voie = (SELECT d.id_voie 
		 		 FROM  __donnees.voirie_nsm_inventaire as d, _vrd_transport.nsm_stationnements as f
		 		WHERE (ST_Distance(NEW.geom,d.geom)<20) 
				ORDER BY ST_Distance(NEW.geom,d.geom) ASC LIMIT 1);
			
		UPDATE _vrd_transport.nsm_stationnements
		   SET  geom = NEW.geom,
			id_voie = new_id_voie,
			typologie = NEW.typologie,
			adresse = NEW.adresse,
			observation = NEW.observation, 
			maj = now()
		WHERE   gid = OLD.gid;
		RETURN NEW;
	END IF;

	RAISE EXCEPTION 'Veuillez modifier seulement : géométrie, typologie, adresse et/ou observation.';
END;
$BODY$;
