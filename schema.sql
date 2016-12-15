CREATE TABLE raw_pathway (
    name varchar (150) PRIMARY KEY,
    description varchar (200));
  
CREATE TABLE raw_module_reaction(
    module varchar (10),
    reaction varchar (10)
);

CREATE TABLE raw_reaction_compound (
    reaction varchar(10), 
    compound varchar(10), 
    type varchar(10));


CREATE TABLE raw_pathway_module (
    pathway varchar (150),
    module varchar (150));
  
CREATE TABLE raw_compound (
    id varchar (10),
    name varchar(200),
    formula varchar(100),
    mass varchar (100));
  

