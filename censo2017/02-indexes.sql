create unique index idx_zonas on zonas (zonaloc_ref_id);
create unique index idx_viviendas on viviendas (vivienda_ref_id);
create unique index idx_hogares on hogares (hogar_ref_id);

alter table viviendas
add constraint fk_viviendas_zonas foreign key (zonaloc_ref_id) REFERENCES zonas (zonaloc_ref_id);

alter table hogares
add constraint fk_hogares_viviendas foreign key (vivienda_ref_id) REFERENCES viviendas (vivienda_ref_id);

alter table personas
add constraint fk_personas_hogares foreign key (hogar_ref_id) REFERENCES hogares (hogar_ref_id);

alter table zonas
add comuna char(5);

alter table zonas
add provincia char(3);

alter table zonas
add region char(2);

update zonas set comuna = substring(geocodigo, 1, 5);

update zonas set provincia = substring(geocodigo, 1, 3);

update zonas set region = substring(geocodigo, 1, 2);

create unique index idx_comunas on comunas (redcoden);

create unique index idx_regiones on regiones (redcoden);

create unique index idx_provincias on provincias (redcoden);

alter table zonas
add constraint fk_zonas_comunas foreign key (comuna) REFERENCES comunas (redcoden);

alter table zonas
add constraint fk_zonas_provincias foreign key (provincia) REFERENCES provincias (redcoden);

alter table zonas
add constraint fk_zonas_regiones foreign key (region) REFERENCES regiones (redcoden);

