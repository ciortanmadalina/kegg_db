insert into pathway select * from  raw_pathway;
insert into reaction select * from  raw_reaction;
insert into enzyme select * from  raw_enzyme;
insert into biological_molecule  select * from  raw_compound;

insert into pathway_reaction (pathway_id, reaction_id )
select pm.pathway, rm.reaction from raw_pathway_module pm, raw_module_reaction rm 
where pm.module= rm.module order by pm.pathway;

insert into reaction_molecule  (reaction_id, molecule_id , type )
select rc.reaction, rc.compound, 
case when rc.type='INPUT' then 'SUBSTRATE' else 'PRODUCT' end
from raw_reaction_compound rc ;

insert into reaction_enzyme select * from raw_reaction_enzyme ;
