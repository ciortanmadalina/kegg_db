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
compound varchar(15), 
type varchar(10)
);

CREATE TABLE raw_compound (
id varchar (15),
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

CREATE TABLE biological_molecule (
id varchar (15),
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
molecule_id varchar (15),
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

