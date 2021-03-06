alter table biological_molecule add primary key (id);
create index  biological_molecule_index ON biological_molecule (id);
alter table reaction  add primary key (id);
create index  reaction_index ON reaction (id);
alter table reaction_molecule add constraint rmm_fkey foreign key (molecule_id) references biological_molecule (id) on delete cascade;
alter table reaction_molecule add constraint rmr_fkey foreign key (reaction_id) references reaction (id) on delete cascade;
alter table enzyme add primary key (id);
create index enzyme_index ON enzyme(id);
alter table pathway add primary key (id);
create index  pathway_index ON pathway(id);
alter table pathway_reaction  add constraint prp_fkey foreign key (pathway_id) references pathway(id) on delete cascade;
alter table pathway_reaction  add constraint prr_fkey foreign key (reaction_id ) references reaction(id) on delete cascade;
alter table reaction_enzyme   add constraint rer_fkey foreign key (reaction_id ) references reaction(id) on delete cascade;
alter table reaction_order   add constraint ro1_fkey foreign key (parentid) references reaction(id) on delete cascade;
alter table reaction_order   add constraint ro2_fkey foreign key (childid) references reaction(id) on delete cascade;
create index  reaction_order_parent_index ON reaction_order(parentid);
create index  reaction_order_child_index ON reaction_order(childid);
