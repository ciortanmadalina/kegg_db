alter table biological_molecule add primary key (id);
create index  biological_molecule_index ON biological_molecule (id);

alter table reaction  add primary key (id);
create index  reaction_index ON reaction (id);

alter table reaction_molecule add constraint molecule_fkey foreign key (molecule_id) references biological_molecule (id) on delete cascade;
alter table reaction_molecule add constraint reaction_fkey foreign key (reaction_id ) references reaction (id) on delete cascade;


alter table enzyme add primary key (id);
create index  enzyme_index ON enzyme(id);

alter table pathway add primary key (id);
create index  pathway_index ON pathway(id);
