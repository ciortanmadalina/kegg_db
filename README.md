<center> <h2>Biological pathways database </h2></center>
<center> <h4>Madalina Ciortan </h4></center>
<center>December 2016</center>

### Project scope

This project constitutes a learning exercise for both modelling a biological component (metabolic pathways) using the entity-relationship paradigm and the hands on implementation of the conceptual schema in a PostgreSQL database.

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

These results are stored in a view (pathway_chain_reactions)
### Results
This project queries the kegg website (http://www.kegg.jp/kegg/docs/keggapi.html) in order to retrieve data about pathways, modules, reactions and compounds.

setup.sh installs postresql and creates a database named "bio".  
schema.sql creates the psql schema. A number of "raw" tables have been created to facilitate data import as their primary key is the functional kegg ID. In a second phase we will transfer data from raw tables to the tables implementing the final relational model.

import_data.sh makes get calls to rest webservices, parses the input and generates insert sql files ( e.g. insert_into_raw_pathway.sql, insert_into_raw_pathway_module.sql, etc)  

setup_db.sh first creates the schema using schema.sql, then invokes the insert files in order to populate the raw version of our tables.


There are cases when 1 module has references to multiple reactions comma separated:
http://rest.kegg.jp/get/M00633  
Even though in the modules file both reactions point to the same componds, the detailed pages point to different results. This scenario can be found from path http://rest.kegg.jp/get/path:map00030 (last module).

