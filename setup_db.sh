#!/bin/bash
export PGPASSWORD='postgres'
sudo -u postgres psql bio < schema.sql
echo 'insert_compound ...'
sudo -u postgres psql bio < output/insert_compound.sql         
echo 'insert pathway'
sudo -u postgres psql bio < output/insert_pathway.sql
echo 'insert enzyme'
sudo -u postgres psql bio < output/insert_enzyme.sql
echo 'insert react'
sudo -u postgres psql bio < output/insert_reaction.sql
echo 'insert reaction enz'
sudo -u postgres psql bio < output/insert_reaction_enzyme.sql
echo 'insert module react'
sudo -u postgres psql bio < output/insert_module_reaction.sql  
echo 'insert reaction comp'
sudo -u postgres psql bio < output/insert_reaction_compound.sql
echo 'insert patway mod'
sudo -u postgres psql bio < output/insert_pathway_module.sql
echo 'insert reaction order'
sudo -u postgres psql bio < output/insert_reaction_order.sql
echo 'patch'
sudo -u postgres psql bio < patch.sql
echo 'fine tuning'
sudo -u postgres psql bio < db_fine_tuning.sql
