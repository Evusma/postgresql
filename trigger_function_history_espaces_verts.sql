-- Trigger function for record the history of data changes

CREATE FUNCTION _espaces_verts.nsm_gestion_espaces_verts_historique_p()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN

	IF (TG_OP = 'DELETE') THEN

		INSERT INTO __historique.history_nsm_gestion_espaces_verts (id, geom, parcelle, entite, categorie, etiquette, nom, contenant, 
									    designation, secteur, id_secteur, aspect, observation, deleted_by, maj_deleted)
		VALUES (OLD.id, OLD.geom, OLD.parcelle, OLD.entite, OLD.categorie, OLD.etiquette, OLD.nom, OLD.contenant, 
			OLD.designation, OLD.secteur, OLD.id_secteur, OLD.aspect, OLD.observation, current_user, tstzrange(current_timestamp, NULL));
		RETURN OLD;
		
	END IF;
	
	IF (TG_OP = 'INSERT') THEN
	
		INSERT INTO __historique.history_nsm_gestion_espaces_verts (id, geom, parcelle, entite, categorie, etiquette, nom, contenant, 
									    designation, secteur, id_secteur, aspect, observation, created_by, maj_created)
		VALUES (NEW.id, NEW.geom, NEW.parcelle, NEW.entite, NEW.categorie, NEW.etiquette, NEW.nom, NEW.contenant, 
		    	NEW.designation, NEW.secteur, NEW.id_secteur, NEW.aspect, NEW.observation, current_user, tstzrange(current_timestamp, NULL));
		RETURN NEW;
	END IF;
	
	IF (TG_OP = 'UPDATE') THEN
		
		INSERT INTO __historique.history_nsm_gestion_espaces_verts (id, geom, parcelle, entite, categorie, etiquette, nom, contenant, 
									    designation, secteur, id_secteur, aspect, observation)
		VALUES (OLD.id, OLD.geom, OLD.parcelle, OLD.entite, OLD.categorie, OLD.etiquette, OLD.nom, OLD.contenant, 
			OLD.designation, OLD.secteur, OLD.id_secteur, OLD.aspect,' (avant la mise à jour)');
			
		INSERT INTO __historique.history_nsm_gestion_espaces_verts (id, geom, parcelle, entite, categorie, etiquette, nom, contenant, 
									    designation, secteur, id_secteur, aspect, observation, updated_by, maj_updated)
		VALUES (NEW.id, NEW.geom, NEW.parcelle, NEW.entite, NEW.categorie, NEW.etiquette, NEW.nom, NEW.contenant, 
			NEW.designation, NEW.secteur, NEW.id_secteur, NEW.aspect, NEW.observation||' (après la mise à jour)', current_user, tstzrange(current_timestamp, NULL));
		RETURN NEW;	
	END IF;

END;
$BODY$;
