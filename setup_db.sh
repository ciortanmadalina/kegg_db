#!/bin/bash

sudo -u postgres psql bio < schema.sql
sudo -u postgres psql bio < insert_into_raw_pathway.sql
sudo -u postgres psql bio < insert_into_raw_pathway_module.sql
