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


insert into reaction_order (parentid, childid, pathway )
select r.parentid, r.childid, pm.pathway from raw_reaction_order r, raw_pathway_module pm 
where pm.module = r.module;

create or replace view pathway_chain_reactions as
WITH RECURSIVE find_pathway_chain_reactions( parentid, path, start, pathway )
AS
(
    select parentid, '' || childid, childid, pathway from reaction_order
    union all
    select reaction_order.parentid, find_pathway_chain_reactions.path || '->' || reaction_order.childid, start, reaction_order.pathway
    from reaction_order, find_pathway_chain_reactions
    where reaction_order.childid = find_pathway_chain_reactions.parentid 
    and reaction_order.loop = false 
    and find_pathway_chain_reactions.pathway = reaction_order.pathway
)
select root.path || '->' || root.parentid as chain_reactions, 
case when reaction.loop=true then 'CIRCULAR' else 'LINEAR' end as circular, 
root.pathway
from find_pathway_chain_reactions root
left join reaction_order reaction on root.start = reaction.parentid and root.pathway = reaction.pathway
where 
root.parentid not in (select childid from reaction_order where loop=false)
and 
root.start not in 
  (select parentid from reaction_order where loop= false 
  and pathway = root.pathway
  )
order by root.pathway;
