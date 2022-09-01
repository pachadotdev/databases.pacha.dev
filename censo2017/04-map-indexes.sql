create unique index idx_zonas_2 on zonas (geocodigo);

alter table mapa_zonas 
add constraint fk_mapazonas_zonas foreign key (geocodigo) REFERENCES zonas (geocodigo);

alter table mapa_comunas
add constraint fk_mapacomunas_comunas foreign key (comuna) REFERENCES comunas (redcoden);

alter table mapa_provincias 
add constraint fk_mapaprovincias_provincias foreign key (provincia) REFERENCES provincias (redcoden);

alter table mapa_provincias 
add constraint fk_mapaprovincias_regiones foreign key (region) REFERENCES regiones (redcoden);

alter table mapa_regiones 
add constraint fk_maparegiones_regiones foreign key (region) REFERENCES regiones (redcoden);

create table mapa_calles_2 as
select region, c.redcoden as comuna, mc.nom_comuna as nom_comuna,
	nombre_via, clase_comu, clase_urba, shape_leng, geometry
from mapa_calles mc 
left join (
	select redcoden, nom_comuna from comunas
) c on c.nom_comuna = mc.nom_comuna;

drop table mapa_calles;

alter table mapa_calles_2 rename to mapa_calles;

alter table mapa_calles 
add constraint fk_mapacalles_regiones foreign key (region) REFERENCES regiones (redcoden);

alter table mapa_calles 
add constraint fk_mapacalles_comunas foreign key (comuna) REFERENCES comunas (redcoden);
