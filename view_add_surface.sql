-- this view uses the postgis function st_area() to add the surface (m²) of the buildings

CREATE OR REPLACE VIEW referentiel.surface_bati AS
	SELECT  "BATIMENT"."GEOM",
		"BATIMENT"."ID",
		st_area("BATIMENT"."GEOM") AS m2_bati
	FROM 	edigeo."BATIMENT";
