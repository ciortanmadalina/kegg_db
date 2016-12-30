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



#### 2. Transform raw data to desired schema


### Results
This project queries the kegg website (http://www.kegg.jp/kegg/docs/keggapi.html) in order to retrieve data about pathways, modules, reactions and compounds.

setup.sh installs postresql and creates a database named "bio".  
schema.sql creates the psql schema. A number of "raw" tables have been created to facilitate data import as their primary key is the functional kegg ID. In a second phase we will transfer data from raw tables to the tables implementing the final relational model.

import_data.sh makes get calls to rest webservices, parses the input and generates insert sql files ( e.g. insert_into_raw_pathway.sql, insert_into_raw_pathway_module.sql, etc)  

setup_db.sh first creates the schema using schema.sql, then invokes the insert files in order to populate the raw version of our tables.


There are cases when 1 module has references to multiple reactions comma separated:
http://rest.kegg.jp/get/M00633  
Even though in the modules file both reactions point to the same componds, the detailed pages point to different results. This scenario can be found from path http://rest.kegg.jp/get/path:map00030 (last module).

