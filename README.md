## Biological pathways database

This project queries the kegg website (http://www.kegg.jp/kegg/docs/keggapi.html) in order to retrieve data about pathways, modules, reactions and compounds.

setup.sh installs postresql and creates a database named "bio".  
schema.sql creates the psql schema. A number of "raw" tables have been created to facilitate data import as their primary key is the functional kegg ID. In a second phase we will transfer data from raw tables to the tables implementing the final relational model.
  
import_data.sh makes get calls to rest webservices, parses the input and generates insert sql files ( e.g. insert_into_raw_pathway.sql, insert_into_raw_pathway_module.sql, etc)  

setup_db.sh first creates the schema using schema.sql, then invokes the insert files in order to populate the raw version of our tables.
