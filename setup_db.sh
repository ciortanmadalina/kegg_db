#!/bin/bash

sudo -u postgres psql bio < schema.sql

sudo -u postgres psql bio < output/insert_compound.sql         

sudo -u postgres psql bio < output/insert_pathway.sql

sudo -u postgres psql bio < output/insert_enzyme.sql

sudo -u postgres psql bio < output/insert_reaction_enzyme.sql

sudo -u postgres psql bio < output/insert_module_reaction.sql  

sudo -u postgres psql bio < output/insert_reaction_compound.sql

sudo -u postgres psql bio < output/insert_pathway_module.sql
