<center> <h2>Biological pathways database </h2></center>
<center> <h4>Madalina Ciortan </h4></center>
<center>December 2016</center>

### Project scope

This project constitutes a learning exercise for both modeling a biological component (metabolic pathways) using the entity-relationship paradigm and the hands on implementation of the conceptual schema in a PostgreSQL database.

### Resources

Kegg API (http://www.kegg.jp/kegg/docs/keggapi.html) was chosen to provide input data for the implementation.  
It exposes a REST interface providing data about the following biological categories:  
```
http://rest.kegg.jp/find/<database>/<query>

<database> = pathway | module | ko | genome | <org> | compound | glycan |
             reaction | rclass | enzyme | disease | drug | dgroup | environ |
             genes | ligand
<org> = KEGG organism code or T number
```

All biological entities have an unique identifier which can be used in get queries in order to retrieve the adjacent details. For instance,
- http://rest.kegg.jp/get/path:map00030 provides details about the metabolic pathway map00030 (Pentose phosphate pathway)
- http://rest.kegg.jp/get/R02035 provides details about R02035 (6-Phospho-D-glucono-1,5-lactone lactonohydrolase), etc

### Implementation
A conceptual model (.svg file) has been created by the biologists' team.  

![Image](https://raw.githubusercontent.com/ciortanmadalina/kegg_db/master/conceptual_diagram.png)

It became clear very quickly that the conceptual model doesn't match perfectly the reality of data available on Kegg.  
The following differences can be mentioned:
- Kegg doesn't provide data about the classification of biological molecules as proteins, nucleic acids, metabolites, polysaccharides, nor about the number of amino-acids or bases they are composed of  
- For biological reactions, Kegg doesn't specify the stoichiometric coefficient, not the classification of biological molecules as cofactors/ inhibitors. It describes only the enzymes, the substrate and the products  
- Kegg doesn't provide information about the cellular types nor about the organisms pathways are expressed in
- On kegg, pathways are composed of modules which are a collection of reactions. These modules can regroup reactions specific to particular species or conditions. The biologists analysed these data and agreed on a limited selection of pathways/ modules which are representative for this proof of concept (see **input** file in the root of this project for all details)

```
Glycolyse :
http://rest.kegg.jp/get/map00010
http://rest.kegg.jp/get/M00001

Cycle de krebs
http://rest.kegg.jp/get/map00020
http://rest.kegg.jp/get/M00009

Pentose phosphate
http://rest.kegg.jp/get/map00030
http://rest.kegg.jp/get/M00004

```

The implementation consisted of the following 2 phases:
#### 1. Import raw data from Kegg
The goal of this phase is to automatically gather all relevant data from Kegg and to expose it as SQL data which can easily be modified in the second phase in order to match the final desired SQL schema model.  
These actions are performed by the 3 steps below:

##### 1.1 Import_data.sh
This bash script performs the following actions:
- reads input file and for all pairs pathway - module retrieves the related Kegg data.
- Kegg data is being parsed by the python scripts (located in the scripts folder) which extract the relevant details and generate sql insert statements for "raw" tables, matching precisely the input structure. For instance, parse_pathway.py generates:

```sql
INSERT INTO raw_pathway (id, name, description, class) VALUES ('map00010' , 'Glycolysis / Gluconeogenesis' , 'Glycolysis is the process of converting glucose into pyruvate and generating small amounts of ATP (energy) and NADH (reducing power). It is a central pathway that produces important precursor metabolites: six-carbon compounds of glucose-6P and fructose-6P and three-carbon compounds of glycerone-P, glyceraldehyde-3P, glycerate-3P, phosphoenolpyruvate, and pyruvate [MD:M00001]. Acetyl-CoA, another important precursor metabolite, is produced by oxidative decarboxylation of pyruvate [MD:M00307]. When the enzyme genes of this pathway are examined in completely sequenced genomes, the reaction steps of three-carbon compounds from glycerone-P to pyruvate form a conserved core module [MD:M00002], which is found in almost all organisms and which sometimes contains operon structures in bacterial genomes. Gluconeogenesis is a synthesis pathway of glucose from noncarbohydrate precursors. It is essentially a reversal of glycolysis with minor variations of alternative paths [MD:M00003].' , 'Metabolism; Carbohydrate metabolism');
INSERT INTO raw_pathway (id, name, description, class) VALUES ('map00020' , 'Citrate cycle (TCA cycle)' , 'The citrate cycle (TCA cycle, Krebs cycle) is an important aerobic pathway for the final steps of the oxidation of carbohydrates and fatty acids. The cycle starts with acetyl-CoA, the activated form of acetate, derived from glycolysis and pyruvate oxidation for carbohydrates and from beta oxidation of fatty acids. The two-carbon acetyl group in acetyl-CoA is transferred to the four-carbon compound of oxaloacetate to form the six-carbon compound of citrate. In a series of reactions two carbons in citrate are oxidized to CO2 and the reaction pathway supplies NADH for use in the oxidative phosphorylation and other metabolic processes. The pathway also supplies important precursor metabolites including 2-oxoglutarate. At the end of the cycle the remaining four-carbon part is transformed back to oxaloacetate. According to the genome sequence data, many organisms seem to lack genes for the full cycle [MD:M00009], but contain genes for specific segments [MD:M00010 M00011].' , 'Metabolism; Carbohydrate metabolism');

```
- parse_module.py generates sql for joining modules with reactions, reactions with compounds and the order of reaction in a module. Reactions may for cyclical or acyclical graphs (see loop parameter):

```sql
INSERT INTO raw_reaction_order (parentid, childid, module, loop) VALUES ( 'R01786' , 'R02740' , 'M00001' , false );
INSERT INTO raw_reaction_order (parentid, childid, module, loop) VALUES ( 'R02189' , 'R02740' , 'M00001' , false );
INSERT INTO raw_reaction_order (parentid, childid, module, loop) VALUES ( 'R09085' , 'R02740' , 'M00001' , false );
```
- generated join files (insert_reaction_compound.sql, insert_reaction_enzyme.sql) are being parsed in order to retrieve details about compounds and enzymes

In the end the following insert sql are generated in the output folder:
```
insert_compound.sql  
insert_module_reaction.sql  
insert_pathway.sql            
insert_reaction_enzyme.sql  
insert_reaction.sql
insert_enzyme.sql    
insert_pathway_module.sql   
insert_reaction_compound.sql  
insert_reaction_order.sql

```

##### 1.2 setup.sh
This bash script installs postgres on a ubuntu machine and creates the database 'bio'

##### 1.3 setup_db.sh
This bash script creates the schema for the raw data
```sql
CREATE TABLE raw_pathway (
id varchar(10),
name varchar (200),
description varchar (5000),
class varchar(100)
);

CREATE TABLE raw_pathway_module (
pathway varchar (150),
module varchar (150)
);

CREATE TABLE raw_module_reaction(
module varchar (10),
reaction varchar (10)
);

CREATE TABLE raw_reaction(
id varchar (10),
name varchar (300),
definition varchar (300)
);

CREATE TABLE raw_reaction_compound (
reaction varchar(10),
compound varchar(10),
type varchar(10)
);

CREATE TABLE raw_compound (
id varchar (10),
name varchar(500),
formula varchar(100),
mass varchar (100)
);

CREATE TABLE raw_reaction_enzyme (
reaction varchar (10),
enzyme varchar (15)
);

CREATE TABLE raw_enzyme (
id varchar (15),
name varchar (700)
);


CREATE TABLE raw_reaction_order (
parentid varchar(10),
childid varchar(10),
loop boolean DEFAULT false,
module varchar(10)
);

```
And then runs all scripts generated during the first phase.  
At this point we have all Kegg data accessible in SQL.

#### 2. Transform raw data to desired schema

This phase creates the final SQL schema, matching the conceptual model as such:

![Image](https://raw.githubusercontent.com/ciortanmadalina/kegg_db/master/db_schema.png)

```sql
CREATE TABLE biological_molecule (
id varchar (10),
name varchar(500),
formula varchar(100),
mass varchar (100),
type varchar(1)
);

CREATE TABLE reaction (
id varchar (10),
name varchar (300),
definition varchar (300)
);

CREATE TABLE enzyme (
id varchar (15),
name varchar (700)
);

CREATE TABLE pathway (
id varchar(10),
name varchar (200),
description varchar (5000),
class varchar(100)
);

CREATE TABLE pathway_reaction (
pathway_id varchar (10),
reaction_id varchar (10)
);

CREATE TABLE reaction_molecule (
molecule_id varchar (10),
reaction_id varchar (10),
type varchar(10),
coefficient REAL
);

CREATE TABLE reaction_enzyme (
reaction_id varchar (10),
enzyme_id varchar (15)
);

CREATE TABLE reaction_order (
    parentid varchar(10),
    childid varchar(10),
    loop boolean DEFAULT false,
    pathway varchar(10)
);

```

patch.sql transfers data from the raw tables to the conceptual ones.  
A better visualisation of the a/cyclical chain of reactions is given with the help of the WITH RECURSIVE functionality, which is able to extract all end to end paths in a graph:

```sql
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

```

These results are stored in a view (pathway_chain_reactions).  
The last script (db_fine_tuning.sql) adds primary/foreign keys and indexes in order to improve queries performance.

### Results

This section shows preview data from all tables:  
```sql
bio=# select * from biological_molecule limit 3;
   id   |                                      name                                      |    formula     |   mass   | type
--------+--------------------------------------------------------------------------------+----------------+----------+------
 C00018 | Pyridoxal phosphate; Pyridoxal 5-phosphate; Pyridoxal 5'-phosphate; PLP        | C8H10NO6P      | 247.0246 |
 C00022 | Pyruvate; Pyruvic acid; 2-Oxopropanoate; 2-Oxopropanoic acid; Pyroracemic acid | C3H4O3         | 88.016   |
 C00024 | Acetyl-CoA; Acetyl coenzyme A                                                  | C23H38N7O17P3S | 809.1258 |
(3 rows)

```

```sql
bio=# select * from reaction limit 3;
   id   |                    name                    |                       definition                        
--------+--------------------------------------------+---------------------------------------------------------
 R00200 | ATP:pyruvate 2-O-phosphotransferase        | ATP + Pyruvate <=> ADP + Phosphoenolpyruvate
 R00238 | Acetyl-CoA:acetyl-CoA C-acetyltransferase  | 2 Acetyl-CoA <=> CoA + Acetoacetyl-CoA
 R00259 | acetyl-CoA:L-glutamate N-acetyltransferase | Acetyl-CoA + L-Glutamate <=> CoA + N-Acetyl-L-glutamate
(3 rows)

```

```sql
bio=# select e.id, substring(e.name, 1, 50) from enzyme e limit 3;
    id     |                     substring                      
-----------+----------------------------------------------------
 1.1.1.145 | 3beta-hydroxy-Delta5-steroid dehydrogenase; proges
 1.1.1.211 | long-chain-3-hydroxyacyl-CoA dehydrogenase; beta-h
 1.1.1.23  | histidinol dehydrogenase; L-histidinol dehydrogena
(3 rows)

```

```sql
bio=# select p.id, p.name, substring(p.description, 1, 50), p.class from pathway p limit 3;
    id    |             name             |                     substring                      |                class                
----------+------------------------------+----------------------------------------------------+-------------------------------------
 map00010 | Glycolysis / Gluconeogenesis | Glycolysis is the process of converting glucose in | Metabolism; Carbohydrate metabolism
 map00020 | Citrate cycle (TCA cycle)    | The citrate cycle (TCA cycle, Krebs cycle) is an i | Metabolism; Carbohydrate metabolism
 map00030 | Pentose phosphate pathway    | The pentose phosphate pathway is a process of gluc | Metabolism; Carbohydrate metabolism
(3 rows)

```

```sql
bio=# select * from reaction_order limit 3;
 parentid | childid | loop | pathway  
----------+---------+------+----------
 R00238   | R01978  | f    | map00072
 R00259   | R02649  | f    | map01230
 R00267   | R00621  | f    | map00020
(3 rows)

```

```sql
bio=# select * from reaction_enzyme  limit 3;
 reaction_id | enzyme_id
-------------+-----------
 R00200      | 2.7.1.40
 R00238      | 2.3.1.9
 R00259      | 2.3.1.1
(3 rows)

```


```sql
bio=# select * from reaction_molecule  limit 3;
 molecule_id | reaction_id |   type    | coefficient
-------------+-------------+-----------+-------------
 C00022      | R00200      | PRODUCT   |            
 C00074      | R00200      | SUBSTRATE |            
 C00024      | R00238      | SUBSTRATE |            
(3 rows)

```

Reactions associated to a pathway can be retrived :

```sql
bio=# select * from pathway_reaction where pathway_id = 'map00010';
 pathway_id | reaction_id 
------------+-------------
 map00010   | R00200
 map00010   | R00658
 map00010   | R01015
 map00010   | R01061
 map00010   | R01063
 map00010   | R01070
 map00010   | R01512
 map00010   | R01518
 map00010   | R01786
 map00010   | R02189
 map00010   | R02740
 map00010   | R04779
 map00010   | R07159
 map00010   | R09084
 map00010   | R09085
(15 rows)

```

Enzymes cathalysing these reactions can be retrieved:

```sql
bio=# select re.reaction_id, substring(e.name, 1, 100) as enzyme_name from enzyme e, reaction_enzyme re where re.reaction_id in ( select reaction_id from pathway_reaction where pathway_id = 'map00010') and e.id = re.enzyme_id limit 5;


reaction_id |                                             enzyme_name                                              
-------------+------------------------------------------------------------------------------------------------------
 R00200      | pyruvate kinase; phosphoenolpyruvate kinase; phosphoenol transphosphorylase
 R00658      | phosphopyruvate hydratase; enolase; 2-phosphoglycerate dehydratase; 14-3-2-protein; nervous-system s
 R01015      | triose-phosphate isomerase; phosphotriose isomerase; triose phosphoisomerase; triose phosphate mutas
 R01061      | glyceraldehyde-3-phosphate dehydrogenase (phosphorylating); triosephosphate dehydrogenase; dehydroge
 R01061      | glyceraldehyde-3-phosphate dehydrogenase (NAD(P)+) (phosphorylating); triosephosphate dehydrogenase 
(5 rows)


```

Biological molecules participating in such reactions can be retrieved:  

```sql

bio=# select rm.reaction_id, m.id, substring (m.name, 1, 50), m.formula, m.mass, rm.type from biological_molecule m, reaction_molecule rm where m.id = rm.molecule_id and rm.reaction_id = 'R00200';

 reaction_id |   id   |                     substring                      | formula |   mass   |   type    
-------------+--------+----------------------------------------------------+---------+----------+-----------
 R00200      | C00022 | Pyruvate; Pyruvic acid; 2-Oxopropanoate; 2-Oxoprop | C3H4O3  | 88.016   | PRODUCT
 R00200      | C00074 | Phosphoenolpyruvate; Phosphoenolpyruvic acid; PEP  | C3H5O6P | 167.9824 | SUBSTRATE
(2 rows)


```

In order to visualise the chain reactions generated using "with recursive", pathway_chain_reactions view can be queried :  


```sql
bio=# select * from pathway_chain_reactions limit 10;
                                    chain_reactions                                     | circular | pathway  
----------------------------------------------------------------------------------------+----------+----------
 R00200->R00658->R01518->R07159->R01512->R01061->R01015->R01070->R09084->R02740->R02189 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R04779->R02740->R09085 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R04779->R02740->R01786 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01061->R01015->R01070->R09084->R02740->R09085 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R09084->R02740->R02189 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R09084->R02740->R09085 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R09084->R02740->R01786 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01063->R01015->R01070->R04779->R02740->R02189 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01061->R01015->R01070->R04779->R02740->R09085 | LINEAR   | map00010
 R00200->R00658->R01518->R07159->R01512->R01061->R01015->R01070->R09084->R02740->R01786 | LINEAR   | map00010
(10 rows)


```

